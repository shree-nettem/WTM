//
//  LoginVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 29/11/20.
//

import UIKit
import Firebase
import SwiftMessages

class LoginVC: UIViewController {

    
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    
    @IBOutlet weak var otpContainerView: UIView!
    let otpStackView = OTPStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtEmail.setLeftPaddingPoints(15.0)
        txtPassword.setLeftPaddingPoints(15.0)
        
//        txtEmail.text = "admin@gmail.com"
//       // txtEmail.text = "tarun@gmail.com"
//       // txtEmail.text = "check@gmail.com"
//
//
//        txtPassword.text = "123456"
        
        
        if Utility.isKeyPresentInUserDefaults(key: "email") {
            txtEmail.text = UserDefaults.standard.value(forKey: "email") as! String
            txtPassword.text = UserDefaults.standard.value(forKey: "password") as! String
        }
        else {
            txtEmail.text = ""
            txtPassword.text = ""
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        otpContainerView.addSubview(otpStackView)
        otpStackView.delegate = self
        otpStackView.heightAnchor.constraint(equalTo: otpContainerView.heightAnchor).isActive = true
        otpStackView.centerXAnchor.constraint(equalTo: otpContainerView.centerXAnchor).isActive = true
        otpStackView.centerYAnchor.constraint(equalTo: otpContainerView.centerYAnchor).isActive = true
    }
    
    //MARK:- OnClick Action Method
    @IBAction func onClickSignUp(){
        
        if NetworkMonitor.shared.isReachable {
            let vc = storyboard!.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        
        
        
    }
    
    @IBAction func onClickLoginPIN(){
        
        
        if NetworkMonitor.shared.isReachable {
            let vc = storyboard!.instantiateViewController(withIdentifier: "LoginWithPinVC") as! LoginWithPinVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        
       
        
    }
    @IBAction func onClickLogin(){
        
        
        print("Final OTP : ",otpStackView.getOTP())
        otpStackView.setAllFieldColor(isWarningColor: true, color: .yellow)
        if otpStackView.getOTP().count < 4 {
            if txtEmail.text! == ""  {
                let vW = Utility.displaySwiftAlert("", "Please enter email", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else if !Utility.isValidEmail(testStr: txtEmail.text!) {
                let vW = Utility.displaySwiftAlert("", "Please enter valid email", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else if txtPassword.text! == ""  {
                let vW = Utility.displaySwiftAlert("", "Please enter password", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else {
                
                if NetworkMonitor.shared.isReachable {
                    loginUser()
                }
                else {
                    let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                }
                
            }
        }
        else {
            
            if NetworkMonitor.shared.isReachable {
                getUserPinListFromDB()
            }
            else {
                let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            
        }
        
        
        
    }
    @IBAction func onClickForgotPassword(){
        
        if NetworkMonitor.shared.isReachable {
            let vc = storyboard!.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
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
    
    
    func loginUser() {
        Utility.showActivityIndicator()
        Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!) { (user, error) in
            Utility.hideActivityIndicator()
            if let error = error {
                let vW = Utility.displaySwiftAlert("", error.localizedDescription , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
                print(error.localizedDescription)
            }
            else if user != nil {
                let db = Firestore.firestore()
                let userID : String = (Auth.auth().currentUser?.uid)!
                db.collection("UserInfo").whereField("userID", isEqualTo: userID)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                let dict = document.data()
                                _ = CurrentUserInfo(dict: dict as NSDictionary)
                                
                                let status : Bool = ((dict["isPinON"] as! Int) != 0)
                                
                                UserDefaults.standard.set(status, forKey: SharedData.isPinOn)
                                
                                
                                
                                
                                Utility.hideActivityIndicator()
                                if (CurrentUserInfo.userType == "Agent") && (dict["status"] as! String == "Approved"){
                                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                                    vc.isFromAdmin = false
                                    vc.isAgentEditTicket = false
                                    Constant.currentUserFlow = "Agent"
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                                else if (CurrentUserInfo.userType == "Normal") && (dict["status"] as! String == "Approved"){
                                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                                    vc.isFromAdmin = false
                                    vc.isAgentEditTicket = false
                                    Constant.currentUserFlow = "Normal"
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                                else if (CurrentUserInfo.userType == "Agent") && (dict["status"] as! String == "Rejected"){
                                    let vW = Utility.displaySwiftAlert("", "Your application is Rejected." , type: SwiftAlertType.error.rawValue)
                                    SwiftMessages.show(view: vW)
                                }
                                else if (CurrentUserInfo.userType == "Agent") && (dict["status"] as! String == "Pending"){
                                    
                                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                                    vc.isFromAdmin = false
                                    vc.isAgentEditTicket = false
                                    Constant.currentUserFlow = "Normal"
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    
                                   // let vW = Utility.displaySwiftAlert("", "Your application is Pending." , type: SwiftAlertType.error.rawValue)
                                   // SwiftMessages.show(view: vW)
                                }
                                else if CurrentUserInfo.userType == "Admin" {
                                    
                                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                                    vc.isFromAdmin = true
                                    vc.isAgentEditTicket = false
                                    Constant.currentUserFlow = "Admin"
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    
                                    
                                    
                                    
                                }
                                else if CurrentUserInfo.userType == "Check" {
                                    Constant.currentUserFlow = "Check"
                                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "TicketCheckVC") as! TicketCheckVC
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                }
                UserDefaults.standard.setValue(self.txtEmail.text!, forKey: "email")
                UserDefaults.standard.setValue(self.txtPassword.text!, forKey: "password")
                UserDefaults.standard.set(true, forKey: SharedData.firstTime)
                UserDefaults.standard.set(true, forKey: SharedData.isAlreadyLogin)
                UserDefaults.standard.synchronize()
             
               
             
            }
        }
    }

}


extension LoginVC: OTPDelegate {
    
    func didChangeValidity(isValid: Bool) {
       // testButton.isUserInteractionEnabled = !isValid
    }
    
}
