//
//  AgentRequestVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 27/12/20.
//

import UIKit
import Firebase
import SwiftMessages

class AgentRequestVC: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var lblNoAgent : UILabel!
    var agentListArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUpdatedData()
    }
    
    @IBAction func onClickBackAcn() {
        _  = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickRejectAcn(_ sender : UIButton) {
        let tag = sender.tag
        let data = (agentListArray.object(at: tag) as! NSDictionary)
        let ageneID = (data["userID"] as! String)
        
        let db = Firestore.firestore()
        let docRef = db.collection("UserInfo").document(ageneID)
         docRef.updateData([
             "status":  "Rejected"
         ]) { err in
             Utility.hideActivityIndicator()
             if let err = err {
                 print("Error updating document: \(err)")
                 let vW = Utility.displaySwiftAlert("", "There is some error.", type: SwiftAlertType.error.rawValue)
                 SwiftMessages.show(view: vW)
             } else {
                 print("Document successfully updated")
                 let vW = Utility.displaySwiftAlert("", "Status Updated Successfully!", type: SwiftAlertType.success.rawValue)
                 SwiftMessages.show(view: vW)
                 self.getUpdatedData()
             }
         }
       
    }
    
    @IBAction func onClickApproveAcn(_ sender : UIButton) {
        let tag = sender.tag
        let data = (agentListArray.object(at: tag) as! NSDictionary)
        let ageneID = (data["userID"] as! String)
        let db = Firestore.firestore()
        let docRef = db.collection("UserInfo").document(ageneID)
         docRef.updateData([
             "status":  "Approved"
         ]) { err in
             Utility.hideActivityIndicator()
             if let err = err {
                 print("Error updating document: \(err)")
                 let vW = Utility.displaySwiftAlert("", "There is some error.", type: SwiftAlertType.error.rawValue)
                 SwiftMessages.show(view: vW)
             } else {
                 print("Document successfully updated")
                 let vW = Utility.displaySwiftAlert("", "Status Updated Successfully!", type: SwiftAlertType.success.rawValue)
                 SwiftMessages.show(view: vW)
                 self.getUpdatedData()
             }
         }
    }
    
    func getUpdatedData() {
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
                        
                        if (data["userType"] as! String == "Agent" ) && (data["status"] as! String == "Pending" ) {
                            
                            if (data["status"] as! String == "Pending" ) {
                                
                            }
                            
                            agentArray.add(document.data())
                        }
                    }
                }
            completion(agentArray)
        }
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
            return 225
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "AgentRequestTblCell")! as! AgentRequestTblCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let data = (agentListArray.object(at: indexPath.section) as! NSDictionary)
        
        cell.lblName.text = String("\("Agent Name: \((data["name"] as! String))")")
            
        cell.lblEmail.text = String("\("Email: \((data["email"] as! String))")")
           
        cell.lblEnrollDate.text = String("\("Request Date: \((data["enrollDate"] as! String))")")
        cell.btnApprove.tag = indexPath.section
        cell.btnReject.tag = indexPath.section
            
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
   

}
