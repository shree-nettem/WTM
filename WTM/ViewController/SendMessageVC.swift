//
//  SendMessageVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 11/01/21.
//

import UIKit
import SwiftMessages
import Firebase

class SendMessageVC: UIViewController , UITextViewDelegate{

    @IBOutlet weak var txtMessage : UITextView!
    @IBOutlet weak var baseViewHeight : NSLayoutConstraint!
    var messageData = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtMessage.delegate = self
        
        if messageData.count > 0 {
            txtMessage.text = (messageData["message"] as! String)
            txtMessage.textColor = UIColor.black
        }
        else {
            txtMessage.text = "Enter Message here..."
            txtMessage.textColor = UIColor.lightGray
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        baseViewHeight.constant = 400
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Message here..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func onClickBackAcn(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmitAcn(){
        
        if txtMessage.text == "" || txtMessage.text == "Enter Message here..." {
            let vW = Utility.displaySwiftAlert("", "Please enter message" , type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else {
            addMessageToDB()
        }
        
    }

    func addMessageToDB() {
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let todayDate = Utility.getTodayDateString()
        
        let timestamp = NSDate().timeIntervalSince1970
        let intVal : Int = Int(timestamp)
        
        if messageData.count > 0 {
            let messageID : String = (messageData["messageID"] as! String)
            let docRef = db.collection("adminMessage").document(messageID)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    docRef.updateData([
                        "message" : self.txtMessage.text!
                    ]) { err in
                        Utility.hideActivityIndicator()
                        if let err = err {
                            print("Error updating document: \(err)")
                            let vW = Utility.displaySwiftAlert("", "There is some error" , type: SwiftAlertType.error.rawValue)
                            SwiftMessages.show(view: vW)
                        } else {
                            print("Document successfully updated")
                            let vW = Utility.displaySwiftAlert("", "Message Updated Successfully" , type: SwiftAlertType.success.rawValue)
                            SwiftMessages.show(view: vW)
                        }
                    }
                }
            }
        }
        else {
            db.collection("adminMessage").document(String("\(intVal)")).setData([
                "messageDate": todayDate,
                "message" : self.txtMessage.text!,
                "messageID":String("\(intVal)"),
            ]) { err in
                Utility.hideActivityIndicator()
                if let err = err {
                    print("Error adding document: \(err)")
                    let vW = Utility.displaySwiftAlert("", "There is some error" , type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                } else {
                    let vW = Utility.displaySwiftAlert("", "Message Sent Succesfully" , type: SwiftAlertType.success.rawValue)
                    SwiftMessages.show(view: vW)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    
    
    
    
    

}
