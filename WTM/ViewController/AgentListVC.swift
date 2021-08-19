//
//  AgentListVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 27/12/20.
//

import UIKit
import Firebase
import SwiftMessages

class AgentListVC: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var lblNoAgent : UILabel!
    var agentListArray = NSArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUpdatedAgentList()
    }
    
    func getUpdatedAgentList() {
        self.getAgentList() { agentListArray in
            print(agentListArray)
            if agentListArray.count > 0 {
                self.lblNoAgent.isHidden = true
                self.tblView.isHidden = false
                self.agentListArray = agentListArray
                self.tblView.reloadData()
            }
            else {
                self.lblNoAgent.isHidden = false
                self.tblView.isHidden = true
            }
        }
    }
    
    @IBAction func onClickBackAcn() {
        _  = self.navigationController?.popViewController(animated: true)
    }
    
    
    func getAgentList(completion: @escaping (_ agentListArray : NSMutableArray) -> Void) {
        
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        
        let bookingRef = db.collection("UserInfo")
        let agentArray =  NSMutableArray()
        
        bookingRef.getDocuments() { (querySnapshot, err) in
                Utility.hideActivityIndicator()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        
                        let data : NSDictionary = document.data() as NSDictionary
                        if (data["userType"] as! String == "Agent" ) && (data["status"] as! String == "Approved" ){
                            agentArray.add(document.data())
                        }
                    }
                }
            completion(agentArray)
        }
    }
    func deleteAgentFromDB(_ index : Int) {
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let agentData = agentListArray.object(at: index) as! NSDictionary
        let userID = (agentData["userID"] as! String)
        db.collection("UserInfo").document(userID).delete() { err in
            Utility.hideActivityIndicator()
            if let err = err {
                print("Error removing document: \(err)")
                let vW = Utility.displaySwiftAlert("", "There is some error" , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            } else {
                print("Document successfully removed!")
                let vW = Utility.displaySwiftAlert("", "Agent removed successfully!" , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
                self.getUpdatedAgentList()
            }
        }
        
        /*
        let user = Auth.auth().currentUser
        user?.delete { error in
          if let error = error {
            print("Some Error")
          } else {
            // Account deleted.
            print("Account deleted.")
          }
        }
    */
        
        
    }
    func showCancelAlert(_ index : Int) {
        
            let alertController = UIAlertController(title: "WTM", message: "Do you really want to delete!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                UIAlertAction in
                NSLog("OK Pressed")
                self.deleteAgentFromDB(index)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
            return 150
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "AgentListTblCell")! as! AgentListTblCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let data = (agentListArray.object(at: indexPath.section) as! NSDictionary)
        
        cell.lblName.text = String("\("Agent Name: \((data["name"] as! String))")")
            
        cell.lblEmail.text = String("\("Email: \((data["email"] as! String))")")
           
        cell.lblEnrollDate.text = String("\("Joining Date: \((data["enrollDate"] as! String))")")
        
        cell.lblAgentPIN.text = String("\("PIN: \((data["userPin"] as! String))")")
            
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
            return agentListArray.count
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
      
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        let edit = UIContextualAction(style: .normal, title:  "Edit", handler: { [self] (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            success(true)
            let data = agentListArray.object(at: indexPath.section) as! NSDictionary
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentInfoEditVC") as! AgentInfoEditVC
            vc.agentData = data
            self.navigationController?.pushViewController(vc, animated: true)
        })
        edit.backgroundColor = .orange
        
        let setPin = UIContextualAction(style: .normal, title:  "Pin", handler: { [self] (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            success(true)
            let data = agentListArray.object(at: indexPath.section) as! NSDictionary
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "EnterPinVC") as! EnterPinVC
            vc.userID = (data["userID"] as! String)
            vc.isFromAdmin = true
            vc.isFromRegister = false
            self.navigationController?.pushViewController(vc, animated: true)
        })
        setPin.backgroundColor = .blue
        
        let delete = UIContextualAction(style: .normal, title:  "Delete", handler: { [self] (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            success(true)
            self.showCancelAlert(indexPath.section)
        })
        delete.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [ edit, setPin, delete ])
    }

}
