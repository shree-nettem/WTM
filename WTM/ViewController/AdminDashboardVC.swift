//
//  AdminDashboardVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 01/12/20.
//

import UIKit

class AdminDashboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnDate : UIButton!
    @IBOutlet weak var listTblView : UITableView!
    var ticketListArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        UserDefaults.standard.set(true, forKey: SharedData.isAlreadyLogin)
        UserDefaults.standard.synchronize()
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
            return 200
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AdminDashboardTblCell")! as! AdminDashboardTblCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
           return 5
    }


}
