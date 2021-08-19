//
//  EnterPinVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 16/01/21.
//

import UIKit
import Firebase
import SwiftMessages
import FirebaseFirestore

class EnterPinVC: UIViewController  {

   
    @IBOutlet weak var usePinSwitch : UISwitch!
    @IBOutlet weak var otpContainerView: UIView!
    @IBOutlet weak var testButton: UIButton!
    let otpStackView = OTPStackView()
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var lblOldPin: UILabel!
    var userID = String()
    var isFromAdmin : Bool = false
    var pinAlreadyStatus : Bool = false
    var isFromRegister : Bool = false
    
    @IBOutlet weak var backButtonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otpContainerView.addSubview(otpStackView)
        otpStackView.delegate = self
        otpStackView.heightAnchor.constraint(equalTo: otpContainerView.heightAnchor).isActive = true
        otpStackView.centerXAnchor.constraint(equalTo: otpContainerView.centerXAnchor).isActive = true
        otpStackView.centerYAnchor.constraint(equalTo: otpContainerView.centerYAnchor).isActive = true
        
        getUserInfoFromDB()
        
        if isFromRegister {
            backButtonView.isHidden = true
        }
        else {
            backButtonView.isHidden = false
        }
        
    }
    
    func getUserInfoFromDB() {
        let db = Firestore.firestore()
        if !isFromAdmin {
            userID = CurrentUserInfo.userID!
        }
        userID = CurrentUserInfo.userID!
        let docRef = db.collection("UserInfo").document(userID)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data : NSDictionary = document.data()! as NSDictionary
                self.lblOldPin.text = (data["userPin"] as! String)
                let pinStatus = (data["isPinON"] as! Bool)
                
                if pinStatus {
                    self.usePinSwitch.isOn = true
                    self.pinAlreadyStatus = true
                }
                else {
                    self.usePinSwitch.isOn = false
                    self.pinAlreadyStatus = false
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func checkForValidPin() {
        let db = Firestore.firestore()
        Utility.showActivityIndicator()
        let userRef = db.collection("UserInfo")
        
        userRef.getDocuments() { (querySnapshot, err) in
                Utility.hideActivityIndicator()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        
                    }
                }
        }
    }
 
    func getUserPinListFromDB() {
        self.getPinList() { userListArray in
            print(userListArray)
            Utility.hideActivityIndicator()
            var isExist : Bool = false
 
            if userListArray.count > 0 {
                for index in 0..<userListArray.count {
                    isExist = false
                    let userData = userListArray.object(at: index) as! NSDictionary
                    let userPin = (userData["userPin"] as! String)
                    if userPin == self.otpStackView.getOTP() {
                        isExist = true
                        break
                    }
                    else {
                        isExist = false
                    }
                }
                //Check if already exist
                if isExist {
                    let vW = Utility.displaySwiftAlert("", "PIN alredy exist!!" , type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                }
                else {
                    self.saveUserOTPInDB(true)
                }
            }
            else {
                
            }
        }
    }
    
    func getPinList(completion: @escaping (_ userListArray : NSMutableArray) -> Void) {
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let bookingRef = db.collection("UserInfo")
        let userArray =  NSMutableArray()
        bookingRef.getDocuments() { (querySnapshot, err) in
                Utility.hideActivityIndicator()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        userArray.add(document.data())
                    }
                }
            completion(userArray)
        }
    }
    
    
    
    
    
    
    @IBAction func clickedForHighlight(_ sender: UIButton) {
        print("Final OTP : ",otpStackView.getOTP())
        otpStackView.setAllFieldColor(isWarningColor: true, color: .yellow)
        
        print(otpStackView.getOTP().count)
        if otpStackView.getOTP().count == 4 {
            
            getUserPinListFromDB()
           // saveUserOTPInDB(true)
            /*
            let vc = storyboard!.instantiateViewController(withIdentifier: "ConfirmPinVC") as! ConfirmPinVC
            vc.previousOTP = otpStackView.getOTP()
            self.navigationController?.pushViewController(vc, animated: true)
 */
        }
        else {
            otpStackView.shake()
        }
    }
    
    @IBAction func onClickSwitchAcn(_ sender : UISwitch){
        if sender.isOn {
            
            pinAlreadyStatus = true
            saveUserOTPInDB(true)
            UserDefaults.standard.set(true, forKey: SharedData.isPinOn)
        }
        else {
            saveUserOTPInDB(false)
            pinAlreadyStatus = false
            UserDefaults.standard.set(false, forKey: SharedData.isPinOn)
        }
        UserDefaults.standard.synchronize()
    }
    
    
    @IBAction func onClickBackAcn(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func saveUserOTPInDB(_ state : Bool) {
        let db = Firestore.firestore()
        
        if !isFromAdmin {
            userID = CurrentUserInfo.userID!
        }
        var userPIN = ""
        
        if state == false {
            let docRef = db.collection("UserInfo").document(userID)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    docRef.updateData([
                        "isPinON":state
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                            let vW = Utility.displaySwiftAlert("", "There is some issue" , type: SwiftAlertType.error.rawValue)
                            SwiftMessages.show(view: vW)
                        } else {
                            let vW = Utility.displaySwiftAlert("", "Saved Successfully!!" , type: SwiftAlertType.success.rawValue)
                            SwiftMessages.show(view: vW)
                            print("Document successfully updated")
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        else {
            if self.lblOldPin.text != "" {
                userPIN = self.lblOldPin.text!
            }
            else if self.otpStackView.getOTP() != "" {
                userPIN = self.otpStackView.getOTP()
            }
            else {
                let vW = Utility.displaySwiftAlert("", "Please choose PIN" , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
           
            if userPIN != "" {
                //userPIN = self.otpStackView.getOTP()
                
                let docRef = db.collection("UserInfo").document(userID)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        docRef.updateData([
                            "userPin": userPIN,
                            "isPinON":state
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                                let vW = Utility.displaySwiftAlert("", "There is some issue" , type: SwiftAlertType.error.rawValue)
                                SwiftMessages.show(view: vW)
                            } else {
                                let vW = Utility.displaySwiftAlert("", "Saved Successfully!!" , type: SwiftAlertType.success.rawValue)
                                SwiftMessages.show(view: vW)
                                print("Document successfully updated")
                                
                                let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                                vc.isFromAdmin = false
                                vc.isAgentEditTicket = false
                                Constant.currentUserFlow = "Normal"
                                self.navigationController?.pushViewController(vc, animated: true)
                                
                            }
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
        
        
        
        Utility.hideActivityIndicator()
    }
}

extension EnterPinVC: OTPDelegate {
    
    func didChangeValidity(isValid: Bool) {
       // testButton.isUserInteractionEnabled = !isValid
    }
    
}
