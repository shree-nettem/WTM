//
//  AdminBookTicketVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 07/03/21.
//

import UIKit
import FSCalendar
import Firebase
import SwiftMessages

class AdminBookTicketVC: UIViewController , UITableViewDelegate, UITableViewDataSource,FSCalendarDelegate, FSCalendarDataSource , UIPickerViewDelegate , UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var txtAgent : UITextField!
    @IBOutlet weak var tblView : UITableView!
    
    var hiddenSections = Set<Int>()
    var ticketListArray = NSMutableArray()
    var taxiListArray = NSMutableArray()
    var dayOfWeek : Int = -1
    var timmingList = NSMutableArray()
    var tempTimmeList = NSMutableArray()
    var tempReturnTimeList = NSMutableArray()
    var todayStatArray = NSMutableArray()
    var todayMessageArray = NSMutableArray()
    var isFromAdmin : Bool = false
    var isAgentEditTicket : Bool = false
    
    
    var breakForLoop:Bool = false
    var tableViewReloaded:Bool = true
    
    
    
    @IBOutlet weak var notificationImg : UIImageView!
    
    @IBOutlet weak var btnTodayDate : UIButton!
    
    @IBOutlet weak var calenderView : UIView!
    @IBOutlet weak var calendar: FSCalendar!
    var selectedDate : Date!
    @IBOutlet weak var calendarHeightConstraint : NSLayoutConstraint!
    var agentListArray = NSArray()
    
    let toolBar = UIToolbar()
    var dataPicker : UIPickerView!
    var selectedAgent = NSDictionary()
    
    @IBOutlet weak var startTimeImg : UIImageView!
    @IBOutlet weak var returnTimeImg : UIImageView!
    var isStatTimeSort : Bool = true
    @IBOutlet weak var timeSortViewHeight : NSLayoutConstraint!
    
    @IBOutlet weak var oneWayTripImg : UIImageView!
    @IBOutlet weak var roundWayTripImg : UIImageView!
    var isRoundTrip : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDate = Date()
        
        hiddenSections = [1]

        
        txtAgent.setLeftPaddingPoints(10.0)
        
        //Calender
        calendar.dataSource = self
        calendar.delegate = self
        calendar.firstWeekday = 1
        calendar.allowsSelection = true
        calendar.appearance.titleWeekendColor = #colorLiteral(red: 0.06893683225, green: 0.2285976112, blue: 0.6367123723, alpha: 1)
        calendar.allowsMultipleSelection = false
        calendar.isHidden = true
        
        txtAgent.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        isStatTimeSort = true
        startTimeImg.image = UIImage(named: "RadioON")
        returnTimeImg.image = UIImage(named: "RadioOFF")
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-YYYY"
        btnTodayDate.setTitle(dateFormatter.string(from: selectedDate), for: .normal)
        
        getUpdatedAgentList()
        
        getDashBoardTicketDetails()
        
