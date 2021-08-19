//
//  AdminTicketListVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 15/12/20.
//

import UIKit
import FirebaseFirestore
import SwiftMessages

class AdminTicketListVC: UIViewController , UITableViewDelegate, UITableViewDataSource {

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
    let toolBar = UIToolbar()
    var dataPicker : UIPickerView!
    var pickerController = UIImagePickerController()
    var agentListArray = NSArray()
    var isFromAdmin : Bool = false
    var selectedDate = Date()
    var isStatTimeSort : Bool = true
    var isticketBoardingPoint : Bool = true
    
    @IBOutlet weak var imgPending : UIImageView!
    @IBOutlet weak var imgApprove : UIImageView!
    @IBOutlet weak var imgCancel : UIImageView!
    @IBOutlet weak var lblPendingCount : UILabel!
    @IBOutlet weak var lblApproveCount : UILabel!
    @IBOutlet weak var lblCancelCount : UILabel!
    var selectedSortCategory = String()
    
    var pendingCount : Int = 0
    var approveCount : Int = 0
    var cancelCount : Int = 0
    var bsDeparturePendingCount : Int = 0
    var bsDepartureApprovedCount : Int = 0
    var mbDeparturePendingCount : Int = 0
    var mbDepartureApprovedCount : Int = 0
    
    
    @IBOutlet weak var lblBSReservedSeatsCount : UILabel!
    @IBOutlet weak var lblBSOnBoardCount : UILabel!
    @IBOutlet weak var lblBSNoShowCount : UILabel!
    @IBOutlet weak var lblBSCancelledCount : UILabel!
    
    @IBOutlet weak var lblMBReservedSeatsCount : UILabel!
    @IBOutlet weak var lblMBOnBoardCount : UILabel!
    @IBOutlet weak var lblMBNoShowCount : UILabel!
    @IBOutlet weak var lblMBCancelledCount : UILabel!
    
    @IBOutlet weak var topStatView : UIView!
    
    var adultReservedCount : Int = 0
    var minorReservedCount : Int = 0
    
    var adultOnBoardCount : Int = 0
    var minorOnBoardCount : Int = 0
    
    
    var bsDepartureAdultReservedCount : Int = 0
    var bsDepartureMinorReservedCount : Int = 0
    var bsDepartureAdultApprovedCount : Int = 0
    var bsDepartureMinorApprovedCount : Int = 0
    var bsDepartureAdultCancelledCount : Int = 0
    var bsDepartureMinorCancelledCount : Int = 0
    
    var mbDepartureAdultReservedCount : Int = 0
    var mbDepartureMinorReservedCount : Int = 0
    var mbDepartureAdultApprovedCount : Int = 0
    var mbDepartureMinorApprovedCount : Int = 0
    var mbDepartureAdultCancelledCount : Int = 0
    var mbDepartureMinorCancelledCount : Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedSortCategory = "Pending"
       
