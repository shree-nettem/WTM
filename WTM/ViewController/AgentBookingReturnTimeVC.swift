//
//  AgentBookingReturnTimeVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 08/12/20.
//

import UIKit
import SwiftMessages

class AgentBookingReturnTimeVC: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var lblTitle : UILabel!
    var returnTimeArray = NSArray()
    var taxiData = NSDictionary()
    var tripStartTime = String()
    var tripReturnTime = String()
    var totalSeatsInTaxi : Int = 0
    var todayStatArray = NSArray()
    var tripStartTimeArray = NSArray()
    
    var selectedDate = Date()
    var selectedAgentData = NSDictionary()
    
    var isAdminTicketBook : Bool = false
    var isStatTimeSort : Bool = true
    
    
    var startAvailableSeats : Int = 0
    var returnAvailableSeats : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(isStatTimeSort)
        
        if isStatTimeSort {
            lblTitle.text = "Time From Miami Beach"
        }
        else {
            lblTitle.text = "Time From BaySide"
        }
        
    }
    
    @IBAction func onClickBackAcn() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    
    //MARK:- UITableView Delegate
   
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
            return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AgentBookingReturnTblCell")! as! AgentBookingReturnTblCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let data = self.returnTimeArray.object(at: indexPath.section) as! NSDictionary
        print(data)
        cell.lblTimeSlot.text = (data["time"] as! String)
        let aleadyBookedSeats =  (data["alreadyBooked"] as! Int)
        
        let availableSeats = totalSeatsInTaxi - aleadyBookedSeats
        cell.lblLeftSeats.text = String("\(availableSeats)")
        return cell
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(CurrentUserInfo.status!)
        print(CurrentUserInfo.name!)
        
        if Constant.currentUserFlow == "Normal" || CurrentUserInfo.status == "Pending" || CurrentUserInfo.status == "Rejected"{
            
         }
         else {
            
            let vc = storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
            let data = self.returnTimeArray.object(at: indexPath.section) as! NSDictionary
            vc.taxiData = taxiData
            vc.tripStartTime = tripStartTime
            vc.isStatTimeSort = isStatTimeSort;
            vc.tripReturnTime = (data["time"] as! String)
            print(taxiData)
            let totalSeats = Int(truncating: taxiData["TotalSeats"] as! NSNumber)
            let alreadyBooked = Int(truncating: data["alreadyBooked"] as! NSNumber)
            
            if totalSeats - alreadyBooked > 0 {
                  // tripStartTime
                 //Convert Date from Hours
                let outStr = dateTimeChangeFormat(str: (data["time"] as! String),
                                                   inDateFormat:  "h:mm a",
                                                   outDateFormat: "HH:mm")
                
                let outStr1 = dateTimeChangeFormat(str: tripStartTime,
                                                  inDateFormat:  "h:mm a",
                                                  outDateFormat: "HH:mm")
                 
                 
                 
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                dateFormatter.timeZone = .current
                let selectedTicketTime = dateFormatter.date(from: outStr)!
                let currentAgentTime = dateFormatter.date(from: outStr1)!

                print(selectedTicketTime)
                print(currentAgentTime)
                
                
                if selectedTicketTime > currentAgentTime {
                    vc.selectedDate = selectedDate
                    vc.tripStartTimeArray = tripStartTimeArray
                    vc.tripReturnTimeArray = returnTimeArray
                    
                    vc.isAdminTicketBook = isAdminTicketBook
                    vc.selectedAgentData = selectedAgentData
                    
                    vc.startAvailableSeats = startAvailableSeats
                    
                    vc.returnAvailableSeats =  Int(truncating: taxiData["TotalSeats"] as! NSNumber) - Int(truncating: data["alreadyBooked"] as! NSNumber)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let vW = Utility.displaySwiftAlert("", "Can't book in past time", type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                }
            }
            else {
                let vW = Utility.displaySwiftAlert("","Can't Book", type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            
            
            

            
         }
       
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
           return self.returnTimeArray.count
    }
    
    func dateTimeChangeFormat(str stringWithDate: String, inDateFormat: String, outDateFormat: String) -> String {
        let inFormatter = DateFormatter()
        inFormatter.timeZone = .current
        inFormatter.locale = Locale(identifier: "en_US_POSIX")
        inFormatter.dateFormat = inDateFormat

        let outFormatter = DateFormatter()
        outFormatter.timeZone = .current
        outFormatter.locale = Locale(identifier: "en_US_POSIX")
        outFormatter.dateFormat = outDateFormat

        let inStr = stringWithDate
        let date = inFormatter.date(from: inStr)!
        
        //Add 5 Min to date for agent
        let earlyDate = Calendar.current.date(
          byAdding: .minute,
          value: 6,
            to: date)! as Date
        print(date)
        print(earlyDate)
        return outFormatter.string(from: earlyDate)
        
        //return outFormatter.string(from: date)
    }
    

}