//        DatabseManager.getTaxiList() { taxiListArray in
//            self.taxiListArray = taxiListArray
//            for index in 0..<taxiListArray.count {
//
//                let data = taxiListArray.object(at: index) as! NSDictionary
//                print(data)
//
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "ddMMMYYYY"
//                let todayDateString =  dateFormatter.string(from: self.selectedDate)
//                let taxiID : String = data["ID"] as! String
//                let taxiIDVal = String("\(taxiID)\(todayDateString)")
//
//                let db = Firestore.firestore()
//                let docRef = db.collection("todayStat").document(taxiIDVal)
//                docRef.getDocument { (document, error) in
//                    if let document = document, document.exists {
//                        Utility.hideActivityIndicator()
//                        DatabseManager.getTodayStatData(selectedDate: self.selectedDate) { statArray in
//                            Utility.hideActivityIndicator()
//                            if statArray.count > 0 {
//                                self.todayStatArray = statArray
//                                print(self.todayStatArray)
//                                self.tblView.reloadData()
//                            }
//                        }
//                    } else {
//                        DatabseManager.setTodayStatData(selectedDate: self.selectedDate)
//                    }
//                }
//          }
//        }
        
    }
    
    func getDashBoardTicketDetails() {
        self.breakForLoop = true
        var finalStatArray:NSMutableArray = []
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: selectedDate)
        dayOfWeek = calendar.component(.weekday, from: today)
        print(dayOfWeek)
        DatabseManager.getTaxiList() { taxiListArray in
            self.taxiListArray = taxiListArray
            for index in 0..<taxiListArray.count {
                
                let data = taxiListArray.object(at: index) as! NSDictionary
                print(data)
                print(self.dayOfWeek)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "ddMMMYYYY"
                let todayDateString =  dateFormatter.string(from: self.selectedDate)
                let taxiID : String = data["ID"] as! String
                
                var weekdaystarttimes = data["weekDayStartTiming"] as! Array<String>
              
                if self.dayOfWeek == 1 || self.dayOfWeek == 7  || self.dayOfWeek == -1 || self.dayOfWeek == -7 {
                    weekdaystarttimes = data["weekEndStartTiming"] as! Array<String>
                    
                    if !self.isStatTimeSort {
                        weekdaystarttimes = data["weekEndReturnTiming"] as! Array<String>
                    }
                }
                else {
                    if !self.isStatTimeSort {
                        weekdaystarttimes = data["weekDayReturnTiming"] as! Array<String>
                    }
                    
                    
                }
                
                
               
                
               
               
                
                for timeIndex in 0..<weekdaystarttimes.count {
                    
                    
                    let timeStramp = weekdaystarttimes[timeIndex]
                    let taxiIDVal = String("\(taxiID)\(todayDateString)\(timeStramp)")
                    
                    print("sreee  \(taxiIDVal)")
                  
                    let db = Firestore.firestore()
                    let docRef = db.collection("bookings").document(taxiIDVal)
                    
                    docRef.getDocument { (document, error) in
                        
                        if let document = document, document.exists {
                            
                            print("sreee document exists")
                            self.tableViewReloaded = false
                            Utility.hideActivityIndicator()
                            
                            let bookedSeats = self.getTotalCount(BookingFile: document.data() ?? [:])
                            
                            print("sreee \(bookedSeats)")
                           
                           
                            
                            if finalStatArray.count <= 0 {
                                DatabseManager.getTodayStatData(selectedDate: self.selectedDate) { statArray in
                                    Utility.hideActivityIndicator()
                                    
                                    print(statArray)
                                    if finalStatArray.count <= 0 {
                                        finalStatArray = statArray
                                        finalStatArray = self.reloadingTableViewWithData(finalStatArray: finalStatArray, taxiID: taxiID, timeStramp: timeStramp, bookedSeats: bookedSeats)
                                        self.todayStatArray = finalStatArray
                                        print(self.todayStatArray)
                                        self.tblView.reloadData()
                                    } else {
                                        finalStatArray =  self.reloadingTableViewWithData(finalStatArray: finalStatArray, taxiID: taxiID, timeStramp: timeStramp, bookedSeats: bookedSeats)
                                        self.todayStatArray = finalStatArray
                                        print(self.todayStatArray)
                                        self.tblView.reloadData()
                                    }
                                   
                                }
                            
                            } else {
                                finalStatArray =  self.reloadingTableViewWithData(finalStatArray: finalStatArray, taxiID: taxiID, timeStramp: timeStramp, bookedSeats: bookedSeats)
                                self.todayStatArray = finalStatArray
                                print(self.todayStatArray)
                                self.tblView.reloadData()
                            }
                            
                           
                            
                           
                        } else {
                           
                            if self.breakForLoop {
                                self.breakForLoop = false
                                Utility.hideActivityIndicator()
//                                print(self.selectedDate)
                                
                                DatabseManager.setTodayStatData(selectedDate: self.selectedDate)
                               

                                
                            }
                            
                            
                        }
                    }
                }
                
                
                print(self.todayStatArray)
              
          }
        }

        
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        DatabseManager.getTodayStatData(selectedDate : selectedDate) { statArray in
            Utility.hideActivityIndicator()
            if self.tableViewReloaded {
                
                let finalStatArray = statArray
                if finalStatArray.count > 0 {
                     
                        for statArrayIndex in 0..<finalStatArray.count {
                        var signleDocument = finalStatArray[statArrayIndex] as? Dictionary<String,Any>
                        
//                        if signleDocument?["taxiID"] as? String ?? "" == taxiID {
                            
                            
                            var weekdaystarttimes = signleDocument?["timingList"] as! Array<Dictionary<String,Any>>
                            
                            if !self.isStatTimeSort {
                                weekdaystarttimes = signleDocument?["returnTimingList"] as! Array<Dictionary<String,Any>>
                            }
                            
                            for timeIndex in 0..<weekdaystarttimes.count {
                          
//                                if timeStramp == weekdaystarttimes[timeIndex]["time"] as? String {
                                    weekdaystarttimes[timeIndex]["alreadyBooked"] = 0
                                  
//                                }
                            }
                            if self.isStatTimeSort {
                                signleDocument?["timingList"] = weekdaystarttimes
                            } else {
                                signleDocument?["returnTimingList"] = weekdaystarttimes
                                
                            }
                            
                            
                            print(weekdaystarttimes)
//                        }
                        
                            finalStatArray[statArrayIndex] = signleDocument ?? [:]
                      
                    }
                    
                   
                   
                  
                }
                
                
                
                
                if finalStatArray.count > 0 {
                    self.todayStatArray = finalStatArray
                    print(self.todayStatArray)
                    self.tblView.reloadData()
                }
            }
           
        }
    }
    
    //MARK:- UITextfield Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
            self.showDataPicker()
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let tag = textField.tag
        print(tag)
    }
    
    @IBAction func onClickBackAcn(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSwapTimeAcn(_ sender : UIButton){
        let btnTag = sender.tag
        
        if btnTag == 1 {
            isStatTimeSort = true
            startTimeImg.image = UIImage(named: "RadioON")
            returnTimeImg.image = UIImage(named: "RadioOFF")
        }
        else {
            isStatTimeSort = false
            startTimeImg.image = UIImage(named: "RadioOFF")
            returnTimeImg.image = UIImage(named: "RadioON")
        }
        
        getDashBoardTicketDetails()
        
//        DatabseManager.getTodayStatData(selectedDate: selectedDate) { statArray in
//            Utility.hideActivityIndicator()
//            if statArray.count > 0 {
//                self.todayStatArray = statArray
//                print(self.todayStatArray)
//                self.tblView.reloadData()
//            }
//        }
        
    }
    
    //MARK:- UIPicker Delegate
    func showDataPicker() {
        self.dataPicker = UIPickerView(frame:CGRect(x: 0, y: self.view.frame.height-300, width: self.view.frame.size.width, height: 216))
        self.dataPicker.delegate = self
        self.dataPicker.dataSource = self
        self.dataPicker.backgroundColor = UIColor.white
        dataPicker.delegate = self
        txtAgent.inputView = self.dataPicker
        
        // ToolBar
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        toolBar.sizeToFit()
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done  , target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        txtAgent.inputAccessoryView = toolBar
        
    }
    
    @objc func doneClick() {
            let data = (agentListArray.object(at: dataPicker.selectedRow(inComponent: 0)) as! NSDictionary)
            selectedAgent = data
            txtAgent.text = (data["name"] as! String)
            txtAgent.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        txtAgent.resignFirstResponder()
    }
    
    func getUpdatedAgentList() {
        self.getAgentList() { agentListArray in
            print(agentListArray)
            if agentListArray.count > 0 {
                self.agentListArray = agentListArray
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
                        if (data["userType"] as! String == "Agent" ) && (data["status"] as! String == "Approved" ){
                            agentArray.add(document.data())
                        }
                    }
                }
            completion(agentArray)
        }
    }
    
    func getTodayStatData(completion: @escaping (_ statArray : NSMutableArray) -> Void) {
        let db = Firestore.firestore()
        Utility.showActivityIndicator()
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "dd-MMM-YYYY"
        let todayDateString =  newDateFormatter.string(from: selectedDate)
        
        
        let bookingRef = db.collection("todayStat").whereField("todayDate", isEqualTo: todayDateString)
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
    
    //MARK:- UIPickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return agentListArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let selectedData : NSDictionary = (agentListArray.object(at: row) as! NSDictionary) as NSDictionary
        return (selectedData["name"] as! String)
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        

    }
    
    //MARK:- Calender Methods
    @objc func handlecalenderViewTap(_ sender: UITapGestureRecognizer) {
        calenderView.isHidden = true
    }
    
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
        
        self.tableViewReloaded = true
        //Get Completed List
        getDashBoardTicketDetails()
