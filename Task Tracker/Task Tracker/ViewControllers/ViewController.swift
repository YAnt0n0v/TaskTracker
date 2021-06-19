import UIKit
import CoreData

class ViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var tasksTableView: UITableView!
    
    //Filelds
    let queue = DispatchQueue.global(qos: .userInteractive)
    var context: NSManagedObjectContext!
    var tasks: [Task] = []
    var filteredTasks: [Task] = []
    
    //Private fields
    private var mode: EditorMode? = .none
    private var editData: (Task, Int)?
    private var repeatsCheckTimer = Timer()
    private var expireCheckTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        
        tasksTableView.register(UINib(nibName: TaskCell.identifier, bundle: nil), forCellReuseIdentifier: TaskCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.overrideUserInterfaceStyle = .light
        
        loadData()
        tasksTableView.reloadData()
        subscribe(forNotification: Notification.Name("unsavedData"))
        
        repeatsCheckTimer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(startRepeatsCheck),
            userInfo: nil,
            repeats: true)
        
        expireCheckTimer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(startExpireCheck),
            userInfo: nil,
            repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        repeatsCheckTimer.invalidate()
        expireCheckTimer.invalidate()
    }
    
    //Notifications handling
    func subscribe(forNotification name: Notification.Name) {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: name, object: nil)
    }
    
    @objc func notificationHandler(_ notification: Notification) {
        if notification.name.rawValue == "unsavedData" {
            saveData()
        }
    }
    
    @IBAction func addNewTask(_ sender: Any) {
        
        mode = .new
        performSegue(withIdentifier: "taskEditorSegue", sender: nil)
    }
    
    @IBAction func clearFilters(_ sender: Any) {
        
        select(filter: .none)
        for i in 0...3 {
            filterCollectionView.deselectItem(at: IndexPath(row: i, section: 0), animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? TaskEditorViewController else {
            return
        }
        if mode! == .new {
            destination.editorData = ("New Task", nil, nil)
            destination.mode = .new
            destination.newTaskDelegate = self
        } else {
            destination.editorData = ("Edit Task", editData!.0, editData!.1)
            destination.startDate = editData!.0.startDate
            destination.finishDate = editData!.0.finishDate
            destination.mode = .edit
            destination.editTaskDelegate = self
        }
    }
    
    func select(filter: State) {
        
        if filter == .none {
            filteredTasks = tasks
        } else {
            filteredTasks = tasks.filter({task in
                if State(rawValue: task.state)! == filter {
                    return true
                }
                return false
            })
        }
        tasksTableView.reloadData()
    }
    
    //MARK: - Private Functions
    
    //Cloning task
    private func clone(of task: Task) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext! = appDelegate.persistentContainer.viewContext
        
        let newTask = Task(context: context)
        newTask.note = task.note
        newTask.title = task.title
        newTask.state = 0
        
        let repeatType: RepeatType = RepeatType(rawValue: task.repeatType)!
        let calendar = Calendar.current
        var start: Date = task.startDate
        
        switch repeatType {
        
        case .daily:
            start = calendar.date(byAdding: .day, value: 1, to: task.startDate)!
        case .weekly:
            start = calendar.date(byAdding: .day, value: 7, to: task.startDate)!
        case .monthly:
            start = calendar.date(byAdding: .month, value: 1, to: task.startDate)!
        case .none:
            start = NSDate() as Date
        }
        
        newTask.startDate = start
        let difference = (calendar.dateComponents([.minute], from: task.startDate, to: task.finishDate)).minute ?? 0
        newTask.finishDate = calendar.date(byAdding: .minute, value: difference, to: start)!
        newTask.repeatType = task.repeatType
        task.isCloned = true
        append(newTask)
    }
    
    //Checking if need clone task with repeats
    @objc
    private func startRepeatsCheck() {
        
        queue.sync {[unowned self] in
            
            for task in tasks {
                
                let repeatType: RepeatType = RepeatType(rawValue: task.repeatType)!
                
                if !task.isCloned && repeatType != .none{
                    
                    let calendar = Calendar.current
                    var start: Date = task.startDate
                    switch repeatType {
                    
                    case .daily:
                        start = calendar.date(byAdding: .day, value: 1, to: start)!
                    case .weekly:
                        start = calendar.date(byAdding: .day, value: 7, to: start)!
                    case .monthly:
                        start = calendar.date(byAdding: .month, value: 1, to: start)!
                    case .none:
                        start = NSDate() as Date
                    }
                    
                    if start < NSDate() as Date {
                        
                        DispatchQueue.main.async {
                            
                            clone(of: task)
                            select(filter: .none)
                            for i in 0...3 {
                                filterCollectionView.deselectItem(at: IndexPath(row: i, section: 0), animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Checking if task time was expired and task was not completed
    @objc
    private func startExpireCheck() {
        
        queue.sync {[unowned self] in
            
            for (i, task) in tasks.enumerated() {
                
                if State(rawValue: task.state) != .expired && State(rawValue: task.state) != .finish {
                    
                    if NSDate() as Date > task.finishDate {
                        
                        DispatchQueue.main.async {
                            
                            let cell = tasksTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! TaskCell
                            
                            if cell.task == task {
                                task.state = 3
                                UIView.animate(withDuration: 1, animations: {
                                    cell.backColorView.backgroundColor = TaskCell.data[task.state].1
                                })
                                
                                cell.stateImageView.image = TaskCell.data[task.state].0
                                
                                saveData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Core Data loading
    private func loadData() {
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            try tasks = context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        tasks.sort(by: {
            return $0.finishDate <= $1.finishDate
        })
        
        filteredTasks = tasks
    }
    
    //Core Data saving
    private func saveData() {
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
//MARK: - Extensions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tasksTableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as! TaskCell
        cell.setUpCell(with: filteredTasks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete Task", handler: {[unowned self] (action, view, completitionHandler) in
            
            context.delete(tasks[indexPath.row])
            self.tasks.remove(at: indexPath.row)
            filteredTasks = tasks
            self.tasksTableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        })
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Edit Task", handler: {[unowned self] (action, view, completitionHandler) in
            
            mode = .edit
            editData = (filteredTasks[indexPath.row], indexPath.row)
            performSegue(withIdentifier: "taskEditorSegue", sender: nil)
        })
        
        action.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
    }
    
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionCell.identifier, for: indexPath) as! FilterCollectionCell
        
        cell.setUpCell(with: indexPath.row)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        select(filter: State(rawValue: indexPath.row)!)
    }
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let totalCellWidth = 320
        let totalSpacingWidth = 30

        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
extension ViewController: NewTaskDelegate, EditTaskDelegate {
    
    func insert(_ task: Task, on position: Int) {
        tasks[position] = task
        tasks.sort(by: {
            return $0.finishDate <= $1.finishDate
        })
        filteredTasks = tasks
        saveData()
    }
    
    func append(_ task: Task) {
        tasks.append(task)
        tasks.sort(by: {
            return $0.finishDate <= $1.finishDate
        })
        filteredTasks = tasks
        saveData()
    }
}
