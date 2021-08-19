//
//  ViewMessageVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 11/01/21.
//

import UIKit
import Firebase

class ViewMessageVC: UIViewController {

    @IBOutlet weak var txtMessage : UITextView!
    @IBOutlet weak var lblNoMessage : UILabel!
    var messageData = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if messageData.count > 0 {
            self.txtMessage.text = (messageData["message"] as! String)
        }
        else {
            self.txtMessage.text = "No Message for the day!!"
        }
        
        
    }
    
    
    @IBAction func onClickBackAcn(){
        self.navigationController?.popViewController(animated: true)
    }

    
    
    
    

}
