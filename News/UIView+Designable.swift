//
//  UIView+Designable.swift
//  LearningCreatingDesignable
//
//  Created by 01HW934413 on 25/03/16.
//  Copyright © 2016 01HW934413. All rights reser
//

import UIKit

@IBDesignable class DesignableImageView: UIImageView {}
@IBDesignable class DesignableButton: UIButton {}
@IBDesignable class DesignableTextField: UITextField {
    
    @IBInspectable
    var placeHolderTextColor: UIColor = UIColor.green{
        didSet {
            guard let placeholder = placeholder else {
                return
            }
            
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: placeHolderTextColor])
        }
    }
}

extension UIView {
    
    @IBInspectable
    var borderWidth: CGFloat {
        get{
            return layer.borderWidth
        }
        
        set(newBorderWidth){
            layer.borderWidth = newBorderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get{
            return layer.borderColor != nil ? UIColor(cgColor:  layer.borderColor!) : nil
        }
        
        set{
            layer.borderColor = newValue?.cgColor
        }
    }
    
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get{
            return layer.cornerRadius
        }
        
        set{
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue != 0
        }
    }
}
