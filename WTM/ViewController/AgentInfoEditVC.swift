//
//  AgentInfoEditVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 10/01/21.
//

import UIKit
import SwiftMessages
import Firebase

class AgentInfoEditVC: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtName : UITextField!
    @IBOutlet weak var txtJoinDate : UITextField!
    @IBOutlet weak var txtPhone : UITextField!
    var agentData = NSDictionary()
    
    let timePicker = UIDatePicker()
    var datePicker : UIDatePicker!
    var selectedTF : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtEmail.setLeftPaddingPoints(15.0)
        txtName.setLeftPaddingPoints(15.0)
        txtJoinDate.setLeftPaddingPoints(15.0)
        txtPhone.setLeftPaddingPoints(15.0)
        
        txtJoinDate.delegate = self
        
        txtEmail.text = (agentData["email"] as! String)
        txtName.text = (agentData["name"] as! String)
        txtJoinDate.text = (agentData["enrollDate"] as! String)
        txtPhone.text = (agentData["phone"] as! String)
        
    }
    
    
    func pickUpDate(_ textField : UITextField){
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.maximumDate = Date()
        
        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        textField.inputView = self.datePicker
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        if selectedTF == txtJoinDate {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "dd MMM, yyyy"
            txtJoinDate.text = dateFormatter1.string(from: datePicker.date)
            txtJoinDate.resignFirstResponder()
        }
    }
    
    @objc func cancelClick() {
        selectedTF.resignFirstResponder()
    }
    
    //MARK:- UITextfield Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTF = textField
        if textField == txtJoinDate {
            self.pickUpDate(txtJoinDate)
        }
    }
    
    @IBAction func onClickBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmit() {
        
        if txtName.text! == "" {
            let vW = Utility.displaySwiftAlert("", "Please enter name", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if txtEmail.text! == "" {
            let vW = Utility.displaySwiftAlert("", "Please enter email", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if !Utility.isValidEmail(testStr: txtEmail.text!) {
            let vW = Utility.displaySwiftAlert("", "Please enter valid email", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if txtJoinDate.text! == "" {
            let vW = Utility.displaySwiftAlert("", "Please enter join date", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else {
            Utility.showActivityIndicator()
            updateAgentInfoInDB()
        }
    }
    
    func updateAgentInfoInDB() {
        
        let db = Firestore.firestore()
        let agentID = (agentData["userID"] as! String)
        //Update Seats
        let docRef = db.collection("UserInfo").document(agentID)

        docRef.getDocument { (document, error) in
            Utility.hideActivityIndicator()
            if let document = document, document.exists {
                let todayData : NSDictionary = document.data()! as NSDictionary
                docRef.updateData([
                    "email": self.txtEmail.text!,
                    "name": self.txtName.text!,
                    "enrollDate": self.txtJoinDate.text!,
                    "phone": self.txtPhone.text!
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                        let vW = Utility.displaySwiftAlert("", "Error Occured" , type: SwiftAlertType.error.rawValue)
                        SwiftMessages.show(view: vW)
                    } else {
                        print("Document successfully updated")
                        let vW = Utility.displaySwiftAlert("", "Information Updated" , type: SwiftAlertType.success.rawValue)
                        SwiftMessages.show(view: vW)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                Utility.hideActivityIndicator()
                print("Document does not exist")
            }
        }
    }
    
    
    

    

}
