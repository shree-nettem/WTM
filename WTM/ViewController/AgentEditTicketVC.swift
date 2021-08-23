//
//  AgentEditTicketVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 02/01/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SideMenu
import FSCalendar
import SwiftMessages

class AgentEditTicketVC: UIViewController , UITableViewDelegate, UITableViewDataSource ,FSCalendarDelegate, FSCalendarDataSource {

    
    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var menuView : UIView!
    var hiddenSections = Set<Int>()
    var ticketListArray = NSMutableArray()
    var taxiListArray = NSMutableArray()
    var dayOfWeek : Int = -1
    var timmingList = NSMutableArray()
    var tempTimmeList = NSMutableArray()
    var tempReturnTimeList = NSMutableArray()
    var todayStatArray = NSMutableArray()
    @IBOutlet weak var lblNoTicket : UILabel!
    
    @IBOutlet weak var calendar: FSCalendar!
    var selectedDate : Date!
    @IBOutlet weak var calendarHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var btnTodayDate : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hiddenSections = [1]
        
        
        //Get Today Day Of Week   // 1 = Sunday, 2 = Monday, etc.
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        dayOfWeek = calendar.component(.weekday, from: today)
        print(dayOfWeek)
        
        
        selectedDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        btnTodayDate.setTitle(dateFormatter.string(from: Date()), for: .normal)
        getUpdatedTicketListFromDB()
        
        
        
        
        
        
    }
    
    @IBAction func onClickBackAcn() {
        _  = self.navigationController?.popViewController(animated: true)
    }
    
    func getUpdatedTicketListFromDB()  {
        
        
        //Calender
        calendar.dataSource = self
        calendar.delegate = self
        calendar.firstWeekday = 1
        calendar.allowsSelection = true
        calendar.appearance.titleWeekendColor = #colorLiteral(red: 0.06893683225, green: 0.2285976112, blue: 0.6367123723, alpha: 1)
        calendar.allowsMultipleSelection = false
        calendar.isHidden = true
        
        self.getTicketList() { ticketListArray in
            print(ticketListArray)
            if ticketListArray.count > 0 {
                self.lblNoTicket.isHidden = true
                self.tblView.isHidden = false
                
                self.ticketListArray = ticketListArray
                self.tblView.reloadData()
            }
            else {
                self.lblNoTicket.isHidden = false
                self.tblView.isHidden = true
            }
        }
    }
    
    //MARK:- OnClick Action Method
    @IBAction func onClickTodayDateAcn(_ sender : UIButton){
        calendar.isHidden = false
        
    }
    
    //MARK:- Calender Methods
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    fileprivate lazy var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        return formatter
    
    }()
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
       
        print(date)
        calendar.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        btnTodayDate.setTitle(dateFormatter.string(from: date), for: .normal)
        selectedDate = date
        getUpdatedTicketListFromDB()
        //Get Completed List
        
        
    }
    
    
    
    func getTicketList(completion: @escaping (_ ticketListArray : NSMutableArray) -> Void) {
        
        
        var setValues:Set<String> = []
        
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd/MM/YYYY"
        dateFormatter.dateFormat = "ddMMMYYYY"
        let selectedDateVal = dateFormatter.string(from:selectedDate)
        
        let todayDate = Utility.getTodayDateString()
        
//        let bookingRef =   db.collection("bookings").whereField("bookingDate", isEqualTo: selectedDateVal).whereField("agentName", isEqualTo: CurrentUserInfo.name!).order(by: "bookingDateTimeStamp")
        
        let bookingRef =  db.collection("bookings")
        
        let totalBookings:NSMutableArray = []
        let totalAgentBookings:NSMutableArray = []
        
        let ticketArray =  NSMutableArray()
        bookingRef.getDocuments() { (querySnapshot, err) in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            
                            if !data.isEmpty {
                            for (_,value) in data {
                                let bookingData = value as? Dictionary<String,Any>
                                totalBookings.add(bookingData ?? [:])
                            }
                            }
                            }
                            for i in 0..<totalBookings.count {
                                
                                let eData = totalBookings[i] as? Dictionary<String,Any>
                                
                                if eData?["agentName"] as? String == CurrentUserInfo.name {
                                    totalAgentBookings.add(eData ?? [:])
                                    if eData?["bookingDate"] as? String == selectedDateVal && eData?["status"] as? String != "Cancelled" {
                                        
                                        if ticketArray.count > 0 {
                                            _ = setValues.filter{ (element)  in
                                                
                                                let txtId = eData?["ticketID"] as? String ?? ""
                                               if setValues.contains(txtId) {
                                                print("data exists")
                                                    return false
                                               } else {
                                                setValues.insert(txtId)
                                                ticketArray.add(eData ?? [:])
                                                return true
                                               }
                                            }
                                        } else {
                                            let txtId = eData?["ticketID"] as? String ?? ""
                                            setValues.insert(txtId)
                                            ticketArray.add(eData ?? [:])
                                        }
                                        
                                        
                                        
                                        
//                                        ticketArray.add(eData ?? [:])
                                    }
                                }
                            }

                    }
                completion(ticketArray)
            }
    }
    
    func getTodayStatData(completion: @escaping (_ statArray : NSMutableArray) -> Void) {
        let db = Firestore.firestore()
        Utility.showActivityIndicator()
        let bookingRef = db.collection("todayStat")
        let statArray =  NSMutableArray()
        
        bookingRef.getDocuments() { (querySnapshot, err) in
                Utility.hideActivityIndicator()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        statArray.add(document.data())
                    }
                }
            completion(statArray)
        }
    }
    
    //MARK:- OnClick Action Method
    @IBAction func onClickBookingAcn(_ sender : UIButton){
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func onClickSideMenuAcn(_ sender : UIButton){
        let menu = storyboard!.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuNavigationController
        self.present(menu, animated: true, completion: nil)
    }
    @IBAction func onClickLogoutAcn(_ sender : UIButton){
        
        UserDefaults.standard.set(false, forKey: SharedData.isAlreadyLogin)
        UserDefaults.standard.synchronize()
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    
    
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
        let str = String("\("Comment: \((data["comment"] as! String))")")
        let height = str.height(withConstrainedWidth: self.view.frame.width - 80, font: UIFont(name: "Montserrat", size: 17.0)!)
        return 520 + height
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AdminTicketListCell")! as! AdminTicketListCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
        
        cell.lblAgentName.text = String("\("Agent Name: \((data["agentName"] as! String))")")
        cell.lblBookingName.text = String("\("Booking Name: \((data["customerName"] as! String))")")
        cell.lblTripDate.text = String("\("Booking Date: \((data["bookingDate"] as! String))")")
            
        let totalAdults : Int = Int(data["adult"] as! String)!
        let totalMinor : Int =  Int(data["minor"] as! String)!
        let totalPassengers : Int = totalAdults +  totalMinor
        cell.lblPassengers.text = String("\("Total Passengers: \(totalPassengers)")")
        cell.lblAdults.text = String("\("Adults: \(totalAdults)")\(" Minor: \(totalMinor)")")
        cell.lblStartTime.text = String("\("Start Time: \((data["tripStartTime"] as! String))")")
        cell.lblReturnTime.text = String("\("Return Time: \((data["tripReturnTime"] as! String))")")
        cell.lblComment.text =  String("\("Comment: \((data["comment"] as! String))")")
        cell.lblTicketID.text =  String("\("TicketID: \((data["ticketID"] as! String))")")
        cell.lblStatus.text =  String("\("Status: \((data["status"] as! String))")")
        
        cell.lblStartDepartureStatus.text =  String("\("Start Departure: \((data["startDepartureStatus"] as? String) ?? "Pending" )")")
        cell.lblReturnDepartureStatus.text =  String("\("Return Departure: \((data["returnDepartureStatus"] as? String) ?? "Pending" )")")
        
        let departureSide = (data["ticketDepartureSide"] as? String) ?? "-"
        
        if departureSide == "-" {
            cell.lblDeparture.text =  "Departure: - "
        }
        else {
            cell.lblDeparture.text =  String("\("Departure: \((data["ticketDepartureSide"] as! String))")")
        }
        cell.lblComment.sizeToFit()
        //Start Departure Side
        let startDepartingSide = (data["startDeparting"] as? Bool) ?? true
        
        if startDepartingSide {
            cell.lblStartTime.text = String("\("Departing Bayside Marketplace: \((data["tripStartTime"] as! String))")")
            cell.lblReturnTime.text = String("\("Departing Miami Beach Marina: \((data["tripReturnTime"] as! String))")")
        }
        else {
            cell.lblStartTime.text = String("\("Departing Miami Beach Marina: \((data["tripStartTime"] as! String))")")
            cell.lblReturnTime.text = String("\("Departing Bayside Marketplace: \((data["tripReturnTime"] as! String))")")
        }
        
        //Trip Type
        let tripType = (data["isRoundTrip"] as? Bool) ?? true
        if tripType {
            cell.lblTripType.text = String("\("Trip Type: Two Way")")
        }
        else {
            cell.lblTripType.text = String("\("Trip Type: One Way")")
        }
        
        cell.lblSqaureCode.text = String("\("Square Code: \((data["squareCode"] as? String) ?? "-")")")
        
        return cell
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           
            return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
           return self.ticketListArray.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
      if editingStyle == .delete {
            print("Deleted")
            self.cancelBookedTicket(indexPath.section)
      }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
        print(data)
        let bookingStatus = (data["status"] as! String)
        let startDepartureStatus = (data["startDepartureStatus"] as! String)
        let returnDepartureStatus = (data["returnDepartureStatus"] as! String)
        if bookingStatus == "Pending"  && startDepartureStatus == "Pending" && returnDepartureStatus == "Pending" {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
//        let cancel = UIContextualAction(style: .normal, title:  "Cancel", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
//
//            self.showCancelAlert(indexPath.section)
//            success(true)
//        })
//        cancel.backgroundColor = .red
        /*
        let edit = UIContextualAction(style: .normal, title:  "Edit", handler: { [self] (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            success(true)
            
            let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
            
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
            vc.isTicketEdit = true
            vc.ticketData = data
            
            
            vc.selectedDate = selectedDate
            vc.startAvailableSeats = 0
            vc.returnAvailableSeats = 0
            self.navigationController?.pushViewController(vc, animated: true)
            
        })
        edit.backgroundColor = .orange
        */
        
        let qrImg = UIContextualAction(style: .normal, title:  "QR", handler: { [self] (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            success(true)
            
            let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
            print(data)
            
            
            let todayDate = (data["bookingDate"] as! String)
            let bookingAgentID = (data["bookingAgentID"] as! String)
            let adult = (data["adult"] as! String)
            let minor = (data["minor"] as! String)
            let customerName = (data["customerName"] as! String)
            let customePhone = (data["customePhone"] as! String)
            let tripStartTime = (data["tripStartTime"] as! String)
            let tripReturnTime = (data["tripReturnTime"] as! String)
            let ticketID = (data["ticketID"] as! String)
            let isStartDeparting = (data["startDeparting"] as! Bool)
            let departurePostRef = (data["startDocumentPath"] as? String ?? "")
            let returnPostRef = (data["returnDocumentPath"] as? String ?? "")
            let dictionary = ["bookingDate": todayDate, "bookingAgentID": bookingAgentID, "adult": adult, "minor": minor, "customerName": customerName, "customePhone": customePhone, "tripStartTime": tripStartTime,"tripReturnTime": tripReturnTime,"ticketID":ticketID,"startDeparting":isStartDeparting,"startDocumentPath": departurePostRef,"returnDocumentPath": returnPostRef] as [String : Any]
            
            
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(jsonString!)
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "BookingConfirmationVC") as! BookingConfirmationVC
            vc.dataDict = jsonString!
            vc.customerEmail = (data["email"] as! String)
            vc.customerPhone = (data["customePhone"] as! String)
            vc.ticketID = (data["ticketID"] as! String)
            vc.tripStartTime = (data["tripStartTime"] as! String)
            vc.tripEndTime = (data["tripReturnTime"] as! String)
            vc.customerName = (data["customerName"] as! String)
            vc.comment = (data["comment"] as! String)
            vc.departureDate = (data["bookingDate"] as! String)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        qrImg.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [qrImg])
    }
    
    
    func cancelBookedTicket(_ selectedIndex : Int) {
        Utility.showActivityIndicator()
        let data = ticketListArray.object(at: selectedIndex) as! NSDictionary
        print(data)
        let db = Firestore.firestore()
        let ticketID = (data["ticketID"] as! String)
        self.updateTicketStatus(ticketID)
        
        //Update Seats
        let tripReturnTime = (data["tripReturnTime"] as! String)
        let tripStartTime = (data["tripStartTime"] as! String)
        let taxiID = (data["taxiID"] as! String)
        let todayDateString = (data["todayDateString"] as! String)
        
        let taxiIDVal = String("\(taxiID)\(todayDateString)")
        let totalSeatsToCancel : Int = Int((data["adult"] as! String))! + Int((data["minor"] as! String))!
        
        let docRef = db.collection("todayStat").document(taxiIDVal)

        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let todayData : NSDictionary = document.data()! as NSDictionary
                
                let isStatSort = (data["startDeparting"] as! Bool)
                var startTimeArray = NSMutableArray()
                var returnTimeArray = NSMutableArray()
 
                if isStatSort {
                    startTimeArray = todayData["timingList"] as! NSMutableArray
                    returnTimeArray = todayData["returnTimingList"] as! NSMutableArray
                }
                else {
                    startTimeArray = todayData["returnTimingList"] as! NSMutableArray
                    returnTimeArray = todayData["timingList"] as! NSMutableArray
                }
                
              //  let startTimeArray : NSMutableArray = todayData["timingList"] as! NSMutableArray
              //  let returnTimeArray : NSMutableArray = todayData["returnTimingList"] as! NSMutableArray
                
                for index in 0..<startTimeArray.count {
                    let data = startTimeArray.object(at: index) as! NSDictionary
                    if (data["time"] as! String) == tripStartTime {
                         let alreadyBooked = (data["alreadyBooked"] as! Int)
                        
                        var newCount : Int = alreadyBooked - totalSeatsToCancel
                        
                        if newCount <= 0 {
                            newCount = 0
                        }
                        
                        let newData : NSDictionary = ["alreadyBooked" :  newCount, "time" : tripStartTime]
                        startTimeArray.replaceObject(at: index, with: newData)
                    }
                }
                for index in 0..<returnTimeArray.count {
                    let data = returnTimeArray.object(at: index) as! NSDictionary
                    if (data["time"] as! String) == tripReturnTime {
                         let alreadyBooked = (data["alreadyBooked"] as! Int)
                        
                        var newCount : Int = alreadyBooked - totalSeatsToCancel
                        
                        if newCount <= 0 {
                            newCount = 0
                        }
                        
                        let newData : NSDictionary = ["alreadyBooked" :  newCount, "time" : tripReturnTime]
                        returnTimeArray.replaceObject(at: index, with: newData)
                    }
                }
                
                var newStartArr = NSMutableArray()
                var newReturnArr = NSMutableArray()
                if isStatSort {
                    newStartArr = startTimeArray
                    newReturnArr = returnTimeArray
                }
                else {
                    newStartArr = returnTimeArray
                    newReturnArr = startTimeArray
                }
                
                
                docRef.updateData([
                    "timingList":newStartArr,
                    "returnTimingList":newReturnArr
                ]) { err in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error updating document: \(err)")
                        let vW = Utility.displaySwiftAlert("", "Error Occured" , type: SwiftAlertType.error.rawValue)
                        SwiftMessages.show(view: vW)
                    } else {
                        print("Document successfully updated")
                        let vW = Utility.displaySwiftAlert("", "Ticket Cancelled" , type: SwiftAlertType.success.rawValue)
                        SwiftMessages.show(view: vW)
                        self.getUpdatedTicketListFromDB()
                        
                        
                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                            vc.isFromAdmin = false
                            vc.isAgentEditTicket = false
                            Constant.currentUserFlow = "Agent"
                            self.navigationController?.pushViewController(vc, animated: true)
                        
                        
                        
                    }
                }
            } else {
                Utility.hideActivityIndicator()
                print("Document does not exist")
            }
        }
        
        
    }
    
    func showCancelAlert(_ index : Int) {
        
            let alertController = UIAlertController(title: "WTM", message: "Do you really want to delete!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                UIAlertAction in
                NSLog("OK Pressed")
               self.cancelBookedTicket(index)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    func updateTicketStatus(_ ticketID : String) {
        //Cancel Ticket Status
        let db = Firestore.firestore()
        let ticketRef = db.collection("manageBooking").document(ticketID)
        ticketRef.getDocument { (document, error) in
            if let document = document, document.exists {
                ticketRef.updateData([
                    "status":"Cancelled"
                ])
            } else {
                print("Document does not exist")
            }
        }
    }

}
