//
//  LoadingUserVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 24/12/20.
//

import UIKit
import Firebase
import SwiftMessages

class LoadingUserVC: UIViewController {

    var data = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // Utility.showActivityIndicator()
       // loginUser()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        print(CurrentUserInfo.userType!)
        if CurrentUserInfo.userType == "Agent" {
            Constant.currentUserFlow = "Agent"
            let  initialViewController : AgentDashboardVC = storyboard.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
            initialViewController.isFromAdmin = false
            initialViewController.isAgentEditTicket = false
            self.navigationController?.pushViewController(initialViewController, animated: true)
        }
        else if CurrentUserInfo.userType == "Admin" {
            Constant.currentUserFlow = "Admin"
            
            let  initialViewController : AgentDashboardVC = storyboard.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
            initialViewController.isFromAdmin = true
            initialViewController.isAgentEditTicket = false
            self.navigationController?.pushViewController(initialViewController, animated: true)
        }
        else if CurrentUserInfo.userType == "Normal" {
            Constant.currentUserFlow = "Normal"
            let  initialViewController : AgentDashboardVC = storyboard.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
            initialViewController.isFromAdmin = true
            initialViewController.isAgentEditTicket = false
            self.navigationController?.pushViewController(initialViewController, animated: true)
        }
        else if CurrentUserInfo.userType == "Check" {
            Constant.currentUserFlow = "Check"
            let initialViewController : TicketCheckVC = storyboard.instantiateViewController(withIdentifier: "TicketCheckVC") as! TicketCheckVC
            self.navigationController?.pushViewController(initialViewController, animated: true)
        }
        
    }
    

    /*
    func loginUser() {
        
        let email : String = (data["email"] as! String)
        let password : String = (data["password"] as! String)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                Utility.hideActivityIndicator()
                let vW = Utility.displaySwiftAlert("", error.localizedDescription , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
                print(error.localizedDescription)
            }
            else if user != nil {
                let db = Firestore.firestore()
                let userID : String = (Auth.auth().currentUser?.uid)!
                db.collection("UserInfo").whereField("userID", isEqualTo: userID)
                    .getDocuments() { (querySnapshot, err) in
                        
                        Utility.hideActivityIndicator()
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                let dict = document.data()
                                _ = CurrentUserInfo(dict: dict as NSDictionary)
                                Utility.hideActivityIndicator()
                                
                            }
                        }
                }
                
                UserDefaults.standard.set(true, forKey: SharedData.firstTime)
                UserDefaults.standard.set(true, forKey: SharedData.isAlreadyLogin)
                UserDefaults.standard.synchronize()
             
               
             
            }
        }
    }
 */

}
