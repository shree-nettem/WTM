//
//  RegisterVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 30/11/20.
//

import UIKit
import Firebase
import SwiftMessages

class RegisterVC: UIViewController , OTPDelegate {
    
    

    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtName : UITextField!
    @IBOutlet weak var txtPhone : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtEmail.setLeftPaddingPoints(15.0)
        txtName.setLeftPaddingPoints(15.0)
        txtPhone.setLeftPaddingPoints(15.0)
        txtPassword.setLeftPaddingPoints(15.0)
    }
    
    func didChangeValidity(isValid: Bool) {
        print("didChangeValidity")
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
        else if txtPassword.text! == ""  {
            let vW = Utility.displaySwiftAlert("", "Please choose password", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if !Utility.isValidEmail(testStr: txtEmail.text!) {
            let vW = Utility.displaySwiftAlert("", "Please enter valid email", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else {
            getUserPhoneListFromDB()
        }
    }
    
    func createUser()  {
        Utility.showActivityIndicator()
        Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { (user, error) in
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
    
    func getPhoneList(completion: @escaping (_ userListArray : NSMutableArray) -> Void) {
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

    func getUserPhoneListFromDB() {
        var isExist : Bool = false
        self.getPhoneList() { userListArray in
            print(userListArray)
            Utility.hideActivityIndicator()
            if userListArray.count > 0 {
                for index in 0..<userListArray.count {
                    isExist = false
                    let userData = userListArray.object(at: index) as! NSDictionary
                    let userPhone = (userData["phone"] as! String)
                    if userPhone == self.txtPhone.text! {
                        isExist = true
                        break
                    }
                    else {
                        //
                        isExist = false
                    }
                }
                if !isExist {
                    
                    if NetworkMonitor.shared.isReachable {
                        self.createUser()
                    }
                    else {
                        let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
                        SwiftMessages.show(view: vW)
                    }
                }
                else {
                    let vW = Utility.displaySwiftAlert("", "Phone number already exist" , type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                }
            }
            else {
                if NetworkMonitor.shared.isReachable {
                    self.createUser()
                }
                else {
                    let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                }
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
        
       // "userType":"Normal",
       // "status":"Approved",
        
        db.collection("UserInfo").document(userID).setData([
            "userID": userID,
            "email": txtEmail.text!,
            "name": txtName.text!,
            "enrollDate":enrollDate,
            "fcmToken":"",
            "userType":"Agent",
            "status":"Pending",
            "userPin":"",
            "phone":txtPhone.text!,
            "password":txtPassword.text!,
            "isPinON" : false
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
      //  let vW = Utility.displaySwiftAlert("", NSLocalizedString("User created successfully", comment: "")  , type: SwiftAlertType.success.rawValue)
      //  SwiftMessages.show(view: vW)
        
        
        UserDefaults.standard.set(true, forKey: SharedData.firstTime)
        UserDefaults.standard.setValue(self.txtEmail.text!, forKey: "email")
        UserDefaults.standard.setValue(txtPassword.text!, forKey: "password")
        UserDefaults.standard.set(true, forKey: SharedData.isAlreadyLogin)
        UserDefaults.standard.synchronize()
        
       // let pushManager = PushNotificationManager(userID: userID)
       // pushManager.registerForPushNotifications()
        
        
        Constant.currentUserFlow = "Normal"
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "EnterPinVC") as! EnterPinVC
        vc.isFromRegister = true
        self.navigationController?.pushViewController(vc, animated: true)
        //let vc = storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
       // self.navigationController?.pushViewController(vc, animated: true)
        
     
        
    }
    
    
    

}
