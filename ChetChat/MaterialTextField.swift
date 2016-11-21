//
//  MaterialTextField.swift
//  ChetChat
//
//  Created by Martyn Cheatle on 21/11/2016.
//  Copyright © 2016 Martyn Cheatle. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {
    
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor(red: SHADOW_COLOUR, green: SHADOW_COLOUR, blue: SHADOW_COLOUR, alpha: 0.1).cgColor
        layer.borderWidth = 1.0
    }
    
    // For Placeholder - move text in 10 from the left
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    // For Placeholder in Edit mode- move text in 10 from the left
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
}
