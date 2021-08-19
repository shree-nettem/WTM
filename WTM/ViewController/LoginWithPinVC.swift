//
//  LoginWithPinVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 16/01/21.
//

import UIKit
import Firebase
import SwiftMessages

class LoginWithPinVC: UIViewController {

    @IBOutlet weak var otpContainerView: UIView!
    let otpStackView = OTPStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        otpContainerView.addSubview(otpStackView)
        otpStackView.delegate = self
        otpStackView.heightAnchor.constraint(equalTo: otpContainerView.heightAnchor).isActive = true
        otpStackView.centerXAnchor.constraint(equalTo: otpContainerView.centerXAnchor).isActive = true
        otpStackView.centerYAnchor.constraint(equalTo: otpContainerView.centerYAnchor).isActive = true
    }
    
    @IBAction func onClickForgotPassword(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickSignUp(){
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func onClickLoginEmail(){
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    @IBAction func clickedSignIn(_ sender: UIButton) {
        print("Final OTP : ",otpStackView.getOTP())
        otpStackView.setAllFieldColor(isWarningColor: true, color: .yellow)
        //let userPin : String = UserDefaults.standard.value(forKey: "userPin") as! String
        
        if otpStackView.getOTP().count < 4 {
            otpStackView.shake()
        }
        else {
            getUserPinListFromDB()
            /*
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoadingUserVC") as! LoadingUserVC
            self.navigationController?.pushViewController(vc, animated: true)
           */
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

    func getUserPinListFromDB() {
        var isExist : Bool = false
        self.getPinList() { userListArray in
            print(userListArray)
            Utility.hideActivityIndicator()
            if userListArray.count > 0 {
                for index in 0..<userListArray.count {
                    isExist = false
                    let userData = userListArray.object(at: index) as! NSDictionary
                    let userPin = (userData["userPin"] as! String)
                    if userPin == self.otpStackView.getOTP() {
                        isExist = true
                        
                        let userStatus = (userData["status"] as! String)
                        
                        if userStatus == "Approved" {
                            Constant.currentUserFlow = "Agent"
                            _ = CurrentUserInfo.init(dict: userData)
                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoadingUserVC") as! LoadingUserVC
                            vc.data = userData
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        else {
                            _ = CurrentUserInfo.init(dict: userData)
                            Constant.currentUserFlow = "Normal"
                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoadingUserVC") as! LoadingUserVC
                            vc.data = userData
                            self.navigationController?.pushViewController(vc, animated: true)
                           // self.navigationController?.present(Utility.showAlertWithMessage(title: "WTM", message: "Your profile status is pending.Please contact Admin for further information.", buttonTitle: "Okay"), animated: true, completion: nil)
                        }
                        break
                    }
                    else {
                        //
                        isExist = false
                    }
                }
                
                if !isExist {
                    let vW = Utility.displaySwiftAlert("", "No User exist!!" , type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                }
            }
            else {
                let vW = Utility.displaySwiftAlert("", "No User exist!!" , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
        }
     }
    
}


extension LoginWithPinVC: OTPDelegate {
    
    func didChangeValidity(isValid: Bool) {
       // testButton.isUserInteractionEnabled = !isValid
    }
    
}
