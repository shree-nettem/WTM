//
//  PastTicketListVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 03/01/21.
//

import UIKit
import FirebaseFirestore
import SwiftMessages
import SideMenu

class PastTicketListVC: UIViewController , UITableViewDelegate, UITableViewDataSource , UIPickerViewDelegate, UIPickerViewDataSource , UITextFieldDelegate{

    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var lblNoTicket : UILabel!
    var ticketListArray = NSMutableArray()
    var taxiData = NSDictionary()
    var tripStartTime = String()
    
    let timePicker = UIDatePicker()
    var datePicker : UIDatePicker!
    var selectedTF : UITextField!
    @IBOutlet weak var txtAgentName : UITextField!
    @IBOutlet weak var txtDate : UITextField!
    @IBOutlet weak var txtEndDate : UITextField!
    let toolBar = UIToolbar()
    var dataPicker : UIPickerView!
    var pickerController = UIImagePickerController()
    var agentListArray = NSArray()
    
    var tripDate = String()
    var agentName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtAgentName.setLeftPaddingPoints(10.0)
        txtDate.setLeftPaddingPoints(10.0)
        txtEndDate.setLeftPaddingPoints(10.0)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAgentList() { agentListArray in
            print(agentListArray)
            if agentListArray.count > 0 {
                self.agentListArray = agentListArray
            }
        }
    }
    @IBAction func onClickSideMenuAcn(_ sender : UIButton){
        let menu = storyboard!.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuNavigationController
        self.present(menu, animated: true, completion: nil)
    }
    @IBAction func onClickBackAcn() {
        _  = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onClickApplyAcn() {
        
        
        if (txtAgentName.text == "") && (txtDate.text == "") && (txtEndDate.text == ""){
            let vW = Utility.displaySwiftAlert("", "Choose any filter" , type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if (txtDate.text == "") && (txtEndDate.text != "") {
            let vW = Utility.displaySwiftAlert("", "Select both dates" , type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if (txtDate.text != "") && (txtEndDate.text == "") {
            let vW = Utility.displaySwiftAlert("", "Select both dates" , type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else {
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
    }
    
    func getTicketList(completion: @escaping (_ ticketListArray : NSMutableArray) -> Void) {
        
        var setValues:Set<String> = []
        
        
        
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MMM/yyyy"
        formatter.timeZone   = NSTimeZone(abbreviation: "UTC") as TimeZone?
        
        
        let SearchAgentName = self.txtAgentName.text!
        
        if txtAgentName.text == "" {
            let start : Date = formatter.date(from: txtDate.text!)!
            let startDate : Date = calendar.date(byAdding: .day, value:0, to: start)!
            let end : Date = formatter.date(from: txtEndDate.text!)!
            //let endDate : Date = calendar.date(byAdding: .day, value: 0, to: end)!
            
            
            var endDate = Date()
            if txtDate.text! ==  txtEndDate.text! { //If the date is same, then increase end date by 1
                endDate = calendar.date(byAdding: .day, value: 1, to: end)!
            }
            else {
                endDate = calendar.date(byAdding: .day, value: 0, to: end)!
            }
            
            
            
          //  let bookingRef = db.collection("manageBooking").whereField("bookingDateTimeStamp", isGreaterThan: startDate).whereField("bookingDateTimeStamp", isLessThan: endDate).order(by: "bookingDateTimeStamp")
            
//            let bookingRef =   db.collection("manageBooking").whereField("bookingDate", isEqualTo: selectedDateVal).whereField("tripStartTime", isEqualTo: tripStartTime).whereField("startDeparting", isEqualTo: true).order(by: "bookingDateTimeStamp")
            
            
            
            let bookingRef = db.collection("bookings")
            
            let totalBookings:NSMutableArray = []
 
            
            let ticketArray =  NSMutableArray()
            
            
            bookingRef.getDocuments() { (querySnapshot, err) in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
//                            let data = document.data()
//                            ticketArray.add(data)
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
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "ddMMMyyyy"
                            dateFormatter.timeZone   = NSTimeZone(abbreviation: "UTC") as TimeZone?
                            
                            let startDateFormat = dateFormatter.date(from: eData?["bookingDate"] as! String)
         
                           
                                if startDateFormat! >= startDate && startDateFormat! <= endDate && eData?["status"] as? String != "Cancelled" {
                                   
//                                    setValues.removeAll()
                                    
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
                                   
                                    
                                }
//                            }
                        }
                    }
                completion(ticketArray)
            }
        }
        else if txtDate.text == "" {
            
            let bookingRef = db.collection("bookings")
            
            let totalBookings:NSMutableArray = []
 
            
            let ticketArray =  NSMutableArray()
            var setValues:Set<String> = []
            
            bookingRef.getDocuments() { (querySnapshot, err) in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
//                            let data = document.data()
//                            ticketArray.add(data)
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
                            
         
                           
                                if  eData?["status"] as? String != "Cancelled" && SearchAgentName == eData?["agentName"] as? String {
                                   
//                                    setValues.removeAll()
                                    
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
                                   
                                    
                                }
//                            }
                        }
                    }
                completion(ticketArray)
            }
        }
        else {
            let start : Date = formatter.date(from: txtDate.text!)!
            let startDate : Date = calendar.date(byAdding: .day, value: 0, to: start)!
            let end : Date = formatter.date(from: txtEndDate.text!)!
            //let endDate : Date = calendar.date(byAdding: .day, value: 0, to: end)!
            
            
            var endDate = Date()
            if txtDate.text! ==  txtEndDate.text! { //If the date is same, then increase end date by 1
                endDate = calendar.date(byAdding: .day, value: 1, to: end)!
            }
            else {
                endDate = calendar.date(byAdding: .day, value: 0, to: end)!
            }
           
            
          //  let bookingRef = db.collection("manageBooking").whereField("bookingDateTimeStamp", isGreaterThan: startDate).whereField("bookingDateTimeStamp", isLessThan: endDate).whereField("agentName", isEqualTo: agentName).order(by: "bookingDateTimeStamp")
            
            let bookingRef = db.collection("bookings")
            
            let totalBookings:NSMutableArray = []
 
            
            let ticketArray =  NSMutableArray()
            var setValues:Set<String> = []
            
            bookingRef.getDocuments() { (querySnapshot, err) in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
//                            let data = document.data()
//                            ticketArray.add(data)
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
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "ddMMMyyyy"
                            dateFormatter.timeZone   = NSTimeZone(abbreviation: "UTC") as TimeZone?
                            
                            let startDateFormat = dateFormatter.date(from: eData?["bookingDate"] as! String)
         
                           
                                if startDateFormat! >= startDate && startDateFormat! <= endDate && eData?["status"] as? String != "Cancelled" && SearchAgentName == eData?["agentName"] as? String {
                                   
//                                    setValues.removeAll()
                                    
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
                                   
                                    
                                }
//                            }
                        }
                    }
                completion(ticketArray)
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
    
    func createPdfFromTableView()
    {
        let priorBounds: CGRect = self.tblView.bounds
        let fittedSize: CGSize = self.tblView.sizeThatFits(CGSize(width: priorBounds.size.width, height: self.tblView.contentSize.height))
        self.tblView.bounds = CGRect(x: 0, y: 0, width: fittedSize.width, height: fittedSize.height)
        self.tblView.reloadData()
        let pdfPageBounds: CGRect = CGRect(x: 0, y: 0, width: fittedSize.width, height: (fittedSize.height))
        let pdfData: NSMutableData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
        self.tblView.layer.render(in: UIGraphicsGetCurrentContext()!)
        UIGraphicsEndPDFContext()
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let documentsFileName = documentDirectories! + "/" + "pdfName"
        pdfData.write(toFile: documentsFileName, atomically: true)
        print(documentsFileName)
        
        let fileURL = NSURL(fileURLWithPath: documentsFileName)
        var filesToShare = [Any]()
        filesToShare.append(fileURL)
        //let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        //self.present(activityViewController, animated: true, completion: nil)
        
        
        let url = NSURL.fileURL(withPath: documentsFileName)

        let activityViewController = UIActivityViewController(activityItems: [url] , applicationActivities: nil)
                
        present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func onClickShare() {
        createPdfFromTableView()
    }

    //MARK:- UIPicker Delegate
    func showDataPicker() {
        self.dataPicker = UIPickerView(frame:CGRect(x: 0, y: self.view.frame.height-300, width: self.view.frame.size.width, height: 216))
        self.dataPicker.delegate = self
        self.dataPicker.dataSource = self
        self.dataPicker.backgroundColor = UIColor.white
        dataPicker.delegate = self
        txtAgentName.inputView = self.dataPicker
        
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
        
        txtAgentName.inputAccessoryView = toolBar
        
    }
    //MARK:- UIDatePicker Delegate
    func pickUpDate(_ textField : UITextField){
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
      //  self.datePicker.maximumDate = Date()
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
        if selectedTF == txtDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MMM/yyyy"
            txtDate.text = dateFormatter.string(from: datePicker.date)
            txtDate.resignFirstResponder()
            tripDate = txtDate.text!
        }
        else if selectedTF == txtEndDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MMM/yyyy"
            txtEndDate.text = dateFormatter.string(from: datePicker.date)
            txtEndDate.resignFirstResponder()
            tripDate = txtEndDate.text!
        }
        else if selectedTF == txtAgentName {
            let data = (agentListArray.object(at: dataPicker.selectedRow(inComponent: 0)) as! NSDictionary)
            txtAgentName.text = (data["name"] as! String)
            txtAgentName.resignFirstResponder()
            agentName = (data["name"] as! String)
        }
    }
    
    @objc func cancelClick() {
        selectedTF.resignFirstResponder()
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
    
    //MARK:- UITextfield Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTF = textField
        if textField == txtDate {
            self.pickUpDate(txtDate)
        }
        else if textField == txtEndDate {
            self.pickUpDate(txtEndDate)
        }
        else if textField == txtAgentName {
            self.showDataPicker()
        }
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let tag = textField.tag
        print(tag)
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
        let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
        let str = String("\("Comment: \((data["comment"] as! String))")")
        let height = str.height(withConstrainedWidth: self.view.frame.width - 80, font: UIFont(name: "Montserrat", size: 17.0)!)
        return 520 + height
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AdminTicketListCell")! as! AdminTicketListCell
        let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.lblAgentName.text = String("\("Agent Name: \((data["agentName"] as! String))")")
        cell.lblBookingName.text = String("\("Booking Name: \((data["customerName"] as! String))")")
        cell.lblTripDate.text = String("\("Booking Date: \((data["bookingDate"] as! String))")")
            
        let totalAdults : Int = Int(data["adult"] as! String)!
        let totalMinor : Int =  Int(data["minor"] as! String)!
        let totalPassengers : Int = totalAdults +  totalMinor
        cell.lblPassengers.text = String("\("Total Passengers: \(totalPassengers)")")
        cell.lblAdults.text = String("\("Adults: \(totalAdults)")\(" Minor: \(totalMinor)")")
      //  cell.lblStartTime.text = String("\("Start Time: \((data["tripStartTime"] as! String))")")
      //  cell.lblReturnTime.text = String("\("Return Time: \((data["tripReturnTime"] as! String))")")
        cell.lblComment.text =  String("\("Comment: \((data["comment"] as! String))")")
        cell.lblTicketID.text =  String("\("TicketID: \((data["ticketID"] as! String))")")
        cell.lblStatus.text =  String("\("Status: \((data["status"] as! String))")")
        
        cell.lblStartDepartureStatus.text =  String("\("Start Departure: \((data["startDepartureStatus"] as? String) ?? "Pending")")")
        cell.lblReturnDepartureStatus.text =  String("\("Return Departure: \((data["returnDepartureStatus"] as? String) ?? "Pending")")")
        
        print((data["ticketDepartureSide"] as? String) ?? "-")
        let departureSide = (data["ticketDepartureSide"] as? String) ?? "-"
        
        if departureSide == "-" {
            cell.lblDeparture.text =  "Departure: - "
        }
        else {
            cell.lblDeparture.text =  String("\("Departure: \((data["ticketDepartureSide"] as! String))")")
        }
        
        
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
        
        cell.lblComment.sizeToFit()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return ticketListArray.count
    }
    
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
      if editingStyle == .delete {
            print("Deleted")
            self.cancelBookedTicket(indexPath.section)
      }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let cancel = UIContextualAction(style: .normal, title:  "Cancel", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.cancelBookedTicket(indexPath.section)
            success(true)
        })
        cancel.backgroundColor = .red
        
        let edit = UIContextualAction(style: .normal, title:  "Edit", handler: { [self] (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            success(true)
            
            let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
            
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
            vc.isTicketEdit = true
            vc.ticketData = data
            self.navigationController?.pushViewController(vc, animated: true)
            
        })
        edit.backgroundColor = .orange
        
        
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
            
            let dictionary = ["bookingDate": todayDate, "bookingAgentID": bookingAgentID, "adult": adult, "minor": minor, "customerName": customerName, "customePhone": customePhone, "tripStartTime": tripStartTime,"tripReturnTime": tripReturnTime,"ticketID":ticketID]
            
            
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(jsonString!)
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "BookingConfirmationVC") as! BookingConfirmationVC
            vc.dataDict = jsonString!
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        qrImg.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [cancel, edit, qrImg])
    }
 */
    
    
    
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
        let startDepartureStatus = (data["startDepartureStatus"] as? String)
        let returnDepartureStatus = (data["returnDepartureStatus"] as? String)
        if bookingStatus == "Pending"  && startDepartureStatus == "Pending" && returnDepartureStatus == "Pending" {
            return true
        }
        else {
            return false
        }
        /*
        let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
        print(data)
        let bookingDate = (data["bookingDate"] as! String)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyy"
       // dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let selectedTicketTime = dateFormatter.date(from: bookingDate)!
        print(selectedTicketTime)
        
        if Calendar.current.isDate(selectedTicketTime, inSameDayAs:Date()) {
            return true
        }
        else {
            if selectedTicketTime >= Date() {
                return true
            }
            else {
                return false
            }
        }
        */
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
        
        let edit = UIContextualAction(style: .normal, title:  "Edit", handler: { [self] (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            success(true)
            
            let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
            print(data)
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
            print(data["startDeparting"] as! Bool)
            vc.isStatTimeSort = data["startDeparting"] as! Bool
            vc.isTicketEdit = true
            vc.ticketData = data
            vc.startAvailableSeats = 0
            vc.returnAvailableSeats = 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMMyyyy"
            let bookingDate = (data["bookingDate"] as! String)
            print(bookingDate)
            print(dateFormatter.date(from: bookingDate)!)
            vc.selectedDate = dateFormatter.date(from: bookingDate)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        })
        edit.backgroundColor = .orange
        
        
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
            let isStartDeparting = (data["startDeparting"] as? Bool) ?? true
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
            vc.departureDate =  todayDate
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        qrImg.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [edit, qrImg])
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
                
                
                var startTimeArray = NSMutableArray()
                var returnTimeArray = NSMutableArray()
 
                let isStatTimeSort = (data["startDeparting"] as! Bool)
                
                if isStatTimeSort {
                    startTimeArray = todayData["timingList"] as! NSMutableArray
                    returnTimeArray = todayData["returnTimingList"] as! NSMutableArray
                }
                else {
                    startTimeArray = todayData["returnTimingList"] as! NSMutableArray
                    returnTimeArray = todayData["timingList"] as! NSMutableArray
                }
                
               // let startTimeArray : NSMutableArray = todayData["timingList"] as! NSMutableArray
               // let returnTimeArray : NSMutableArray = todayData["returnTimingList"] as! NSMutableArray
                
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
                if isStatTimeSort {
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
                       // self.getUpdatedTicketListFromDB()
                        /*
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                            vc.isFromAdmin = false
                            vc.isAgentEditTicket = false
                            Constant.currentUserFlow = "Agent"
                        self.navigationController?.pushViewController(vc, animated: true)
                        */
                        
                    }
                }
            } else {
                Utility.hideActivityIndicator()
                print("Document does not exist")
            }
        }
        
        
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
