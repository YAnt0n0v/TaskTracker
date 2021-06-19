//
//  TaskCell.swift
//  Task Tracker
//
//  Created by Kukina Anastasia on 02.02.2021.
//

import UIKit
import CoreData

enum State: Int {
    
    case new = 0
    case process
    case finish
    case expired
    case none
}

class TaskCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var backColorView: BackgroundView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var finishDateLabel: UILabel!
    @IBOutlet weak var repeatsLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!

    //Fields
    var task: Task?
    
    //Static fields
    static let identifier = "TaskCell"
    static let data: [(UIImage?, UIColor?)] = [(UIImage(named: "new"), UIColor(named: "newColor")),
                                              (UIImage(named: "process"), UIColor(named: "processColor")),
                                              (UIImage(named: "check"), UIColor(named: "completeColor")),
                                              (UIImage(named: "expired"), UIColor(named: "expiredColor"))]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
        recognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(recognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0))
    }
    
    func setUpCell(with task: Task) {
        
        self.task = task
        titleLabel.text = task.title
        noteLabel.text = task.note
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy, h:mm a"
        startDateLabel.text = "from: \(formatter.string(from: task.startDate))"
        finishDateLabel.text = "until: \(formatter.string(from: task.finishDate))"
        
        let repeats = RepeatType(rawValue: task.repeatType)!
        
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
        
        stateImageView.image = TaskCell.data[task.state].0
        backColorView.backgroundColor = TaskCell.data[task.state].1
    }
    
    //Double touch handler for changing task state
    @objc
    func doubleTapHandler(_ recognizer: UIGestureRecognizer) {
        
        if State(rawValue: task!.state)! == .new {
            task!.state  = 1
            
            UIView.animate(withDuration: 1, animations: {[unowned self] in
                backColorView.backgroundColor = TaskCell.data[task!.state].1
            })
            
            stateImageView.image = TaskCell.data[task!.state].0
            task!.postNotification(Notification.Name("unsavedData"))
        } else if State(rawValue: task!.state)! == .process {
            task!.state  = 2
            
            UIView.animate(withDuration: 1, animations: {[unowned self] in
                backColorView.backgroundColor = TaskCell.data[task!.state].1
            })
            
            stateImageView.image = TaskCell.data[task!.state].0
            task!.postNotification(Notification.Name("unsavedData"))
        }
    }
}
