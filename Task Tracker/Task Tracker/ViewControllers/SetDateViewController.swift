import UIKit

enum RepeatType: Int {
    
    case daily = 0
    case weekly
    case monthly
    case none
}

protocol TaskTimeDelegate {
    
    func setTime(start: Date, finish: Date, repeats: RepeatType)
}

class SetDateViewController: UIViewController {

    //Outlets
    @IBOutlet weak var startDatePicker: TaskDatePicker!
    @IBOutlet weak var finishDatePicker: TaskDatePicker!
    @IBOutlet var repeatButtons: [TaskCustomButton]!
    
    //Fields
    var delegate: TaskTimeDelegate?
    var startDate: Date?
    var finishDate: Date?
    var repeatType: RepeatType = .none
    
    //Private fields
    private let selectedColor: UIColor = UIColor(named: "completeColor")!
    private let unselectedColor: UIColor = .white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        
        if repeatType != .none {
            
            repeatButtons[repeatType.rawValue].backgroundColor = selectedColor
        }
        
        if let startDate = self.startDate, let finishDate = self.finishDate {
            
            startDatePicker.date =  startDate
            finishDatePicker.date =  finishDate
        }
        let calendar = Calendar.current
        finishDatePicker.minimumDate = calendar.date(byAdding: .minute, value: 1, to: startDatePicker.date)!
    }

    //MARK: - Actions
    @IBAction func selectRepeatType(_ sender: Any) {
        
        guard let repeatButton = sender as? TaskCustomButton else{
            return
        }
        
        for (i, button) in repeatButtons.enumerated() {
            
            if button == repeatButton {
                
                repeatType = button.backgroundColor == selectedColor ? .none : RepeatType(rawValue: i)!
                
                button.backgroundColor = button.backgroundColor == selectedColor ? unselectedColor : selectedColor
            } else {
                
                button.backgroundColor = unselectedColor
            }
        }
    }
    
    @IBAction func confirmChanges(_ sender: Any) {
        delegate?.setTime(start: startDatePicker.date, finish: finishDatePicker.date, repeats: repeatType)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startTimeEdited(_ sender: Any) {
        
        let calendar = Calendar.current
        finishDatePicker.minimumDate = calendar.date(byAdding: .minute, value: 1, to: startDatePicker.date)!
    }
    
}
