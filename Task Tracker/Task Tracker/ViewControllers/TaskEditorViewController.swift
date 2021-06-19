import UIKit
import CoreData

enum EditorMode {
    case new
    case edit
}

protocol NewTaskDelegate {
    
    func append(_ task: Task)
}
protocol EditTaskDelegate {
    
    func insert(_ task: Task, on position: Int)
}

class TaskEditorViewController: UIViewController {

    //Outlets
    @IBOutlet weak var titleLabel: TaskTextField!
    @IBOutlet weak var noteTextView: TaskTextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var finishDateLabel: UILabel!
    @IBOutlet weak var repeatsLabel: UILabel!
    
    //Fields
    var context: NSManagedObjectContext!
    var mode: EditorMode?
    var editorData: (String, Task?, Int?)?
    var startDate: Date?
    var finishDate: Date?
    var repeatType: RepeatType = .none
    var editTaskDelegate: EditTaskDelegate?
    var newTaskDelegate: NewTaskDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        titleLabel.delegate = self
        
        title = editorData!.0
        
        if mode! == .edit {
            
            titleLabel.text = editorData?.1?.title
            noteTextView.text = editorData?.1?.note
            
            setTime(start: (editorData?.1?.startDate)!, finish: (editorData?.1?.finishDate)!, repeats: RepeatType(rawValue: (editorData?.1?.repeatType)!)!)
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        self.view.addGestureRecognizer(recognizer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "timeEditorSegue" {
            
            let destination = segue.destination as! SetDateViewController
            destination.delegate = self
            
            if let startDate = self.startDate, let finishDate = self.finishDate {
                
                destination.startDate =  startDate
                destination.finishDate =  finishDate
                destination.repeatType = repeatType
            }
        }
    }
    
    func colorLabel() {
        
        var attributedText: NSMutableAttributedString = NSMutableAttributedString(string: startDateLabel.text!)
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, 6))
        startDateLabel.attributedText = attributedText
        
        attributedText = NSMutableAttributedString(string: finishDateLabel.text!)
        print(attributedText.string)
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, 7))
        finishDateLabel.attributedText = attributedText
        
        attributedText = NSMutableAttributedString(string: repeatsLabel.text!)
        print(attributedText.string)
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, 8))
        repeatsLabel.attributedText = attributedText
    }
    
    //MARK: - Actions
    @objc
    func tapHandler(_ recognizer: UIGestureRecognizer) {
        
        titleLabel.resignFirstResponder()
        noteTextView.resignFirstResponder()
    }
    
    @IBAction func acceptBtnPressed(_ sender: Any) {
        
        if let _ = startDate, let _ = finishDate {
            
            if mode! == .new {
                
                if titleLabel.text! != "" {
                    let task = Task(context: context)
                    task.state = 0
                    task.title = titleLabel.text!
                    task.note = noteTextView.text!
                    task.startDate = startDate!
                    task.finishDate = finishDate!
                    task.repeatType = repeatType.rawValue
                    
                    newTaskDelegate?.append(task)
                    navigationController?.popToRootViewController(animated: true)
                } else {
                    presentAlert(title: "Ooups!", message: "Please fill title gap!")
                }
            } else {
                
                if titleLabel.text! != "" {
                    
                    editorData!.1!.state = 0
                    editorData!.1!.title = titleLabel.text!
                    editorData!.1!.note = noteTextView.text!
                    editorData!.1!.startDate = startDate!
                    editorData!.1!.finishDate = finishDate!
                    editorData!.1!.repeatType = repeatType.rawValue
                    editorData!.1!.isCloned = false
                    editTaskDelegate?.insert(editorData!.1!, on: editorData!.2!)
                    navigationController?.popToRootViewController(animated: true)
                } else {
                    presentAlert(title: "Ooups!", message: "Please fill title gap!")
                }
            }
        } else {
            
            presentAlert(title: "Ooups!", message: "Please set start and finish date of the task!")
        }
        
    }
    
    
    @IBAction func editTime(_ sender: Any) {
        
        performSegue(withIdentifier: "timeEditorSegue", sender: nil)
    }
    
    private func presentAlert(title: String, message: String) {
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
//MARK: - Extensions
extension TaskEditorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
extension TaskEditorViewController: TaskTimeDelegate {
    
    
    func setTime(start: Date, finish: Date, repeats: RepeatType) {
        
        startDate = start
        finishDate = finish
        repeatType = repeats
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yy, h:mm a"
        startDateLabel.text = "Start: \(formatter.string(from: start))"
        finishDateLabel.text = "Finish: \(formatter.string(from: finish))"
        switch repeats {
            
        case.daily:
            repeatsLabel.text = "Repeats: Daily"
        case .weekly:
            repeatsLabel.text = "Repeats: Weekly"
        case .monthly:
            repeatsLabel.text = "Repeats: Monthly"
        case .none:
            repeatsLabel.text = "Repeats: No"
        }
        
        colorLabel()
    }
    
    
}