        getUpdatedTicketListFromDB()
        
        
        topStatView.layer.shadowColor = UIColor.black.cgColor
        topStatView.layer.shadowOpacity = 1
        topStatView.layer.shadowOffset = .zero
        topStatView.layer.shadowRadius = 10
        
        
    }

    @IBAction func onClickBackAcn() {
        _  = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- OnClick Ticket Sort Acn
    @IBAction func onClickSortAcn(sender : UIButton) {
        let btnTag = sender.tag
        
        if btnTag == 1 {
            selectedSortCategory = "Pending"
            imgPending.image = UIImage(named: "RadioON")
            imgApprove.image = UIImage(named: "RadioOFF")
            imgCancel.image = UIImage(named: "RadioOFF")
        }
        else if btnTag == 2 {
            selectedSortCategory = "Approved"
            imgPending.image = UIImage(named: "RadioOFF")
            imgApprove.image = UIImage(named: "RadioON")
            imgCancel.image = UIImage(named: "RadioOFF")
        }
        else if btnTag == 3 {
            selectedSortCategory = "Cancelled"
            imgPending.image = UIImage(named: "RadioOFF")
            imgApprove.image = UIImage(named: "RadioOFF")
            imgCancel.image = UIImage(named: "RadioON")
        }
        getUpdatedTicketListFromDB()
    }
    
    
    
    func newupdatedListFromb() {
        
        
        
    }
    
    func getUpdatedTicketListFromDB()  {
        self.ticketListArray.removeAllObjects()
        self.getTicketList() { ticketListArray in
            print(ticketListArray)
            if ticketListArray.count > 0 {
                self.lblNoTicket.isHidden = true
                self.tblView.isHidden = false
             //   self.ticketListArray = ticketListArray
                
                for index in 0..<ticketListArray.count {
                    let data : NSDictionary = ticketListArray.object(at: index) as! NSDictionary
//                    if (data["status"] as! String == self.selectedSortCategory) {
//                        self.ticketListArray.add(data)
//                    }
                    
                    if !(data["status"] as! String == "Cancelled") {
                        self.ticketListArray.add(data)
                    }
                }
                
                self.tblView.reloadData()
                
                if self.isFromAdmin {
//                    self.getSecondTicketList() { ticketListArray in
//                        print(ticketListArray)
//                        if ticketListArray.count > 0 {
//                            self.lblNoTicket.isHidden = true
//                            self.tblView.isHidden = false
//                           // self.ticketListArray.addObjects(from: ticketListArray as! [Any])
//                          //  self.ticketListArray = ticketListArray
//                            for index in 0..<ticketListArray.count {
//                                let data : NSDictionary = ticketListArray.object(at: index) as! NSDictionary
////                                if (data["status"] as! String == self.selectedSortCategory) {
////                                    self.ticketListArray.add(data)
////                                }
//                                
//                                if !(data["status"] as! String == "Cancelled") {
//                                    self.ticketListArray.add(data)
//                                }
//                            }
//                            
//                            self.tblView.reloadData()
//                        }
//                     }
                 }
                
            }
            else {
                self.lblNoTicket.isHidden = false
                self.tblView.isHidden = true
                
                
                if self.isFromAdmin {
//                    self.getSecondTicketList() { ticketListArray in
//                        print(ticketListArray)
//                        if ticketListArray.count > 0 {
//                            self.lblNoTicket.isHidden = true
//                            self.tblView.isHidden = false
//                            //self.ticketListArray = ticketListArray
//
//                            for index in 0..<ticketListArray.count {
//                                let data : NSDictionary = ticketListArray.object(at: index) as! NSDictionary
////                                if (data["status"] as! String == self.selectedSortCategory) {
////                                    self.ticketListArray.add(data)
////                                }
//                                if !(data["status"] as! String == "Cancelled") {
//                                    self.ticketListArray.add(data)
//                                }
//
//                            }
//
//                            self.tblView.reloadData()
//                        }
//                }
            }
             
                
        }
      }
    }
    
    
    func getSecondTicketList(completion: @escaping (_ ticketListArray : NSMutableArray) -> Void) {
        
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMYYYY"
        let selectedDateVal = dateFormatter.string(from:self.selectedDate)
        
        if isStatTimeSort {
            let bookingRef =   db.collection("manageBooking").whereField("bookingDate", isEqualTo: selectedDateVal).whereField("tripReturnTime", isEqualTo: self.tripStartTime).whereField("startDeparting", isEqualTo: false).order(by: "bookingDateTimeStamp")
            
            
            
            let ticketArray =  NSMutableArray()
            bookingRef.getDocuments() { (querySnapshot, err) in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            
                            let status = (data["status"] as! String)
                            let adultCount : Int = Int(data["adult"] as! String)!
                            let minorCount : Int = Int(data["minor"] as! String)!
                            
                            if status == "Pending" {
                                self.adultReservedCount = self.adultReservedCount + adultCount
                                self.minorReservedCount = self.minorReservedCount + minorCount
                                self.pendingCount = self.pendingCount + adultCount + minorCount
                            }
                            else if status == "Approved" {
                                self.adultReservedCount = self.adultReservedCount + adultCount
                                self.minorReservedCount = self.minorReservedCount + minorCount
                                self.approveCount = self.approveCount + adultCount + minorCount
                                
                                self.adultOnBoardCount =  self.adultOnBoardCount + adultCount
                                self.minorOnBoardCount =  self.minorOnBoardCount + minorCount
                            }
                            else if status == "Cancelled" {
                                self.cancelCount = self.cancelCount + adultCount + minorCount
                            }
                            
                            let startDeparting : Bool = (data["startDeparting"] as! Bool)
                            let startDepartureStatus = (data["startDepartureStatus"] as! String)
                            let returnDepartureStatus = (data["returnDepartureStatus"] as! String)
                            print(startDeparting)
                            if startDeparting {
                                if status == "Pending" {
                                    self.bsDeparturePendingCount = self.bsDeparturePendingCount + adultCount + minorCount
                                    
                                    self.bsDepartureAdultReservedCount =  self.bsDepartureAdultReservedCount + adultCount
                                    
                                    self.bsDepartureMinorReservedCount =  self.bsDepartureMinorReservedCount + minorCount
                                   
                                    
                                }
                                else if status == "Approved" {
                                    self.bsDepartureApprovedCount = self.bsDepartureApprovedCount + adultCount + minorCount
                                    
                                    self.bsDepartureAdultReservedCount =  self.bsDepartureAdultReservedCount + adultCount
                                    
                                    self.bsDepartureMinorReservedCount =  self.bsDepartureMinorReservedCount + minorCount
                                    
                                    
                                    self.bsDepartureAdultApprovedCount =  self.bsDepartureAdultApprovedCount + adultCount
                                    
                                    self.bsDepartureMinorApprovedCount =  self.bsDepartureMinorApprovedCount + minorCount
                                    
                                }
                                else if status == "Cancelled" {
                                    self.bsDepartureAdultCancelledCount =  self.bsDepartureAdultCancelledCount + adultCount
                                    
                                    self.bsDepartureMinorCancelledCount =  self.bsDepartureMinorCancelledCount + minorCount
                                }
                            }
                            else {
                                if status == "Pending" {
                                    self.mbDeparturePendingCount = self.mbDeparturePendingCount + adultCount + minorCount
                                    
                                    self.mbDepartureAdultReservedCount =  self.mbDepartureAdultReservedCount + adultCount
                                    
                                    self.mbDepartureMinorReservedCount =  self.mbDepartureMinorReservedCount + minorCount
                                    
                                }
                                else if status == "Approved" {
                                    self.mbDepartureApprovedCount = self.mbDepartureApprovedCount + adultCount + minorCount
                                    
                                    self.mbDepartureAdultReservedCount =  self.mbDepartureAdultReservedCount + adultCount
                                    
                                    self.mbDepartureMinorReservedCount =  self.mbDepartureMinorReservedCount + minorCount
                                    
                                    self.mbDepartureAdultApprovedCount =  self.mbDepartureAdultApprovedCount + adultCount
                                    
                                    self.mbDepartureMinorApprovedCount =  self.mbDepartureMinorApprovedCount + minorCount
                                    
                                }
                                else if status == "Cancelled" {
                                    self.mbDepartureAdultCancelledCount =  self.mbDepartureAdultCancelledCount + adultCount
                                    
                                    self.mbDepartureMinorCancelledCount =  self.mbDepartureMinorCancelledCount + minorCount
                                }
                            }
                            
                            self.lblBSReservedSeatsCount.text = String("\("BS Reserved Seats A: ")\(self.bsDepartureAdultReservedCount)\(" M: ")\(self.bsDepartureMinorReservedCount)\(" Total: ")\(self.bsDepartureMinorReservedCount + self.bsDepartureAdultReservedCount)")
                            
                            self.lblBSOnBoardCount.text = String("\("BS OnBoard A: ")\(self.bsDepartureAdultApprovedCount)\(" M:  ")\(self.bsDepartureMinorApprovedCount)\(" Total: ")\(self.bsDepartureAdultApprovedCount + self.bsDepartureMinorApprovedCount)")
                            
                            self.lblBSNoShowCount.text = String("\("BS Boarded A: ")\(self.bsDepartureAdultReservedCount - self.bsDepartureAdultApprovedCount)\(" M:  ")\(self.bsDepartureMinorReservedCount - self.bsDepartureMinorApprovedCount)")
                            
                            self.lblBSCancelledCount.text = String("\("BS Cancelled A: ")\(self.bsDepartureAdultCancelledCount)\(" M:  ")\(self.bsDepartureMinorCancelledCount)\(" Total: ")\(self.bsDepartureAdultCancelledCount + self.bsDepartureMinorCancelledCount)")
                            
                            self.lblMBReservedSeatsCount.text = String("\("MB Reserved Seats A: ")\(self.mbDepartureAdultReservedCount)\(" M: ")\(self.mbDepartureMinorReservedCount)\(" Total: ")\(self.mbDepartureMinorReservedCount + self.mbDepartureAdultReservedCount)")
                            
                            self.lblMBOnBoardCount.text = String("\("MB OnBoard A: ")\(self.mbDepartureAdultApprovedCount)\(" M:  ")\(self.mbDepartureMinorApprovedCount)\(" Total: ")\(self.mbDepartureAdultApprovedCount + self.mbDepartureMinorApprovedCount)")
                            
                            self.lblMBNoShowCount.text = String("\("MB Boarded A: ")\(self.mbDepartureAdultReservedCount - self.mbDepartureAdultApprovedCount)\(" M:  ")\(self.mbDepartureMinorReservedCount - self.mbDepartureMinorApprovedCount)")
                            
                            self.lblMBCancelledCount.text = String("\("MB Cancelled A: ")\(self.mbDepartureAdultCancelledCount)\(" M:  ")\(self.mbDepartureMinorCancelledCount)\(" Total: ")\(self.mbDepartureAdultCancelledCount + self.mbDepartureMinorCancelledCount)")
                            
                            
                            
                          //  if (data["status"] as! String == "Pending") {
                                ticketArray.add(data)
                          //  }
                        }
                    }
                completion(ticketArray)
            }
        }
        else {
            let bookingRef =   db.collection("manageBooking").whereField("bookingDate", isEqualTo: selectedDateVal).whereField("tripReturnTime", isEqualTo: self.tripStartTime).whereField("startDeparting", isEqualTo: true).order(by: "bookingDateTimeStamp")
            
            let ticketArray =  NSMutableArray()
            bookingRef.getDocuments() { (querySnapshot, err) in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            
                            let status = (data["status"] as! String)
                            let adultCount : Int = Int(data["adult"] as! String)!
                            let minorCount : Int = Int(data["minor"] as! String)!
                            
                            
                            if status == "Pending" {
                                self.adultReservedCount = self.adultReservedCount + adultCount
                                self.minorReservedCount = self.minorReservedCount + minorCount
                                self.pendingCount = self.pendingCount + adultCount + minorCount
                            }
                            else if status == "Approved" {
                                self.adultReservedCount = self.adultReservedCount + adultCount
                                self.minorReservedCount = self.minorReservedCount + minorCount
                                self.approveCount = self.approveCount + adultCount + minorCount
                                
                                self.adultOnBoardCount =  self.adultOnBoardCount + adultCount
                                self.minorOnBoardCount =  self.minorOnBoardCount + minorCount
                                
                            }
                            else if status == "Cancelled" {
                                self.cancelCount = self.cancelCount + adultCount + minorCount
                            }
                            
                            let startDeparting : Bool = (data["startDeparting"] as! Bool)
                            let startDepartureStatus = (data["startDepartureStatus"] as! String)
                            let returnDepartureStatus = (data["returnDepartureStatus"] as! String)
                            print(startDeparting)
                            if startDeparting {
                                if status == "Pending" {
                                    self.bsDeparturePendingCount = self.bsDeparturePendingCount + adultCount + minorCount
                                    
                                    self.bsDepartureAdultReservedCount =  self.bsDepartureAdultReservedCount + adultCount
                                    
                                    self.bsDepartureMinorReservedCount =  self.bsDepartureMinorReservedCount + minorCount
                                   
                                    
                                }
                                else if status == "Approved" {
                                    self.bsDepartureApprovedCount = self.bsDepartureApprovedCount + adultCount + minorCount
                                    
                                    self.bsDepartureAdultReservedCount =  self.bsDepartureAdultReservedCount + adultCount
                                    
                                    self.bsDepartureMinorReservedCount =  self.bsDepartureMinorReservedCount + minorCount
                                    
                                    
                                    self.bsDepartureAdultApprovedCount =  self.bsDepartureAdultApprovedCount + adultCount
                                    
                                    self.bsDepartureMinorApprovedCount =  self.bsDepartureMinorApprovedCount + minorCount
                                    
                                }
                                else if status == "Cancelled" {
                                    self.bsDepartureAdultCancelledCount =  self.bsDepartureAdultCancelledCount + adultCount
                                    
                                    self.bsDepartureMinorCancelledCount =  self.bsDepartureMinorCancelledCount + minorCount
                                }
                            }
                            else {
                                if status == "Pending" {
                                    self.mbDeparturePendingCount = self.mbDeparturePendingCount + adultCount + minorCount
                                    
                                    self.mbDepartureAdultReservedCount =  self.mbDepartureAdultReservedCount + adultCount
                                    
                                    self.mbDepartureMinorReservedCount =  self.mbDepartureMinorReservedCount + minorCount
                                    
                                }
                                else if status == "Approved" {
                                    self.mbDepartureApprovedCount = self.mbDepartureApprovedCount + adultCount + minorCount
                                    
                                    self.mbDepartureAdultReservedCount =  self.mbDepartureAdultReservedCount + adultCount
                                    
                                    self.mbDepartureMinorReservedCount =  self.mbDepartureMinorReservedCount + minorCount
                                    
                                    self.mbDepartureAdultApprovedCount =  self.mbDepartureAdultApprovedCount + adultCount
                                    
                                    self.mbDepartureMinorApprovedCount =  self.mbDepartureMinorApprovedCount + minorCount
                                    
                                }
                                else if status == "Cancelled" {
                                    self.mbDepartureAdultCancelledCount =  self.mbDepartureAdultCancelledCount + adultCount
                                    
                                    self.mbDepartureMinorCancelledCount =  self.mbDepartureMinorCancelledCount + minorCount
                                }
                            }
                            
                            self.lblBSReservedSeatsCount.text = String("\("BS Reserved Seats A: ")\(self.bsDepartureAdultReservedCount)\(" M: ")\(self.bsDepartureMinorReservedCount)\(" Total: ")\(self.bsDepartureMinorReservedCount + self.bsDepartureAdultReservedCount)")
                            
                            self.lblBSOnBoardCount.text = String("\("BS OnBoard A: ")\(self.bsDepartureAdultApprovedCount)\(" M:  ")\(self.bsDepartureMinorApprovedCount)\(" Total: ")\(self.bsDepartureAdultApprovedCount + self.bsDepartureMinorApprovedCount)")
                            
                            self.lblBSNoShowCount.text = String("\("BS Boarded A: ")\(self.bsDepartureAdultReservedCount - self.bsDepartureAdultApprovedCount)\(" M:  ")\(self.bsDepartureMinorReservedCount - self.bsDepartureMinorApprovedCount)")
                            
                            self.lblBSCancelledCount.text = String("\("BS Cancelled A: ")\(self.bsDepartureAdultCancelledCount)\(" M:  ")\(self.bsDepartureMinorCancelledCount)\(" Total: ")\(self.bsDepartureAdultCancelledCount + self.bsDepartureMinorCancelledCount)")
                            
                            self.lblMBReservedSeatsCount.text = String("\("MB Reserved Seats A: ")\(self.mbDepartureAdultReservedCount)\(" M: ")\(self.mbDepartureMinorReservedCount)\(" Total: ")\(self.mbDepartureMinorReservedCount + self.mbDepartureAdultReservedCount)")
                            
                            self.lblMBOnBoardCount.text = String("\("MB OnBoard A: ")\(self.mbDepartureAdultApprovedCount)\(" M:  ")\(self.mbDepartureMinorApprovedCount)\(" Total: ")\(self.mbDepartureAdultApprovedCount + self.mbDepartureMinorApprovedCount)")
                            
                            self.lblMBNoShowCount.text = String("\("MB Boarded A: ")\(self.mbDepartureAdultReservedCount - self.mbDepartureAdultApprovedCount)\(" M:  ")\(self.mbDepartureMinorReservedCount - self.mbDepartureMinorApprovedCount)")
                            
                            self.lblMBCancelledCount.text = String("\("MB Cancelled A: ")\(self.mbDepartureAdultCancelledCount)\(" M:  ")\(self.mbDepartureMinorCancelledCount)\(" Total: ")\(self.mbDepartureAdultCancelledCount + self.mbDepartureMinorCancelledCount)")
                            
                            
                            
                           // if (data["status"] as! String == "Pending") {
                                ticketArray.add(data)
                          //  }
                        }
                    }
                completion(ticketArray)
            }
        }
        
        
        
    }
    
    func getTicketList(completion: @escaping (_ ticketListArray : NSMutableArray) -> Void) {
        
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd/MM/YYYY"
        dateFormatter.dateFormat = "ddMMMYYYY"
        let selectedDateVal = dateFormatter.string(from:selectedDate)
        
        let todayDate = Utility.getTodayDateString()

        pendingCount = 0
        approveCount = 0
        cancelCount = 0
        bsDeparturePendingCount = 0
        bsDepartureApprovedCount = 0
        mbDeparturePendingCount = 0
        mbDepartureApprovedCount = 0
        
        if isFromAdmin {
            print(isticketBoardingPoint)
            print(tripStartTime)
            
            
            //startDeparting

            
            
            if isStatTimeSort {
//                let bookingRef =   db.collection("manageBooking").whereField("bookingDate", isEqualTo: selectedDateVal).whereField("tripStartTime", isEqualTo: tripStartTime).whereField("startDeparting", isEqualTo: true).order(by: "bookingDateTimeStamp")
                
                let bookingRef = db.collection("bookings").document("\(self.taxiData["ID"]!)\(selectedDateVal)\(tripStartTime)")
               print("\(self.taxiData["ID"]!)\(selectedDateVal)\(tripStartTime)")
              print(bookingRef)
                
                let ticketArray =  NSMutableArray()
                bookingRef.getDocument { (document, err) in
                        Utility.hideActivityIndicator()
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            
                            let ticketListArray =  NSMutableArray()
                            if let documentDict = document?.data() {
//                                let data = document.data()
                                
                                for (_,value) in documentDict {
                                    let item = value as? Dictionary<String,Any>
                                    ticketListArray.add(item ?? [:])
                                }
                                
                                for i in 0..<ticketListArray.count {
                                    
                                    let data = ticketListArray[i] as? Dictionary<String,Any> ?? [:]
                                
                                print(data)
                                let status = (data["status"] as! String)
                                let adultCount : Int = Int(data["adult"] as! String)!
                                let minorCount : Int = Int(data["minor"] as! String)!
                                
                                if status == "Pending" {
                                    self.adultReservedCount = self.adultReservedCount + adultCount
                                    self.minorReservedCount = self.minorReservedCount + minorCount
                                    self.pendingCount = self.pendingCount + adultCount + minorCount
                                }
                                else if status == "Approved" {
                                    self.adultReservedCount = self.adultReservedCount + adultCount
                                    self.minorReservedCount = self.minorReservedCount + minorCount
                                    self.approveCount = self.approveCount + adultCount + minorCount
                                    
                                    self.adultOnBoardCount =  self.adultOnBoardCount + adultCount
                                    self.minorOnBoardCount =  self.minorOnBoardCount + minorCount
                                    
                                }
                                else if status == "Cancelled" {
                                    self.cancelCount = self.cancelCount + adultCount + minorCount
                                }
                                
                                let startDeparting : Bool = (data["startDeparting"] as! Bool)
                                let startDepartureStatus = (data["startDepartureStatus"] as! String)
                                let returnDepartureStatus = (data["returnDepartureStatus"] as! String)
                                print(startDeparting)
                                if startDeparting {
                                    if status == "Pending" {
                                        self.bsDeparturePendingCount = self.bsDeparturePendingCount + adultCount + minorCount
                                        
                                        self.bsDepartureAdultReservedCount =  self.bsDepartureAdultReservedCount + adultCount
                                        
                                        self.bsDepartureMinorReservedCount =  self.bsDepartureMinorReservedCount + minorCount
                                       
                                        
                                    }
                                    else if status == "Approved" {
                                        self.bsDepartureApprovedCount = self.bsDepartureApprovedCount + adultCount + minorCount
                                        
                                        self.bsDepartureAdultReservedCount =  self.bsDepartureAdultReservedCount + adultCount
                                        
                                        self.bsDepartureMinorReservedCount =  self.bsDepartureMinorReservedCount + minorCount
                                        
                                        
                                        self.bsDepartureAdultApprovedCount =  self.bsDepartureAdultApprovedCount + adultCount
                                        
                                        self.bsDepartureMinorApprovedCount =  self.bsDepartureMinorApprovedCount + minorCount
                                        
                                    }
                                    else if status == "Cancelled" {
                                        self.bsDepartureAdultCancelledCount =  self.bsDepartureAdultCancelledCount + adultCount
                                        
                                        self.bsDepartureMinorCancelledCount =  self.bsDepartureMinorCancelledCount + minorCount
                                    }
                                }
                                else {
                                    if status == "Pending" {
                                        self.mbDeparturePendingCount = self.mbDeparturePendingCount + adultCount + minorCount
                                        
                                        self.mbDepartureAdultReservedCount =  self.mbDepartureAdultReservedCount + adultCount
                                        
                                        self.mbDepartureMinorReservedCount =  self.mbDepartureMinorReservedCount + minorCount
                                        
                                    }
                                    else if status == "Approved" {
                                        self.mbDepartureApprovedCount = self.mbDepartureApprovedCount + adultCount + minorCount
                                        
                                        self.mbDepartureAdultReservedCount =  self.mbDepartureAdultReservedCount + adultCount
                                        
                                        self.mbDepartureMinorReservedCount =  self.mbDepartureMinorReservedCount + minorCount
                                        
                                        self.mbDepartureAdultApprovedCount =  self.mbDepartureAdultApprovedCount + adultCount
                                        
                                        self.mbDepartureMinorApprovedCount =  self.mbDepartureMinorApprovedCount + minorCount
                                        
                                    }
                                    else if status == "Cancelled" {
                                        self.mbDepartureAdultCancelledCount =  self.mbDepartureAdultCancelledCount + adultCount
                                        
                                        self.mbDepartureMinorCancelledCount =  self.mbDepartureMinorCancelledCount + minorCount
                                    }
                                }
                               
                                self.lblBSReservedSeatsCount.text = String("\("BS Reserved Seats A: ")\(self.bsDepartureAdultReservedCount)\(" M: ")\(self.bsDepartureMinorReservedCount)\(" Total: ")\(self.bsDepartureMinorReservedCount + self.bsDepartureAdultReservedCount)")
                                
                                self.lblBSOnBoardCount.text = String("\("BS OnBoard A: ")\(self.bsDepartureAdultApprovedCount)\(" M:  ")\(self.bsDepartureMinorApprovedCount)\(" Total: ")\(self.bsDepartureAdultApprovedCount + self.bsDepartureMinorApprovedCount)")
                                
                                self.lblBSNoShowCount.text = String("\("BS Boarded A: ")\(self.bsDepartureAdultReservedCount - self.bsDepartureAdultApprovedCount)\(" M:  ")\(self.bsDepartureMinorReservedCount - self.bsDepartureMinorApprovedCount)")
                                
                                self.lblBSCancelledCount.text = String("\("BS Cancelled A: ")\(self.bsDepartureAdultCancelledCount)\(" M:  ")\(self.bsDepartureMinorCancelledCount)\(" Total: ")\(self.bsDepartureAdultCancelledCount + self.bsDepartureMinorCancelledCount)")
                                
                                self.lblMBReservedSeatsCount.text = String("\("MB Reserved Seats A: ")\(self.mbDepartureAdultReservedCount)\(" M: ")\(self.mbDepartureMinorReservedCount)\(" Total: ")\(self.mbDepartureMinorReservedCount + self.mbDepartureAdultReservedCount)")
                                
                                self.lblMBOnBoardCount.text = String("\("MB OnBoard A: ")\(self.mbDepartureAdultApprovedCount)\(" M:  ")\(self.mbDepartureMinorApprovedCount)\(" Total: ")\(self.mbDepartureAdultApprovedCount + self.mbDepartureMinorApprovedCount)")
                                
                                self.lblMBNoShowCount.text = String("\("MB Boarded A: ")\(self.mbDepartureAdultReservedCount - self.mbDepartureAdultApprovedCount)\(" M:  ")\(self.mbDepartureMinorReservedCount - self.mbDepartureMinorApprovedCount)")
                                
                                self.lblMBCancelledCount.text = String("\("MB Cancelled A: ")\(self.mbDepartureAdultCancelledCount)\(" M:  ")\(self.mbDepartureMinorCancelledCount)\(" Total: ")\(self.mbDepartureAdultCancelledCount + self.mbDepartureMinorCancelledCount)")
                                
                                ticketArray.add(data)
                                
                            }
                            }
                        }
                    completion(ticketArray)
                }
            }
            else {
//                let bookingRef =   db.collection("manageBooking").whereField("bookingDate", isEqualTo: selectedDateVal).whereField("tripStartTime", isEqualTo: tripStartTime).whereField("startDeparting", isEqualTo: false).order(by: "bookingDateTimeStamp")
//
//                let ticketArray =  NSMutableArray()
//                bookingRef.getDocuments() { (querySnapshot, err) in
//                        Utility.hideActivityIndicator()
//                        if let err = err {
//                            print("Error getting documents: \(err)")
//                        } else {
//                            for document in querySnapshot!.documents {
//                                let data = document.data()
                let bookingRef = db.collection("bookings").document("\(self.taxiData["ID"]!)\(selectedDateVal)\(tripStartTime)")
                
                
                
                let ticketArray =  NSMutableArray()
                bookingRef.getDocument { (document, err) in
                        Utility.hideActivityIndicator()
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            
                            let ticketListArray =  NSMutableArray()
                            if let documentDict = document?.data() {
//                                let data = document.data()
                                
                                for (_,value) in documentDict {
                                    let item = value as? Dictionary<String,Any>
                                    ticketListArray.add(item ?? [:])
                                }
                                
                                for i in 0..<ticketListArray.count {
                                    
                                    let data = ticketListArray[i] as? Dictionary<String,Any> ?? [:]
                                let status = (data["status"] as! String)
                                let adultCount : Int = Int(data["adult"] as! String)!
                                let minorCount : Int = Int(data["minor"] as! String)!
                                
                                
                                if status == "Pending" {
                                    self.adultReservedCount = self.adultReservedCount + adultCount
                                    self.minorReservedCount = self.minorReservedCount + minorCount
                                    self.pendingCount = self.pendingCount + adultCount + minorCount
                                }
                                else if status == "Approved" {
                                    self.adultReservedCount = self.adultReservedCount + adultCount
                                    self.minorReservedCount = self.minorReservedCount + minorCount
                                    self.approveCount = self.approveCount + adultCount + minorCount
                                    
                                    self.adultOnBoardCount =  self.adultOnBoardCount + adultCount
                                    self.minorOnBoardCount =  self.minorOnBoardCount + minorCount
                                }
                                else if status == "Cancelled" {
                                    self.cancelCount = self.cancelCount + adultCount + minorCount
                                }
                                
                                let startDeparting : Bool = (data["startDeparting"] as! Bool)
                                let startDepartureStatus = (data["startDepartureStatus"] as! String)
                                let returnDepartureStatus = (data["returnDepartureStatus"] as! String)
                                print(startDeparting)
                                if startDeparting {
                                    if status == "Pending" {
                                        self.bsDeparturePendingCount = self.bsDeparturePendingCount + adultCount + minorCount
                                        
                                        self.bsDepartureAdultReservedCount =  self.bsDepartureAdultReservedCount + adultCount
                                        
                                        self.bsDepartureMinorReservedCount =  self.bsDepartureMinorReservedCount + minorCount
                                       
                                        
                                    }
                                    else if status == "Approved" {
                                        self.bsDepartureApprovedCount = self.bsDepartureApprovedCount + adultCount + minorCount
                                        
                                        self.bsDepartureAdultReservedCount =  self.bsDepartureAdultReservedCount + adultCount
                                        
                                        self.bsDepartureMinorReservedCount =  self.bsDepartureMinorReservedCount + minorCount
                                        
                                        
                                        self.bsDepartureAdultApprovedCount =  self.bsDepartureAdultApprovedCount + adultCount
                                        
                                        self.bsDepartureMinorApprovedCount =  self.bsDepartureMinorApprovedCount + minorCount
                                        
                                    }
                                    else if status == "Cancelled" {
                                        self.bsDepartureAdultCancelledCount =  self.bsDepartureAdultCancelledCount + adultCount
                                        
                                        self.bsDepartureMinorCancelledCount =  self.bsDepartureMinorCancelledCount + minorCount
                                    }
                                }
                                else {
                                    if status == "Pending" {
                                        self.mbDeparturePendingCount = self.mbDeparturePendingCount + adultCount + minorCount
                                        
                                        self.mbDepartureAdultReservedCount =  self.mbDepartureAdultReservedCount + adultCount
                                        
                                        self.mbDepartureMinorReservedCount =  self.mbDepartureMinorReservedCount + minorCount
                                        
                                    }
                                    else if status == "Approved" {
                                        self.mbDepartureApprovedCount = self.mbDepartureApprovedCount + adultCount + minorCount
                                        
                                        self.mbDepartureAdultReservedCount =  self.mbDepartureAdultReservedCount + adultCount
                                        
                                        self.mbDepartureMinorReservedCount =  self.mbDepartureMinorReservedCount + minorCount
                                        
                                        self.mbDepartureAdultApprovedCount =  self.mbDepartureAdultApprovedCount + adultCount
                                        
                                        self.mbDepartureMinorApprovedCount =  self.mbDepartureMinorApprovedCount + minorCount
                                        
                                    }
                                    else if status == "Cancelled" {
                                        self.mbDepartureAdultCancelledCount =  self.mbDepartureAdultCancelledCount + adultCount
                                        
                                        self.mbDepartureMinorCancelledCount =  self.mbDepartureMinorCancelledCount + minorCount
                                    }
                                }
                                
                                self.lblBSReservedSeatsCount.text = String("\("BS Reserved Seats A: ")\(self.bsDepartureAdultReservedCount)\(" M: ")\(self.bsDepartureMinorReservedCount)\(" Total: ")\(self.bsDepartureMinorReservedCount + self.bsDepartureAdultReservedCount)")
                                
                                self.lblBSOnBoardCount.text = String("\("BS OnBoard A: ")\(self.bsDepartureAdultApprovedCount)\(" M:  ")\(self.bsDepartureMinorApprovedCount)\(" Total: ")\(self.bsDepartureAdultApprovedCount + self.bsDepartureMinorApprovedCount)")
                                
                                self.lblBSNoShowCount.text = String("\("BS Boarded A: ")\(self.bsDepartureAdultReservedCount - self.bsDepartureAdultApprovedCount)\(" M:  ")\(self.bsDepartureMinorReservedCount - self.bsDepartureMinorApprovedCount)")
                                
                                self.lblBSCancelledCount.text = String("\("BS Cancelled A: ")\(self.bsDepartureAdultCancelledCount)\(" M:  ")\(self.bsDepartureMinorCancelledCount)\(" Total: ")\(self.bsDepartureAdultCancelledCount + self.bsDepartureMinorCancelledCount)")
                                
                                self.lblMBReservedSeatsCount.text = String("\("MB Reserved Seats A: ")\(self.mbDepartureAdultReservedCount)\(" M: ")\(self.mbDepartureMinorReservedCount)\(" Total: ")\(self.mbDepartureMinorReservedCount + self.mbDepartureAdultReservedCount)")
                                
                                self.lblMBOnBoardCount.text = String("\("MB OnBoard A: ")\(self.mbDepartureAdultApprovedCount)\(" M:  ")\(self.mbDepartureMinorApprovedCount)\(" Total: ")\(self.mbDepartureAdultApprovedCount + self.mbDepartureMinorApprovedCount)")
                                
                                self.lblMBNoShowCount.text = String("\("MB Boarded A: ")\(self.mbDepartureAdultReservedCount - self.mbDepartureAdultApprovedCount)\(" M:  ")\(self.mbDepartureMinorReservedCount - self.mbDepartureMinorApprovedCount)")
                                
                                self.lblMBCancelledCount.text = String("\("MB Cancelled A: ")\(self.mbDepartureAdultCancelledCount)\(" M:  ")\(self.mbDepartureMinorCancelledCount)\(" Total: ")\(self.mbDepartureAdultCancelledCount + self.mbDepartureMinorCancelledCount)")
                                
                               // if (data["status"] as! String == "Pending") {
                                    ticketArray.add(data)
                                }
                            }
                        }
                    completion(ticketArray)
                }
            }
        }
        else {
//            let bookingRef =   db.collection("manageBooking").whereField("bookingDate", isEqualTo: selectedDateVal).whereField("agentName", isEqualTo: CurrentUserInfo.name!).whereField("tripStartTime", isEqualTo: tripStartTime).order(by: "bookingDateTimeStamp")
//            let ticketArray =  NSMutableArray()
//
//            bookingRef.getDocuments() { (querySnapshot, err) in
//                    Utility.hideActivityIndicator()
//                    if let err = err {
//                        print("Error getting documents: \(err)")
//                    } else {
//                        for document in querySnapshot!.documents {
//                            let data = document.data()
            let bookingRef = db.collection("bookings").document("\(self.taxiData["ID"]!)\(selectedDateVal)\(tripStartTime)")
            
            
            
            let ticketArray =  NSMutableArray()
            bookingRef.getDocument { (document, err) in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        
                        let ticketListArray =  NSMutableArray()
                        if let documentDict = document?.data() {
//                                let data = document.data()
                            
                            for (_,value) in documentDict {
                                let item = value as? Dictionary<String,Any>
                                ticketListArray.add(item ?? [:])
                            }
                            
                            for i in 0..<ticketListArray.count {
                                
                                let data = ticketListArray[i] as? Dictionary<String,Any> ?? [:]
                            
                         //   if (data["status"] as! String == "Pending") {
                                ticketArray.add(data)
                            }
                        }
                    }
                completion(ticketArray)
            }
        }
    }
    
    func updateTicketStatus(_ ticketID : String , _ checkBookingStatus: String) {
        //Cancel Ticket Status
        let db = Firestore.firestore()
        let ticketRef = db.collection("bookings").document(checkBookingStatus)
        ticketRef.getDocument { (document, error) in
            if let document = document, document.exists {
            
                var booking:Dictionary<String,Any> = [:]
                if let documentDict = document.data()  {
                    
                    for (key,_) in documentDict {
                        if key == ticketID {
                            booking = documentDict[key] as! Dictionary<String, Any>
                        }
                    }
                }
              
                booking["status"] = "Cancelled"
                ticketRef.updateData([
                    ticketID:booking
                ])
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func cancelBookedTicket(_ selectedIndex : Int) {
        Utility.showActivityIndicator()
        let data = ticketListArray.object(at: selectedIndex) as! NSDictionary
        print(data)
        let db = Firestore.firestore()
        let ticketID = (data["ticketID"] as! String)
        let taxiId = data["taxiID"] as! String
        
        if let returnTime = data["tripReturnTime"] as? String {
            if returnTime != ""  {
                self.updateTicketStatus(ticketID,"\(taxiId)\( data["bookingDate"] as! String)\(returnTime)")
            }
            
        }
        self.updateTicketStatus(ticketID,"\(taxiId)\( data["bookingDate"] as! String)\( data["tripStartTime"] as! String)")
        
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
                
                
                
               // let startTimeArray : NSMutableArray = todayData["timingList"] as! NSMutableArray
               // let returnTimeArray : NSMutableArray = todayData["returnTimingList"] as! NSMutableArray
                
                
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
                
                print(returnTimeArray)
                print(startTimeArray)
                for index in 0..<startTimeArray.count {
                    let data = startTimeArray.object(at: index) as! NSDictionary
                    if (data["time"] as! String) == tripStartTime {
                        let alreadyBooked = (data["alreadyBooked"] as! Int)
                        
                        var newCount : Int = alreadyBooked - totalSeatsToCancel
                        
                        if newCount <= 0 {
                            newCount = 0
                        }
                        
                        print(startTimeArray.object(at: index) as! NSDictionary)
                        let newData : NSDictionary = ["alreadyBooked" :  newCount, "time" : tripStartTime]
                        
                        print(startTimeArray.object(at: index) as! NSDictionary)
                        print(newData)
                        startTimeArray.replaceObject(at: index, with: newData)
                        break
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
                        break
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
                
                print(newStartArr)
                print(newReturnArr)
                
                print(returnTimeArray)
                print(startTimeArray)
                
                
                docRef.updateData([
                    "timingList":newStartArr,
                    "returnTimingList":newReturnArr
                ]) { err in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error updating document: \(err)")
                        let vW = Utility.displaySwiftAlert("", "Error todayStat update, cancelling" , type: SwiftAlertType.error.rawValue)
                        SwiftMessages.show(view: vW)
                    } else {
                        print("Document successfully updated")
                        let vW = Utility.displaySwiftAlert("", "Ticket Cancelled & Stat Updtes" , type: SwiftAlertType.success.rawValue)
                        SwiftMessages.show(view: vW)
                        
                        //self.getUpdatedTicketListFromDB()
                        
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginWithPinVC") as! LoginWithPinVC
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                        /*
                        if self.isFromAdmin {
                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                            vc.isFromAdmin = true
                            vc.isAgentEditTicket = false
                            Constant.currentUserFlow = "Admin"
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        else {
                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
                            vc.isFromAdmin = false
                            vc.isAgentEditTicket = false
                            Constant.currentUserFlow = "Agent"
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        */
                        
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
        print(data)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
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
        
        cell.lblStartDepartureStatus.text =  String("\("Start Departure: \((data["startDepartureStatus"] as? String) ?? "Pending")")")
        cell.lblReturnDepartureStatus.text =  String("\("Return Departure: \((data["returnDepartureStatus"] as? String) ?? "Pending")")")
       
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
        /*
         if bookingStatus == "Pending"  && startDepartureStatus == "Pending" && returnDepartureStatus == "Pending" {
             return true
         }
         else {
             return false
         }*/
        
        if bookingStatus == "Pending"  {
            return true
        }
        else {
            return false
        }
        
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let cancel = UIContextualAction(style: .normal, title:  "Cancel", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in

            self.showCancelAlert(indexPath.section)
            success(true)
        })
        cancel.backgroundColor = .red
       
        let edit = UIContextualAction(style: .normal, title:  "Edit", handler: { [self] (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            success(true)
            
            let data = ticketListArray.object(at: indexPath.section) as! NSDictionary
            
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
            vc.isStatTimeSort = isStatTimeSort;
            vc.isTicketEdit = true
            vc.ticketData = data
            vc.startAvailableSeats = 0
            vc.returnAvailableSeats = 0
            vc.selectedDate = selectedDate
            
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
            let isStartDeparting = (data["startDeparting"] as! Bool)
            
            let dictionary = ["bookingDate": todayDate, "bookingAgentID": bookingAgentID, "adult": adult, "minor": minor, "customerName": customerName, "customePhone": customePhone, "tripStartTime": tripStartTime,"tripReturnTime": tripReturnTime,"ticketID":ticketID,"startDeparting":isStartDeparting] as [String : Any]
            
            
            
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
            vc.departureDate = todayDate
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        qrImg.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [edit, qrImg, cancel])
    }

}