//        DatabseManager.getTaxiList() { taxiListArray in
//            for index in 0..<taxiListArray.count {
//                let data = taxiListArray.object(at: index) as! NSDictionary
//                print(data)
//
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "ddMMMYYYY"
//                let todayDateString =  dateFormatter.string(from: self.selectedDate)
//                let taxiID : String = data["ID"] as! String
//                let taxiIDVal = String("\(taxiID)\(todayDateString)")
//
//                let db = Firestore.firestore()
//                let docRef = db.collection("todayStat").document(taxiIDVal)
//                docRef.getDocument { (document, error) in
//                    if let document = document, document.exists {
//                        Utility.hideActivityIndicator()
//                        DatabseManager.getTodayStatData(selectedDate: self.selectedDate) { statArray in
//                            Utility.hideActivityIndicator()
//                            if statArray.count > 0 {
//                                self.todayStatArray = statArray
//                                print(self.todayStatArray)
//                                self.tblView.reloadData()
//                            }
//                        }
//                    } else {
//                        DatabseManager.setTodayStatData(selectedDate: self.selectedDate)
//                    }
//                }
//          }
//        }
        
        
    }
    
    //MARK:- OnClick Action Method
    @IBAction func onClickTripTypeAcn(_ sender : UIButton){
        let btnTag = sender.tag
        
        if btnTag == 1 {
            isRoundTrip = true
            roundWayTripImg.image = UIImage(named: "RadioON")
            oneWayTripImg.image = UIImage(named: "RadioOFF")
        }
        else {
            isRoundTrip = false
            roundWayTripImg.image = UIImage(named: "RadioOFF")
            oneWayTripImg.image = UIImage(named: "RadioON")
        }
    }
    @IBAction func onClickTodayDateAcn(_ sender : UIButton){
        calendar.isHidden = false
        
    }
    
    @IBAction func onClickBookingAcn(_ sender : UIButton){
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func hideSection(sender: UIButton) {
        let section = sender.tag
        
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            let data = self.todayStatArray.object(at: section) as! NSDictionary
            let arr : NSArray = data["timingList"] as! NSArray
            for row in 0..<arr.count {
                indexPaths.append(IndexPath(row: row,
                                            section: section))
            }
            return indexPaths
        }
        
        
        if self.hiddenSections.contains(section) {
            self.hiddenSections.remove(section)
            self.tblView.insertRows(at: indexPathsForSection(),
                                      with: .fade)
        } else {
            self.hiddenSections.insert(section)
            self.tblView.deleteRows(at: indexPathsForSection(),
                                      with: .fade)
        }
        tblView.reloadData()
    }
    
    
    
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AgentBookingHeaderCell")! as! AgentBookingHeaderCell
        let data = self.todayStatArray.object(at: section) as! NSDictionary
        cell.lblTitle.text = (data["name"] as! String)
        cell.btnHide.tag = section
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
            return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AgentBookingTblCell")! as! AgentBookingTblCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.vwDashedLine.makeDashedBorderLine()
        
        let data = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
       // let arr : NSArray = data["timingList"] as! NSArray
        
        
        var arr = NSArray()
        
        if isStatTimeSort {
             arr = data["timingList"] as! NSArray
        }
        else {
             arr = data["returnTimingList"] as! NSArray
        }
        
        
        print(arr)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMYYYY"
        let todayDateString =  dateFormatter.string(from: self.selectedDate)
        
        let rowData = arr.object(at: indexPath.row) as? NSDictionary ?? [:]
        let timeStr = (rowData["time"] as? String ?? "")

        let taxiIDVal = "\(data["taxiID"] as? String ?? "")\(todayDateString)\(timeStr)"
