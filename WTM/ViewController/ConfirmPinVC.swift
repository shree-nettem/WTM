//
//  ConfirmPinVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 16/01/21.
//

import UIKit
import SwiftMessages
import Firebase

class ConfirmPinVC: UIViewController {

    @IBOutlet weak var otpContainerView: UIView!
    @IBOutlet weak var testButton: UIButton!
    let otpStackView = OTPStackView()
    var previousOTP = String()
    @IBOutlet weak var pinView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        otpContainerView.addSubview(otpStackView)
        otpStackView.delegate = self
        otpStackView.heightAnchor.constraint(equalTo: otpContainerView.heightAnchor).isActive = true
        otpStackView.centerXAnchor.constraint(equalTo: otpContainerView.centerXAnchor).isActive = true
        otpStackView.centerYAnchor.constraint(equalTo: otpContainerView.centerYAnchor).isActive = true
        
       
        
    }
    
    @IBAction func onClickBackAcn(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func clickedForHighlight(_ sender: UIButton) {
        print("Final OTP : ",otpStackView.getOTP())
        otpStackView.setAllFieldColor(isWarningColor: true, color: .yellow)
        
        if otpStackView.getOTP().count < 4 {
            otpStackView.shake()
        }
        else if previousOTP == otpStackView.getOTP() {
            Utility.showActivityIndicator()
            saveUserOTPInDB()
            let vW = Utility.displaySwiftAlert("", "PIN Saved Successfully!!" , type: SwiftAlertType.success.rawValue)
            SwiftMessages.show(view: vW)
        }
        else {
            let vW = Utility.displaySwiftAlert("", "Please enter Same PIN!!" , type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
    }
    
    
    func saveUserOTPInDB() {
        let db = Firestore.firestore()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let docRef = db.collection("UserInfo").document(userID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                docRef.updateData([
                    "userPin": self.previousOTP,
                    "isPinON": true
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
        
        
        
        UserDefaults.standard.set(true, forKey: "isPinON")
        UserDefaults.standard.set(otpStackView.getOTP(), forKey: "userPin")
        UserDefaults.standard.synchronize()
        
        Utility.hideActivityIndicator()
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
        vc.isFromAdmin = false
        vc.isAgentEditTicket = false
        Constant.currentUserFlow = "Agent"
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension ConfirmPinVC: OTPDelegate {
    
    func didChangeValidity(isValid: Bool) {
      //  testButton.isUserInteractionEnabled = !isValid
    }
    
}
