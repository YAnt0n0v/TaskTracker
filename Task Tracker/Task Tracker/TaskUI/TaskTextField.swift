//
//  TaskTextField.swift
//  Task Tracker
//
//  Created by Kukina Anastasia on 02.02.2021.
//

import UIKit

@IBDesignable
class TaskTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
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
    
    @IBInspectable var placeholderTintColor: UIColor = .black {
        didSet {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: placeholder!)
            attributeString.addAttribute(.foregroundColor, value: placeholderTintColor, range: NSMakeRange(0, placeholder!.count))
            attributedPlaceholder = attributeString
        }
    }
}
