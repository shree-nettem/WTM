//
//  TicketCheckVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 13/12/20.
//

import UIKit


class TicketCheckVC: UIViewController {

        
    var lblClockTime : UILabel!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        
    }
    
    @IBAction func onClickScan() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "TicketScanVC") as! TicketScanVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickLogoutAcn(_ sender : UIButton){
        
        UserDefaults.standard.set(false, forKey: SharedData.isAlreadyLogin)
        UserDefaults.standard.synchronize()
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
   
    

    

}
