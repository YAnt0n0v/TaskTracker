//
//  TaskDatePicker.swift
//  Task Tracker
//
//  Created by Kukina Anastasia on 02.02.2021.
//

import UIKit

@IBDesignable
class TaskDatePicker: UIDatePicker {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

}
