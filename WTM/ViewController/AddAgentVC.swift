//
//  AddAgentVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 26/01/21.
//

import UIKit
import SwiftMessages
import Firebase

class AddAgentVC: UIViewController, OTPDelegate {
    
    
    
    

    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtName : UITextField!
    @IBOutlet weak var txtPhone : UITextField!
    @IBOutlet weak var otpContainerView: UIView!
    let otpStackView = OTPStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        otpContainerView.addSubview(otpStackView)
        otpStackView.delegate = self
        otpStackView.heightAnchor.constraint(equalTo: otpContainerView.heightAnchor).isActive = true
        otpStackView.centerXAnchor.constraint(equalTo: otpContainerView.centerXAnchor).isActive = true
        otpStackView.centerYAnchor.constraint(equalTo: otpContainerView.centerYAnchor).isActive = true
        
        txtEmail.setLeftPaddingPoints(15.0)
        txtName.setLeftPaddingPoints(15.0)
        txtPhone.setLeftPaddingPoints(15.0)
    }
    
    //MARK:- OnClick Action Method
    @IBAction func onClickCross(){
            _ = self.navigationController?.popViewController(animated: true)
    }
        
    @IBAction func onClickSubmit(){
            
            if txtName.text! == ""  {
                let vW = Utility.displaySwiftAlert("", "Please enter name", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else if txtPhone.text! == ""  {
                let vW = Utility.displaySwiftAlert("", "Please enter phone number", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else if txtEmail.text! == ""  {
                let vW = Utility.displaySwiftAlert("", "Please enter email", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else if !Utility.isValidEmail(testStr: txtEmail.text!) {
                let vW = Utility.displaySwiftAlert("", "Please enter valid email", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else if otpStackView.getOTP().count < 4 {
                let vW = Utility.displaySwiftAlert("", "Enter PIN", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            else {
                print("Final OTP : ",otpStackView.getOTP())
                getUserPinListFromDB()
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
            Utility.hideActivityIndicator()
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
                if isExist {
                    let vW = Utility.displaySwiftAlert("", "Choose different PIN" , type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                }
                else {
                    self.createUser()
                }
            }
            else {
                self.createUser()
            }
        }
     }
    
    func createUser()  {
            Utility.showActivityIndicator()
            Auth.auth().createUser(withEmail: txtEmail.text!, password: "123456") { (user, error) in
                Utility.hideActivityIndicator()
                if let error = error {
                    let vW = Utility.displaySwiftAlert("", error.localizedDescription , type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                    print(error.localizedDescription)
                }
                else if let user = user {
                    print(user)
                self.saveUserToDB()
                }
            }
    }
        
        func saveUserToDB() {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "dd MMM, yyyy"
            let enrollDate = dateFormatter.string(from: Date())
            let userID : String = (Auth.auth().currentUser?.uid)!
            print(userID)
            let db = Firestore.firestore()
            Constant.currentUserID = userID
            
            db.collection("UserInfo").document(userID).setData([
                "userID": userID,
                "email": txtEmail.text!,
                "name": txtName.text!,
                "enrollDate":enrollDate,
                "fcmToken":"",
                "userType":"Agent",
                "status":"Approved",
                "userPin":self.otpStackView.getOTP(),
                "phone":txtPhone.text!
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            let dataDict : NSDictionary = ["userID":userID,"email": txtEmail.text!,"name": txtName.text!,"enrollDate":enrollDate]
            
            _ = CurrentUserInfo(dict: dataDict as NSDictionary)
            
            Utility.hideActivityIndicator()
            let vW = Utility.displaySwiftAlert("", NSLocalizedString("Agent created successfully", comment: "")  , type: SwiftAlertType.success.rawValue)
            SwiftMessages.show(view: vW)
            UserDefaults.standard.set(true, forKey: SharedData.firstTime)
            UserDefaults.standard.setValue(self.txtEmail.text!, forKey: "email")
            UserDefaults.standard.setValue("123456", forKey: "password")
            UserDefaults.standard.set(true, forKey: SharedData.isAlreadyLogin)
            UserDefaults.standard.synchronize()
            
           // let pushManager = PushNotificationManager(userID: userID)
           // pushManager.registerForPushNotifications()
            
            let vc = storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    
    func didChangeValidity(isValid: Bool) {
        print("didChangeValidity")
    }
    

}
