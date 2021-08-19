//
//  ForgotPasswordVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 30/11/20.
//

import UIKit
import Firebase
import SwiftMessages

class ForgotPasswordVC: UIViewController {

    
    @IBOutlet weak var txtEmail : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtEmail.setLeftPaddingPoints(15.0)
    }
    

    //MARK:- OnClick Action Method
        @IBAction func onClickCross(){
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        @IBAction func onClickSubmit(){
            if txtEmail.text! == ""  {
                let vW = Utility.displaySwiftAlert("", "Please enter email", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else if !Utility.isValidEmail(testStr: txtEmail.text!) {
                let vW = Utility.displaySwiftAlert("", "Please enter valid email", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else {
                if NetworkMonitor.shared.isReachable {
                    Auth.auth().sendPasswordReset(withEmail: txtEmail.text!) { error in
                        print(error!)
                        let vW = Utility.displaySwiftAlert("", error!.localizedDescription, type: SwiftAlertType.error.rawValue)
                        SwiftMessages.show(view: vW)
                    }
                }
                else {
                    let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                }
            }
        }

}