//        let taxiIDVal = String("162806891718Aug20213:30 PM")
        
        print("sreee  \(taxiIDVal)")
      
        cell.lblTimeSlot.text = (rowData["time"] as? String ?? "")
        let db = Firestore.firestore()
        let docRef = db.collection("bookings").document(taxiIDVal)
        
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                let bookedSeats = self.getTotalCount(BookingFile: document.data() ?? [:])
                let totalSeats =  (data["totalSeats"] as? Int ?? 0)
               
                
                let availableSeats = totalSeats - bookedSeats
                cell.lblLeftSeats.text = String("\(availableSeats)")
                
            } else {
                let totalSeats =  (data["totalSeats"] as? Int ?? 0)
               
                
                let availableSeats = totalSeats - 0
                cell.lblLeftSeats.text = String("\(availableSeats)")
               
            }
            
        }
        return cell
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if txtAgent.text == "" {
            let vW = Utility.displaySwiftAlert("", "Please select agent.", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else {
            
            let vc = storyboard!.instantiateViewController(withIdentifier: "AgentBookingReturnTimeVC") as! AgentBookingReturnTimeVC
            let data : NSDictionary = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
            vc.taxiData = self.taxiListArray.object(at:indexPath.section) as! NSDictionary
            let totalSeats = Int(truncating: data["totalSeats"] as! NSNumber)
            
            print(data)
            
            //let arr : NSArray = data["timingList"] as! NSArray
            var arr = NSArray()
            var returnArr = NSArray()
            var ticketType = String()
            if isStatTimeSort {
                 ticketType = "tripStartTime"
                 arr = data["timingList"] as! NSArray
                 returnArr = data["returnTimingList"] as! NSArray
            }
            else {
                 ticketType = "tripReturnTime"
                 arr = data["returnTimingList"] as! NSArray
                 returnArr = data["timingList"] as! NSArray
            }
            
            let rowData = arr.object(at: indexPath.row) as! NSDictionary
            let alreadyBooked = Int(truncating: rowData["alreadyBooked"] as! NSNumber)
            let ticketTime = (rowData["time"] as! String)
            print(rowData)
            let now = Date()
            
            DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: ticketTime, timeType: ticketType, startDeparting: isStatTimeSort, completion: { count , backtime in
                print(count)
                
                
                if self.selectedDate > now {
                    
                    // Selected Date is bigger than today date
//                    if totalSeats - count > 0 {
                        vc.tripStartTime = (rowData["time"] as! String)
                        if self.isStatTimeSort {
                            vc.returnTimeArray = data["returnTimingList"] as! NSArray
                        }
                        else {
                            vc.returnTimeArray = data["timingList"] as! NSArray
                        }
                       // vc.returnTimeArray = data["returnTimingList"] as! NSArray
                        vc.tripStartTimeArray = arr
                        print(Int(truncating: data["totalSeats"] as! NSNumber))
                        vc.totalSeatsInTaxi = Int(truncating: data["totalSeats"] as! NSNumber)
                        vc.selectedDate = self.selectedDate
                        vc.isAdminTicketBook = false
                        vc.startAvailableSeats = Int(truncating: data["totalSeats"] as! NSNumber) - Int(truncating: rowData["alreadyBooked"] as! NSNumber)
                        print(self.isStatTimeSort)
                        vc.isStatTimeSort = self.isStatTimeSort
                        
                        if self.isRoundTrip {
                            self.checkForReturnTime(startTime: (rowData["time"] as! String), returnTime: returnArr, indexNumber: indexPath.row, totalSeats: totalSeats, taxiData: self.taxiListArray.object(at:indexPath.section) as! NSDictionary)
                        }
                        else {
                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
                            vc.tripStartTime = (rowData["time"] as! String)
                            vc.taxiData = self.taxiListArray.object(at:indexPath.section) as! NSDictionary
                            vc.isTicketEdit = false
                            vc.selectedDate = self.selectedDate
                            vc.isStatTimeSort = self.isStatTimeSort;
                            vc.isRoundTrip = self.isRoundTrip
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
//                    }
//                    else {
//                        let vW = Utility.displaySwiftAlert("","Tickets Not Available", type: SwiftAlertType.error.rawValue)
//                        SwiftMessages.show(view: vW)
//                    }
                }
                else {
                    //Selected date is same as today date, Agent can book even after 30 minutes past of ticket time
//                    if totalSeats - count > 0 {
                        
                        let selectedSlot = (rowData["time"] as! String)
                        
                        //Convert Date from Hours
                        let outStr = self.dateTimeChangeFormat(str: selectedSlot,
                                                          inDateFormat:  "h:mm a",
                                                          outDateFormat: "HH:mm")
                        
                        print(outStr)
                        let calendar = Calendar.current
                        let time=calendar.dateComponents([.hour,.minute,.second], from: Date())
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm"
                        dateFormatter.timeZone = .current
                        let selectedTicketTime = dateFormatter.date(from: outStr)!
                        let currentAgentTime = dateFormatter.date(from: String("\(time.hour!):\(time.minute!)"))!
       
                        print(selectedTicketTime)
                        print(currentAgentTime)
                        
                        if self.isRoundTrip {
                            if selectedTicketTime > currentAgentTime   {
                                self.checkForReturnTime(startTime: (rowData["time"] as! String), returnTime: returnArr, indexNumber: indexPath.row, totalSeats: totalSeats, taxiData: self.taxiListArray.object(at:indexPath.section) as! NSDictionary)
                            }
                            else {
                                let vW = Utility.displaySwiftAlert("","Can't book in past time", type: SwiftAlertType.error.rawValue)
                                SwiftMessages.show(view: vW)
                            }
                        }
                        else {
                            if selectedTicketTime > currentAgentTime   {
                                let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
                                vc.tripStartTime = (rowData["time"] as! String)
                                vc.taxiData = self.taxiListArray.object(at:indexPath.section) as! NSDictionary
                                vc.isTicketEdit = false
                                vc.selectedDate = self.selectedDate
                                vc.isStatTimeSort = self.isStatTimeSort;
                                vc.isRoundTrip = self.isRoundTrip
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else {
                                let vW = Utility.displaySwiftAlert("","Can't book in past time", type: SwiftAlertType.error.rawValue)
                                SwiftMessages.show(view: vW)
                            }
                        }
                        
                        
//                    }
//                    else {
//                        let vW = Utility.displaySwiftAlert("","Tickets Not Available", type: SwiftAlertType.error.rawValue)
//                        SwiftMessages.show(view: vW)
//                    }
                }
          })
            
            
            /*
            if isRoundTrip {
                let now = Date()
                if selectedDate > now {
                    let vc = storyboard!.instantiateViewController(withIdentifier: "AgentBookingReturnTimeVC") as! AgentBookingReturnTimeVC
                    
                    let data : NSDictionary = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
                    vc.taxiData = self.taxiListArray.object(at:indexPath.section) as! NSDictionary
                    print(data)
                    //let arr : NSArray = data["timingList"] as! NSArray
                    
                    var arr = NSArray()
                    if isStatTimeSort {
                         arr = data["timingList"] as! NSArray
                    }
                    else {
                         arr = data["returnTimingList"] as! NSArray
                    }
                    
                    
                    let rowData = arr.object(at: indexPath.row) as! NSDictionary
                    print(rowData)
                    vc.tripStartTime = (rowData["time"] as! String)
                    
                    //vc.returnTimeArray = data["returnTimingList"] as! NSArray
                    if isStatTimeSort {
                        vc.returnTimeArray = data["returnTimingList"] as! NSArray
                    }
                    else {
                        vc.returnTimeArray = data["timingList"] as! NSArray
                    }
                    
                    
                    vc.tripStartTimeArray = arr
                    print(Int(truncating: data["totalSeats"] as! NSNumber))
                    vc.totalSeatsInTaxi = Int(truncating: data["totalSeats"] as! NSNumber)
                    vc.selectedDate = selectedDate
                    vc.isAdminTicketBook = true
                    vc.selectedAgentData = selectedAgent
                    
                    vc.startAvailableSeats = Int(truncating: data["totalSeats"] as! NSNumber) - Int(truncating: rowData["alreadyBooked"] as! NSNumber)
                    vc.isStatTimeSort = isStatTimeSort;
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let vc = storyboard!.instantiateViewController(withIdentifier: "AgentBookingReturnTimeVC") as! AgentBookingReturnTimeVC
                    
                    let data : NSDictionary = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
                    vc.taxiData = self.taxiListArray.object(at:indexPath.section) as! NSDictionary
                    print(data)
                 //   let arr : NSArray = data["timingList"] as! NSArray
                    
                    var arr = NSArray()
                    if isStatTimeSort {
                         arr = data["timingList"] as! NSArray
                    }
                    else {
                         arr = data["returnTimingList"] as! NSArray
                    }
                    
                    
                    let rowData = arr.object(at: indexPath.row) as! NSDictionary
                    print(rowData)
                    vc.tripStartTime = (rowData["time"] as! String)
                    let selectedSlot = (rowData["time"] as! String)
                    //Convert Date from Hours
                    let outStr = dateTimeChangeFormat(str: selectedSlot, inDateFormat:  "h:mm a", outDateFormat: "HH:mm")
                    
                    print(outStr)
                    let calendar = Calendar.current
                    let time=calendar.dateComponents([.hour,.minute,.second], from: Date())
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    dateFormatter.timeZone = .current
                    let selectedTicketTime = dateFormatter.date(from: outStr)!
                   // let selectedTicketTime = dateFormatter.date(from: "14:00")!
                    let currentAgentTime = dateFormatter.date(from: String("\(time.hour!):\(time.minute!)"))!
                    
                    if selectedTicketTime > currentAgentTime   {
                        //vc.returnTimeArray = data["returnTimingList"] as! NSArray
                        
                        if isStatTimeSort {
                            vc.returnTimeArray = data["returnTimingList"] as! NSArray
                        }
                        else {
                            vc.returnTimeArray = data["timingList"] as! NSArray
                        }
                        print(vc.returnTimeArray)
                        vc.tripStartTimeArray = arr
                        print(Int(truncating: data["totalSeats"] as! NSNumber))
                        vc.totalSeatsInTaxi = Int(truncating: data["totalSeats"] as! NSNumber)
                        vc.selectedDate = selectedDate
                        vc.isAdminTicketBook = true
                        vc.selectedAgentData = selectedAgent
                        
                        vc.startAvailableSeats = Int(truncating: data["totalSeats"] as! NSNumber) - Int(truncating: rowData["alreadyBooked"] as! NSNumber)
                        vc.isStatTimeSort = isStatTimeSort
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else {
                        let vW = Utility.displaySwiftAlert("", "Can't book in past time", type: SwiftAlertType.error.rawValue)
                        SwiftMessages.show(view: vW)
                    }
                }
            }*/
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.hiddenSections.contains(section) {
                return 0
            }
            let data = self.todayStatArray.object(at: section) as! NSDictionary
            let arr : NSArray = data["timingList"] as! NSArray
            return arr.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
           return self.todayStatArray.count
    }
    
    //MARK:- Check For Return Time
    func checkForReturnTime(startTime : String , returnTime : NSArray, indexNumber : Int, totalSeats : Int, taxiData : NSDictionary) {
        
        print(startTime)
        print(returnTime)
       // let startIndex = indexNumber + 2
        var flag : Bool = false
        var stepCount : Int = 0
        var tempTime = String()
        var selectedFirstStepTime = String()
        var selectedFirstStepRowData = NSDictionary()
        
        if returnTime.count > 0 {
            
            for index in 0..<returnTime.count {
                let data = returnTime.object(at: index) as! NSDictionary
                
                let outStr = dateTimeChangeFormat(str: (data["time"] as! String),
                                                   inDateFormat:  "h:mm a",
                                                   outDateFormat: "HH:mm")
                let outStr1 = dateTimeChangeFormat(str: startTime,
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
                    stepCount = stepCount + 1
                    
                    if stepCount == 1 {
                        let rowData = returnTime.object(at: index) as! NSDictionary
                        selectedFirstStepTime = (rowData["time"] as! String)
                    }
                    
                    if stepCount == 2 {
                        let rowData = returnTime.object(at: index) as! NSDictionary
                        let selectedTime = (rowData["time"] as! String)
                        var ticketType = String()
                        
                        if isStatTimeSort {
                             ticketType = "tripStartTime"
                        }
                        else {
                             ticketType = "tripReturnTime"
                        }
                        DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: selectedTime, timeType: ticketType, startDeparting: isStatTimeSort, completion: { count , backtime in
                            print(count)
//                            if totalSeats - count > 0 {
                                flag = true
                                
                                let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
                                vc.tripStartTime = startTime
                                vc.tripReturnTime = (rowData["time"] as! String)
                                vc.taxiData = taxiData
                                vc.isTicketEdit = false
                                vc.selectedDate = self.selectedDate
                                vc.isStatTimeSort = self.isStatTimeSort;
                                self.navigationController?.pushViewController(vc, animated: true)
//                            }
                        })
                    }
                }
            }
        }
        
        if stepCount == 1 {
            flag = true
            var ticketType = String()
            if isStatTimeSort {
                 ticketType = "tripStartTime"
            }
            else {
                 ticketType = "tripReturnTime"
            }
            
            DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: selectedFirstStepTime, timeType: ticketType, startDeparting: isStatTimeSort, completion: { count , backtime in
                print(count)
//                if totalSeats - count > 0 {
                    flag = true
                    
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
                    vc.tripStartTime = startTime
                    vc.tripReturnTime = selectedFirstStepTime
                    vc.taxiData = taxiData
                    vc.isTicketEdit = false
                    vc.isStatTimeSort = self.isStatTimeSort;
                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//                else {
//                    flag = true
//                    Utility.hideActivityIndicator()
//                    let vW = Utility.displaySwiftAlert("", "No Return Time Available", type: SwiftAlertType.error.rawValue)
//                    SwiftMessages.show(view: vW)
//                }
            })
        }
        else {
            
        }
        
        
        
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
        
        //Add 30 Min to date
        let earlyDate = Calendar.current.date(
          byAdding: .minute,
          value: 30,
            to: date)! as Date
        print(date)
        print(earlyDate)
        return outFormatter.string(from: earlyDate)
        }

    func reloadingTableViewWithData(finalStatArray:NSMutableArray, taxiID:String, timeStramp:String, bookedSeats:Int) -> NSMutableArray{
        if finalStatArray.count > 0 {
             
                for statArrayIndex in 0..<finalStatArray.count {
                var signleDocument = finalStatArray[statArrayIndex] as? Dictionary<String,Any>
                
                if signleDocument?["taxiID"] as? String ?? "" == taxiID {
                    
                    
                    var weekdaystarttimes = signleDocument?["timingList"] as! Array<Dictionary<String,Any>>
                    
                    if !self.isStatTimeSort {
                        weekdaystarttimes = signleDocument?["returnTimingList"] as! Array<Dictionary<String,Any>>
                    }
                    
                    for timeIndex in 0..<weekdaystarttimes.count {
                  
                        if timeStramp == weekdaystarttimes[timeIndex]["time"] as? String {
//                            weekdaystarttimes[timeIndex]["alreadyBooked"] = 0
                            weekdaystarttimes[timeIndex]["alreadyBooked"] = bookedSeats
                          
                        } else {
                            weekdaystarttimes[timeIndex]["alreadyBooked"] = 0
                        }
                    }
                    if self.isStatTimeSort {
                        signleDocument?["timingList"] = weekdaystarttimes
                    } else {
                        signleDocument?["returnTimingList"] = weekdaystarttimes
                        
                    }
                    
                    
                    print(weekdaystarttimes)
                }
                
                    finalStatArray[statArrayIndex] = signleDocument ?? [:]
              
            }
            
           
           
          
        }
        return finalStatArray
    }
    
    func getTotalCount(BookingFile:Dictionary<String,Any>) -> Int {
        
        var count = 0
        
        if !BookingFile.isEmpty {
           
         _ = BookingFile.mapValues { (element)  in
               let signleDocument = element as? Dictionary<String,Any>
                
                if (signleDocument?["status"] as? String != "Cancelled") {
                    
                    let adultSeats = Int(signleDocument?["adult"] as? String ?? "0")
                    let minorSeats = Int(signleDocument?["minor"] as? String ?? "0")
                    count += (adultSeats ?? 0) + (minorSeats ?? 0)
                }
                
            }
            return count
            
        }
        return count
    }
}
