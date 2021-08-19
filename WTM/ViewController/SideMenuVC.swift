//
//  SideMenuVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 22/12/20.
//

import UIKit

class SideMenuVC: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var lblVersion : UILabel!
    var menuArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if Constant.currentUserFlow == "Agent" {
            menuArray = ["Edit Ticket","Ticket List","Set Pin"]
        }
        else if Constant.currentUserFlow == "Admin" {
           
            menuArray = ["Ticket List","Book Ticket","Add New Taxi", "Update Taxi Details","Agents Request","Agent List","Delete Taxi","Past Ticket","Add New Agent","Invite","Set Pin"]
            
         //   menuArray = ["Ticket List","Book Ticket","Add New Taxi", "Update Taxi Details","Agents Request","Agent List","Delete Taxi","Add New Agent","Invite","Set Pin"]
        }
        else if Constant.currentUserFlow == "Normal" {
            menuArray = ["Set Pin"]
        }
        else if Constant.currentUserFlow == "Check" {
            
        }
        
        if CurrentUserInfo.status == "Pending" {
            menuArray = ["Set Pin"]
        }
        
        if CurrentUserInfo.status == "Rejected" {
            menuArray = ["Set Pin"]
        }
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        lblVersion.text = String("\("App Version: ")\(appVersion!)")
        
    }
    
    func shareAppURL() {
        let textToShare = "Water Taxi Miami"
        let myWebsite = NSURL(string: "https://itunes.apple.com/app/id1545116369")
        let objectsToShare = [textToShare,myWebsite!] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        //New Excluded Activities Code
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
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
            return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "SideMenuTblCell")! as! SideMenuTblCell
        
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.lblTitle.text = (menuArray.object(at: indexPath.section) as! String)
        
            
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            if Constant.currentUserFlow == "Agent" {
                let vc = storyboard!.instantiateViewController(withIdentifier: "AgentEditTicketVC") as! AgentEditTicketVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else  if Constant.currentUserFlow == "Normal" {
                let vc = storyboard!.instantiateViewController(withIdentifier: "EnterPinVC") as! EnterPinVC
                vc.isFromAdmin = false
                vc.isFromRegister = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                vc.isFromAdmin = true
                vc.isAgentEditTicket = false
                vc.isAgentTicketList = false
                Constant.currentUserFlow = "Admin"
                self.navigationController?.pushViewController(vc, animated: true)
                //self.dismiss(animated: true, completion: nil)
            }
            break
        case 1:
            if Constant.currentUserFlow == "Agent" {
                let vc = storyboard!.instantiateViewController(withIdentifier: "AgentEditTicketVC") as! AgentEditTicketVC
                self.navigationController?.pushViewController(vc, animated: true)
                /*
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                vc.isFromAdmin = false
                vc.isAgentEditTicket = true
                vc.isAgentTicketList = true
                Constant.currentUserFlow = "Agent"
                self.navigationController?.pushViewController(vc, animated: true)
 */
            }
            else {
                let vc = storyboard!.instantiateViewController(withIdentifier: "AdminBookTicketVC") as! AdminBookTicketVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 2:
            
            if Constant.currentUserFlow == "Agent" {
                let vc = storyboard!.instantiateViewController(withIdentifier: "EnterPinVC") as! EnterPinVC
                vc.isFromAdmin = false
                vc.isFromRegister = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = storyboard!.instantiateViewController(withIdentifier: "AdminAddTaxiVC") as! AdminAddTaxiVC
                vc.isEdit = false
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            break
        case 3:
            let vc = storyboard!.instantiateViewController(withIdentifier: "AdminAllTaxiListVC") as! AdminAllTaxiListVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
        case 4:
            
            let vc = storyboard!.instantiateViewController(withIdentifier: "AgentRequestVC") as! AgentRequestVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
        case 5:
            //Agent List
            let vc = storyboard!.instantiateViewController(withIdentifier: "AgentListVC") as! AgentListVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
        case 6:
            //Agent List
            let vc = storyboard!.instantiateViewController(withIdentifier: "DeleteTaxiVC") as! DeleteTaxiVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
        
        case 7:
            
            //Past Ticket List
           let vc = self.storyboard!.instantiateViewController(withIdentifier: "PastTicketListVC") as! PastTicketListVC
           self.navigationController?.pushViewController(vc, animated: true)
            
            
            
            break
        case 8:
            
            let vc = storyboard!.instantiateViewController(withIdentifier: "AddAgentVC") as! AddAgentVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            
            break
        case 9:
            //Invite
            shareAppURL()
            break
        case 10:
            let vc = storyboard!.instantiateViewController(withIdentifier: "EnterPinVC") as! EnterPinVC
            vc.isFromAdmin = true
            vc.isFromRegister = false
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuArray.count
    }

}
