//
//  OTPTextField.swift
//  WTM
//
//  Created by Tarun Sachdeva on 16/01/21.
//

import UIKit

class OTPTextField: UITextField {

    weak var previousTextField: OTPTextField?
    weak var nextTextField: OTPTextField?
    
    
    override public func deleteBackward(){
        text = ""
        previousTextField?.becomeFirstResponder()
    }

}
