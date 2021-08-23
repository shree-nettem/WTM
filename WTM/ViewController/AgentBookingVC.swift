//
//  AgentBookingVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 30/11/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SwiftMessages

class AgentBookingVC: UIViewController , UITextFieldDelegate , TimeSelectedDelegate , UITextViewDelegate {
    
    @IBOutlet weak var txtName : UITextField!
    @IBOutlet weak var txtPhone : UITextField!
    @IBOutlet weak var txtStartTime : UITextField!
    @IBOutlet weak var txtReturnTime : UITextField!
    @IBOutlet weak var txtAdults : UITextField!
    @IBOutlet weak var txtMinor : UITextField!
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtSquareCode : UITextField!
    @IBOutlet weak var txtComment : UITextView!
    @IBOutlet weak var baseViewHeigt : NSLayoutConstraint!
    var taxiData = NSDictionary()
    var weekDayTime = NSMutableArray()
    var weekendDayTime = NSMutableArray()
    var tripStartTime = String()
    var tripReturnTime = String()
    var returnTimeArray = NSArray()
    var isTicketEdit : Bool = false
    var ticketData = NSDictionary()
    var totalPaxToBook : Int = 0
    var taxiTotalSeats : Int = 0
    var isRoundTrip : Bool = true
    
    
    var editTicketStartTime = String()
    var editTicketReturnTime = String()
    
    var tripStartTimeArray = NSArray()
    var tripReturnTimeArray = NSArray()
    var dayOfWeek : Int = -1
    
    var countingArray : NSArray = [1,2,3,4,5,6,7,8,9,10]
    
    
    @IBOutlet weak var btnEditStartTime : UIButton!
    @IBOutlet weak var btnEditReturnTime : UIButton!
    var editSelectedTag : Int = 0
    
    var selectedDate = Date()
    
    var selectedAgentData = NSDictionary()
    var isAdminTicketBook : Bool = false
    
    
    var startAvailableSeats : Int = 0
    var returnAvailableSeats : Int = 0
    
    var bookedStartSeats : Int  = 0
    var bookedReturnSeats : Int  = 0
    
    var currentBookingSeats:Int = 0
    
    
    var isStatTimeSort : Bool = true
    
    
    @IBOutlet weak var lblDepartureTitle : UILabel!
    @IBOutlet weak var lblArrivalTitle : UILabel!
    
    
    var jsonString = String()
    var finalTicketID = String()
    var todayDate = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        print(taxiData)
        print(ticketData)
        
        print(startAvailableSeats)
        print(returnAvailableSeats)
        
        //Get Today Day Of Week   // 1 = Sunday, 2 = Monday, etc.
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        dayOfWeek = calendar.component(.weekday, from: today)
        print(dayOfWeek)
        
        print(tripStartTimeArray)
        print(tripReturnTimeArray)
        
        txtName.setLeftPaddingPoints(15.0)
        txtPhone.setLeftPaddingPoints(15.0)
        txtStartTime.setLeftPaddingPoints(15.0)
        txtReturnTime.setLeftPaddingPoints(15.0)
        txtAdults.setLeftPaddingPoints(15.0)
        txtMinor.setLeftPaddingPoints(15.0)
        txtEmail.setLeftPaddingPoints(15.0)
        txtSquareCode.setLeftPaddingPoints(15.0)
        
        txtComment.text = "Write your comment(Optional)"
        txtComment.textColor = UIColor.lightGray
        
        if isTicketEdit {
            isStatTimeSort = (ticketData["startDeparting"] as? Bool) ?? true
            btnEditStartTime.isHidden = false
            btnEditReturnTime.isHidden = false
            txtStartTime.isUserInteractionEnabled = false
            txtReturnTime.isUserInteractionEnabled = false
            
            print(ticketData)
            
            self.finalTicketID = (ticketData["ticketID"] as! String)
            getTaxiDetail()
            txtName.text = (ticketData["customerName"] as! String)
            txtPhone.text = (ticketData["customePhone"] as! String)
            txtStartTime.text = (ticketData["tripStartTime"] as! String)
            txtReturnTime.text = (ticketData["tripReturnTime"] as! String)
            
            editTicketStartTime = (ticketData["tripStartTime"] as! String)
            editTicketReturnTime = (ticketData["tripReturnTime"] as! String)
            
            txtAdults.text = (ticketData["adult"] as! String)
            txtMinor.text = (ticketData["minor"] as! String)
            txtEmail.text = (ticketData["email"] as! String)
            txtSquareCode.text = (ticketData["squareCode"] as? String) ?? ""
            let commentData = (ticketData["comment"] as? String) ?? "Write your comment(Optional)"
            
            if commentData == "Write your comment(Optional)" {
                txtComment.text = "Write your comment(Optional)"
                txtComment.textColor = UIColor.lightGray
            }
            else {
                txtComment.text = commentData
                txtComment.textColor = UIColor.black
            }
        }
        else {
            btnEditStartTime.isHidden = true
            btnEditReturnTime.isHidden = true
            
            txtStartTime.text = tripStartTime
            txtStartTime.isUserInteractionEnabled = false
            
            txtReturnTime.text = tripReturnTime
            txtReturnTime.isUserInteractionEnabled = false
        }
        
        print(isStatTimeSort)
        if isStatTimeSort {
            lblDepartureTitle.text = "Departing Time BS"
            lblArrivalTitle.text = "Departing Time MB"
        }
        else {
            lblDepartureTitle.text = "Departing Time MB"
            lblArrivalTitle.text = "Departing Time BS"
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        baseViewHeigt.constant = 400
    }
    
    func getTodayStatData() {
        
        var departurePostRef = String()
        var returnPostRef = String()
        
        print(self.taxiData)
        
        var adultVal = String()
        var minorVal = String()
        var agentID = String()
        var userName = String()
        var agentName = String()
        
        var departureSide = String()
        
        if self.txtAdults.text! == "" {
            adultVal = "0"
        }
        else {
            adultVal = self.txtAdults.text!
        }
        
        if self.txtMinor.text! == "" {
            minorVal = "0"
        }
        else {
            minorVal = self.txtMinor.text!
        }
        
        userName = self.txtName.text!
        
        
        print(self.isStatTimeSort)
        if self.isStatTimeSort {
            departureSide = "Bayside Beach"
        }
        else {
            departureSide = "Miami Beach"
        }
        
        
        let customerName = self.txtName.text!
        let customePhone = self.txtPhone.text!
        let tripStartTime = self.txtStartTime.text!
        let tripReturnTime = self.txtReturnTime.text!
        
        var oldtripCount = 0
        
        if self.isTicketEdit {
            let adult  = Int(ticketData["adult"] as! String)
            let minor = Int(ticketData["minor"] as! String)
            oldtripCount = (adult ?? 0) + (minor ?? 0)
        }
        
        
        
        
        let email = self.txtEmail.text!
        let comment = self.txtComment.text!
        
        let squareCode = self.txtSquareCode.text!
        
        self.currentBookingSeats = (Int(self.txtAdults.text!) ?? 0) + (Int(self.txtMinor.text!) ?? 0)
        
        print(self.currentBookingSeats)
        //        let seconds = Double.random(in: 0.0 ... 10.0)
        //        print(seconds)
        
        Utility.showActivityIndicator()
        //        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        // Put your code which should be executed with a delay here
        
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMYYYY"
        let selectedDateVal = dateFormatter.string(from:self.selectedDate)
        
        //        var taxiIDVal = String()
        
        if isStatTimeSort {
            lblDepartureTitle.text = "Departing Time BS"
            lblArrivalTitle.text = "Departing Time MB"
        }
        else {
            lblDepartureTitle.text = "Departing Time MB"
            lblArrivalTitle.text = "Departing Time BS"
        }
        
        if self.isTicketEdit {
            if isStatTimeSort {
                let bookingDate = (self.ticketData["bookingDate"] as! String)
                departurePostRef = String("\(self.ticketData["taxiID"]!)\(bookingDate)BS\(self.txtStartTime.text!)")
                returnPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDate)MB\(self.txtReturnTime.text!)")
            } else {
                let bookingDate = (self.ticketData["bookingDate"] as! String)
                departurePostRef = String("\(self.ticketData["taxiID"]!)\(bookingDate)MB\(self.txtStartTime.text!)")
                returnPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDate)BS\(self.txtReturnTime.text!)")
            }
        }
        else {
            if isStatTimeSort {
                departurePostRef = String("\(self.taxiData["ID"]!)\(selectedDateVal)BS\(self.txtStartTime.text!)")
                returnPostRef = String("\(self.taxiData["ID"]!)\(selectedDateVal)MB\(self.txtReturnTime.text!)")
            } else {
                departurePostRef = String("\(self.taxiData["ID"]!)\(selectedDateVal)MB\(self.txtStartTime.text!)")
                returnPostRef = String("\(self.taxiData["ID"]!)\(selectedDateVal)BS\(self.txtReturnTime.text!)")
            }
        }
        
        print(departurePostRef,returnPostRef)
        
        //        let bookingRef =  db.collection("todayStat").document(departurePostRef)
        
        //        let newBookingRef = db.collection("bookings").document("sam");
        //        let userJohn = db.collection("bookings").document("john");
        
        //        let departurePostRef = "\(self.ticketData["taxiID"] ?? "")\(self.txtStartTime.text ?? "")"
        
        
        //
        db.runTransaction { (transaction, error) -> Any? in
            
            let ref1 =  db.collection("bookings").document(departurePostRef)
            let ref2 =  db.collection("bookings").document(returnPostRef)
            
            
            let sfDocumentdepartureref: DocumentSnapshot
            let sfDocumentreturnref: DocumentSnapshot
            do {
                try sfDocumentdepartureref = transaction.getDocument(ref1)
                try sfDocumentreturnref = transaction.getDocument(ref2)
                
                
                if let totaldepartDoc = sfDocumentdepartureref.data()  {
                    
                    
                    self.bookedStartSeats = self.getTotalCount(BookingFile: totaldepartDoc)
                    
                    
                    if self.isTicketEdit {
                        self.startAvailableSeats = (self.taxiData["totalSeats"] as? Int ?? 0) - self.bookedStartSeats
                        if tripStartTime == self.editTicketStartTime {
                        self.startAvailableSeats += oldtripCount
                        }
                    } else {
                        self.startAvailableSeats = (self.taxiData["TotalSeats"] as? Int ?? 0) - self.bookedStartSeats
                    }
                    
                    
                } else {
                    self.bookedStartSeats = 0
                    
                    if self.isTicketEdit {
                        self.startAvailableSeats = (self.taxiData["totalSeats"] as? Int ?? 0)
                    } else {
                        self.startAvailableSeats = (self.taxiData["TotalSeats"] as? Int ?? 0)
                    }
                    
                }
                
                
                
                
                if let totalReturnDoc = sfDocumentreturnref.data() {
                    
                    self.bookedReturnSeats = self.getTotalCount(BookingFile: totalReturnDoc)
                    
                    if self.isTicketEdit {
                        self.returnAvailableSeats = (self.taxiData["totalSeats"] as? Int ?? 0) - self.bookedReturnSeats
                        if tripReturnTime == self.editTicketReturnTime {
                            self.returnAvailableSeats += oldtripCount
                        }
                        
                    } else {
                        self.returnAvailableSeats = (self.taxiData["TotalSeats"] as? Int ?? 0) - self.bookedReturnSeats
                    }
                    
                } else {
                    self.bookedReturnSeats = 0
                    if self.isTicketEdit {
                        self.returnAvailableSeats = (self.taxiData["totalSeats"] as? Int ?? 0)
                    } else {
                        self.returnAvailableSeats = (self.taxiData["TotalSeats"] as? Int ?? 0)
                    }
                    
                }
                
                
                
            } catch let fetchError as NSError {
                error?.pointee = fetchError
                return nil
            }
            
            print(self.startAvailableSeats, self.bookedStartSeats,self.returnAvailableSeats , self.bookedReturnSeats)
            
            
            if self.startAvailableSeats < self.currentBookingSeats {
                DispatchQueue.main.async {
                    let vW = Utility.displaySwiftAlert("", "Not enough seats available", type: SwiftAlertType.error.rawValue)
                    SwiftMessages.show(view: vW)
                    
                }
                let customError = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot"
                    ]
                )
                error?.pointee = customError
                return nil
            }
            
            
            // variables for booking object
            let timestamp = NSDate().timeIntervalSince1970
            let intVal : Int = Int(timestamp)
            print(self.selectedDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMMYYYY"
            let todayDateString =  dateFormatter.string(from: self.selectedDate)
            
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "dd/MM/YYYY"
            self.todayDate =  dateFormatter.string(from: self.selectedDate)
            
            
            
            var bookingObject:Dictionary<String,Any> = [:]
            //            DispatchQueue.main.async {
            
            
            var taxiID = String()
            if self.isTicketEdit {
                taxiID =  self.taxiData["taxiID"] as! String
                self.taxiTotalSeats = Int(truncating: self.taxiData["totalSeats"] as! NSNumber)
            }
            else {
                taxiID =  self.taxiData["ID"] as! String
                self.taxiTotalSeats = Int(truncating: self.taxiData["TotalSeats"] as! NSNumber)
            }
            
            
            if self.isAdminTicketBook {
                agentID = (self.selectedAgentData["userID"] as! String)
                agentName = (self.selectedAgentData["name"] as! String)
            }
            else {
                agentID = CurrentUserInfo.userID!
                agentName = CurrentUserInfo.name!
            }
            
            if self.isTicketEdit {
                agentID = (self.ticketData["bookingAgentID"] as! String)
                agentName = (self.ticketData["agentName"] as! String)
                
            }
            
            
            
            let numVal = String("\(intVal)")
            if !self.isTicketEdit {
                
                self.finalTicketID = String("\(userName.prefix(4))\("-")\(numVal.suffix(4))")
            }
            
            print(self.finalTicketID)
            
            //        totalPaxToBook = Int(adultVal)! + Int(minorVal)!
            
            if self.currentBookingSeats <= 0 {
                let vW = Utility.displaySwiftAlert("", "Passenger count must atleast one." , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            } else {
                let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
                var deviceType = String()
                // 2. check the idiom
                switch (deviceIdiom) {
                case .pad:
                    deviceType = "iPad"
                    print("iPad style UI")
                case .phone:
                    deviceType = "iPhone"
                    print("iPhone and iPod touch style UI")
                case .tv:
                    deviceType = "tvOS"
                    print("tvOS style UI")
                default:
                    deviceType = "Unspecified"
                    print("Unspecified UI idiom")
                }
                
                
                
                
                bookingObject = [
                    "bookingDate": self.todayDate,
                    "bookingAgentID": agentID,
                    "adult" : adultVal,
                    "minor" : minorVal,
                    "customerName" : customerName,
                    "customePhone" : customePhone,
                    "tripStartTime" : tripStartTime,
                    "tripReturnTime" : tripReturnTime,
                    "taxiID": taxiID,
                    "agentName": agentName,
                    "status":"Pending",
                    "ticketID":self.finalTicketID,
                    "bookingDateTimeStamp": FieldValue.serverTimestamp(),
                    "email":email,
                    "comment":comment,
                    "todayDateString":todayDateString,
                    "isAdminTicketBook":self.isAdminTicketBook,
                    "ticketDepartureSide":departureSide,
                    "startDeparting":self.isStatTimeSort,
                    "device":"IOS",
                    "startDepartureStatus":"Pending",
                    "returnDepartureStatus":"Pending",
                    "version":currentAppVersion!,
                    "deviceIdiom":deviceType,
                    "isRoundTrip":self.isRoundTrip,
                    "squareCode":squareCode,
                    "startDocumentPath": departurePostRef,
                    "returnDocumentPath": tripReturnTime != "" ? returnPostRef : ""
                ] as [String : Any]
                
                
            }
            
            
            
            if tripStartTime != self.editTicketStartTime {
                
//                if self.isTicketEdit {
//                } else {
                    if self.startAvailableSeats < self.currentBookingSeats {
                        DispatchQueue.main.async {
                            let vW = Utility.displaySwiftAlert("", "Not enough seats available", type: SwiftAlertType.error.rawValue)
                            SwiftMessages.show(view: vW)
                            
                        }
                        let customError = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot"
                            ]
                        )
                        error?.pointee = customError
                        return nil

                    }
//                }
               
            } else  {
//                if self.isTicketEdit {
//                } else {
                    if self.taxiTotalSeats < self.currentBookingSeats {
                        DispatchQueue.main.async {
                            let vW = Utility.displaySwiftAlert("", "Not enough seats available", type: SwiftAlertType.error.rawValue)
                            SwiftMessages.show(view: vW)
                            
                        }
                        let customError = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot"
                            ]
                        )
                        error?.pointee = customError
                        return nil

                    }
//                }
               
            }
            
            
            
            if self.isRoundTrip {
                
                if tripReturnTime != self.editTicketReturnTime {
//                    if self.isTicketEdit {
//                    } else {
                        if self.returnAvailableSeats < self.currentBookingSeats {
                            DispatchQueue.main.async {
                                let vW = Utility.displaySwiftAlert("", "Not enough return seats", type: SwiftAlertType.error.rawValue)
                                SwiftMessages.show(view: vW)
                                
                            }
                            let customError = NSError(
                                domain: "AppErrorDomain",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot"
                                ]
                            )
                            error?.pointee = customError
                            return nil

                        }
//                    }
                    
                }  else  {
//                    if self.isTicketEdit {
//                    } else {
                        if self.taxiTotalSeats < self.currentBookingSeats {
                            DispatchQueue.main.async {
                                let vW = Utility.displaySwiftAlert("", "Not enough return seats", type: SwiftAlertType.error.rawValue)
                                SwiftMessages.show(view: vW)
                               
                            }
                            let customError = NSError(
                                domain: "AppErrorDomain",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot"
                                ]
                            )
                            error?.pointee = customError
                            return nil

                        }
//                    }
                   
                }
                
                
                
                if self.isTicketEdit {
                    
                    
                    if self.editTicketStartTime == tripStartTime {
                        transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref1)
                    } else {
                        
                        
                        let bookingDateCancel = (self.ticketData["bookingDate"] as! String)
                        var departureCancelPostRef = String()
                        
                        if self.ticketData["ticketDepartureSide"] as? String == "Bayside Beach" {
                            
                            departureCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)BS\(self.editTicketStartTime)")
                        } else {
                            departureCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)MB\(self.editTicketStartTime)")
                        }
                        
//                        if self.isStatTimeSort {
//                            departureCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)BS\(self.editTicketStartTime)")
//                        } else  {
//                            departureCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)MB\(self.editTicketStartTime)")
//                        }
                            
                        
                        let refCancell1 =  db.collection("bookings").document(departureCancelPostRef)
                        
                        var cancelBookingObject = bookingObject
                        cancelBookingObject["status"] = "Cancelled"
                        cancelBookingObject["tripStartTime"] = self.editTicketStartTime
                        cancelBookingObject["tripReturnTime"] = self.editTicketReturnTime
                        
                        
                        transaction.updateData([self.finalTicketID: cancelBookingObject], forDocument: refCancell1)
                        
                        
                        if self.bookedStartSeats > 0  {
                            transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref1)
                        } else {
                            transaction.setData([self.finalTicketID: bookingObject], forDocument: ref1)
                        }
                        
                        
                        
                        
                    }
                    
                    
                    if self.editTicketReturnTime == tripReturnTime {
                        if tripReturnTime != "" {
                            transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref2)
                        }
                        
                    } else {
                        
                        let bookingDateCancel = (self.ticketData["bookingDate"] as! String)
                        
                        var returnCancelPostRef = String()
                        if self.ticketData["ticketDepartureSide"] as? String == "Bayside Beach" {
                            
                            returnCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)MB\(self.editTicketReturnTime)")
                        } else {
                            returnCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)BS\(self.editTicketReturnTime)")
                        }
//                        if self.isStatTimeSort {
//                            returnCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)MB\(self.editTicketReturnTime)")
//                        } else {
//                            returnCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)BS\(self.editTicketReturnTime)")
//                        }
                       
                        let refCancell2 =  db.collection("bookings").document(returnCancelPostRef)
                        
                        var cancelBookingObject = bookingObject
                        cancelBookingObject["status"] = "Cancelled"
                        cancelBookingObject["tripStartTime"] = self.editTicketStartTime
                        cancelBookingObject["tripReturnTime"] = self.editTicketReturnTime
                        
                        if self.editTicketReturnTime != "" {
                            transaction.updateData([self.finalTicketID: cancelBookingObject], forDocument: refCancell2)
                        }
                        
                       
                        
                        if self.bookedReturnSeats > 0  {
                            transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref2)
                        } else {
                            transaction.setData([self.finalTicketID: bookingObject], forDocument: ref2)
                        }
                        
                        
                        
                        //                        bookingObject["status"] = "Cancelled"
                        //                        transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref1)
                    }
                    
                    
                    
                    
                    
                } else {
                    if self.bookedStartSeats > 0  {
                        transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref1)
                    } else {
                        transaction.setData([self.finalTicketID: bookingObject], forDocument: ref1)
                    }
                    
                    if tripReturnTime != "" {
                        if self.bookedReturnSeats > 0  {
                            transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref2)
                        } else {
                            
                            transaction.setData([self.finalTicketID: bookingObject], forDocument: ref2)
                        }
                    }
                    
                }
                
                
                
                
            } else {
                if !self.isTicketEdit {
                    if self.bookedStartSeats > 0  {
                        transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref1)
                    } else {
                        transaction.setData([self.finalTicketID: bookingObject], forDocument: ref1)
                    }
                } else {
                    
                    if self.editTicketStartTime == tripStartTime {
                        transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref1)
                    } else {
                        
                        
                        let bookingDateCancel = (self.ticketData["bookingDate"] as! String)
                        var departureCancelPostRef = String()
                        if self.ticketData["ticketDepartureSide"] as? String == "Bayside Beach" {
                             departureCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)BS\(self.editTicketStartTime)")
                        } else {
                            departureCancelPostRef = String("\(self.ticketData["taxiID"]!)\(bookingDateCancel)MB\(self.editTicketStartTime)")
                        }
                        
                        let refCancell1 =  db.collection("bookings").document(departureCancelPostRef)
                        
                        var cancelBookingObject = bookingObject
                        cancelBookingObject["status"] = "Cancelled"
                        cancelBookingObject["tripStartTime"] = self.editTicketStartTime
                        
                        transaction.updateData([self.finalTicketID: cancelBookingObject], forDocument: refCancell1)
                        
                        
                        
                        if self.bookedStartSeats > 0  {
                            transaction.updateData([self.finalTicketID: bookingObject], forDocument: ref1)
                        } else {
                            transaction.setData([self.finalTicketID: bookingObject], forDocument: ref1)
                        }
                        
                        
                        
                        //
                    }
                    
                }
            }
            let dictionary = ["bookingDate": self.todayDate, "bookingAgentID": CurrentUserInfo.userID!, "adult": adultVal, "minor": minorVal, "customerName": customerName, "customePhone": customePhone, "tripStartTime": tripStartTime,"tripReturnTime": tripReturnTime,"ticketID":self.finalTicketID,"startDeparting":self.isStatTimeSort , "startDocumentPath": departurePostRef,"returnDocumentPath": tripReturnTime != "" ? returnPostRef : ""] as [String : Any]
            let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            self.jsonString = String(data: jsonData!, encoding: .utf8)!
            
            //            DispatchQueue.main.async {
            //                return nil
            //                let currentBookingSeats = (Int(self.txtAdults.text!) ?? 0) +  (Int(self.txtMinor.text!) ?? 0)
            //            }
            
            //
            //                if (self.taxiData["totalSeats"] as? Int ?? 0) < (self.bookedStartSeats + currentBookingSeats ) {
            //                    let vW = Utility.displaySwiftAlert("", "Not enough return seats", type: SwiftAlertType.error.rawValue)
            //                    SwiftMessages.show(view: vW)
            //                    return nil
            //                }
            //            }
            
            
         
            //            let sfDocument: DocumentSnapshot
            //            do {
            //                   try sfDocument = transaction.getDocument(bookingRef)
            //               } catch let fetchError as NSError {
            //                error?.pointee = fetchError
            //                   return nil
            //               }
            
            return nil
        } completion: { (object, error) in
            DispatchQueue.main.async {
                Utility.hideActivityIndicator()
            }
            if let error = error {
                print(error.localizedDescription)
            } else {
            if !self.jsonString.isEmpty {
                var isDeparting : Bool = true
                if self.isTicketEdit {
                    isDeparting = (self.ticketData["startDeparting"] as? Bool) ?? true
                }
                else {
                    isDeparting = self.isStatTimeSort
                }
                

                let vc = self.storyboard!.instantiateViewController(withIdentifier: "BookingConfirmationVC") as! BookingConfirmationVC
                vc.customerEmail = email
                vc.customerPhone = customePhone
                vc.tripStartTime = tripStartTime
                vc.tripEndTime = tripReturnTime
                vc.customerName = customerName
                vc.comment = comment
                vc.departureDate = self.todayDate
                vc.totalPaxToBook = self.totalPaxToBook
                vc.taxiIDVal = departurePostRef
                vc.isTicketEdit = self.isTicketEdit
                vc.taxiTotalSeats = self.taxiTotalSeats
                vc.isDeparting = isDeparting
                vc.dataDict = self.jsonString
                vc.ticketID = self.finalTicketID
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
            
        }
        
        
        
        
        //        bookingRef.getDocument { (document, error) in
        //            Utility.hideActivityIndicator()
        //            if let document = document, document.exists {
        //                let data : NSDictionary = document.data()! as NSDictionary
        //                print(data)
        //
        //                var returnTimingArray = NSArray()
        //                var startTimingArray = NSArray()
        //                print(self.ticketData)
        //
        //                var isDeparting : Bool = true
        //                if self.isTicketEdit {
        //                    isDeparting = (self.ticketData["startDeparting"] as? Bool) ?? true
        //                }
        //                else {
        //                    isDeparting = self.isStatTimeSort
        //                }
        //
        //                if  isDeparting {
        //                    returnTimingArray = (data["returnTimingList"] as! NSArray)
        //                    startTimingArray = (data["timingList"] as! NSArray)
        //                }
        //                else {
        //                    returnTimingArray = (data["timingList"] as! NSArray)
        //                    startTimingArray = (data["returnTimingList"] as! NSArray)
        //                }
        //
        //                for index in 0...startTimingArray.count - 1 {
        //                    let data = startTimingArray.object(at: index) as! NSDictionary
        //                    if (data["time"] as! String) == self.txtStartTime.text{
        //
        //                        if self.isTicketEdit {
        //                            self.startAvailableSeats = Int(truncating: self.taxiData["totalSeats"] as! NSNumber) - Int(truncating: data["alreadyBooked"] as! NSNumber)
        //                        }
        //                        else {
        //                            self.startAvailableSeats = Int(truncating: self.taxiData["TotalSeats"] as! NSNumber) - Int(truncating: data["alreadyBooked"] as! NSNumber)
        //                        }
        //
        //                        print(self.startAvailableSeats)
        //                        break
        //
        //                    }
        //                }
        //                for index in 0...returnTimingArray.count - 1 {
        //                    let data = returnTimingArray.object(at: index) as! NSDictionary
        //                    if (data["time"] as! String) == self.txtReturnTime.text{
        //
        //                        if self.isTicketEdit {
        //                            self.returnAvailableSeats = Int(truncating: self.taxiData["totalSeats"] as! NSNumber) - Int(truncating: data["alreadyBooked"] as! NSNumber)
        //                        }
        //                        else {
        //                            self.returnAvailableSeats = Int(truncating: self.taxiData["TotalSeats"] as! NSNumber) - Int(truncating: data["alreadyBooked"] as! NSNumber)
        //
        //                        }
        //
        //                        print(self.returnAvailableSeats)
        //                        break
        //
        //                    }
        //                }
        //
        //
        //                if self.isTicketEdit {
        //
        //                    var adultVal = String()
        //                    var minorVal = String()
        //
        //                    adultVal = (self.ticketData["adult"] as! String)
        //                    minorVal = (self.ticketData["minor"] as! String)
        //
        //                    let alreadyBookedPax =  Int(adultVal)! + Int(minorVal)!
        //
        //                    var totalSeats : Int = 0
        //                    totalSeats = Int(truncating: self.taxiData["totalSeats"] as! NSNumber)
        //
        //                    let startTime = self.txtStartTime.text!
        //                    let returnTime = self.txtReturnTime.text!
        //                    print(self.selectedDate)
        //                    DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: startTime, timeType: "tripStartTime", startDeparting: isDeparting, completion: { count , backtime in
        //                        print(count)
        //
        //                        var newAdultVal = String()
        //                        var newMinorVal = String()
        //
        //                        if self.txtAdults.text! == "" {
        //                            newAdultVal = "0"
        //                        }
        //                        else {
        //                            newAdultVal = self.txtAdults.text!
        //                        }
        //
        //                        if self.txtMinor.text! == "" {
        //                            newMinorVal = "0"
        //                        }
        //                        else {
        //                            newMinorVal = self.txtMinor.text!
        //                        }
        //                        let totalPax = (Int(newAdultVal)! + Int(newMinorVal)!)
        //
        //                        if totalSeats - (count - alreadyBookedPax)  >= totalPax {
        //                            DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: returnTime, timeType: "tripReturnTime", startDeparting: isDeparting, completion: { count , backtime in
        //
        //                                print(count)
        //                                if totalSeats - (count - alreadyBookedPax) >= totalPax {
        //                                    self.cancelBooking()
        //                                }
        //                                else {
        //                                    let vW = Utility.displaySwiftAlert("", "Not enough return seats", type: SwiftAlertType.error.rawValue)
        //                                    SwiftMessages.show(view: vW)
        //                                }
        //
        //                            })
        //                        }
        //                        else {
        //                            let vW = Utility.displaySwiftAlert("", "Not enough start seats", type: SwiftAlertType.error.rawValue)
        //                            SwiftMessages.show(view: vW)
        //                        }
        //                    })
        //
        //                }
        //                else {
        //                    if NetworkMonitor.shared.isReachable {
        //
        //                        var totalSeats : Int = 0
        //                        if self.isTicketEdit {
        //                            totalSeats = Int(truncating: self.taxiData["totalSeats"] as! NSNumber)
        //                        }
        //                        else {
        //                            totalSeats = Int(truncating: self.taxiData["TotalSeats"] as! NSNumber)
        //                        }
        //
        //                        let startTime = self.txtStartTime.text!
        //                        let returnTime = self.txtReturnTime.text!
        //                        print(self.selectedDate)
        //                        DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: startTime, timeType: "tripStartTime", startDeparting: isDeparting, completion: { count , backtime in
        //                            print(count)
        //
        //                            var newAdultVal = String()
        //                            var newMinorVal = String()
        //
        //                            if self.txtAdults.text! == "" {
        //                                newAdultVal = "0"
        //                            }
        //                            else {
        //                                newAdultVal = self.txtAdults.text!
        //                            }
        //
        //                            if self.txtMinor.text! == "" {
        //                                newMinorVal = "0"
        //                            }
        //                            else {
        //                                newMinorVal = self.txtMinor.text!
        //                            }
        //                            let totalPax = (Int(newAdultVal)! + Int(newMinorVal)!)
        //
        //                            if totalSeats - count >= totalPax {
        //                                DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: returnTime, timeType: "tripReturnTime", startDeparting: isDeparting, completion: { count , backtime in
        //
        //                                    print(count)
        //                                    if totalSeats - count >= totalPax {
        //                                        self.createBooking()
        //                                    }
        //                                    else {
        //                                        let vW = Utility.displaySwiftAlert("", "Not enough return seats", type: SwiftAlertType.error.rawValue)
        //                                        SwiftMessages.show(view: vW)
        //                                    }
        //
        //                                })
        //                            }
        //                            else {
        //                                let vW = Utility.displaySwiftAlert("", "Not enough start seats", type: SwiftAlertType.error.rawValue)
        //                                SwiftMessages.show(view: vW)
        //                            }
        //                        })
        //                    }
        //                    else {
        //                        let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
        //                        SwiftMessages.show(view: vW)
        //                    }
        //
        //                }
        //
        //            }
        //        }
        
        //    }
        
    }
    
    
    //MARK:- UITextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your comment(Optional)"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func onClickEditStartTime(_ sender : UIButton) {
        let btnTag = sender.tag
        editSelectedTag = btnTag
        let vc = storyboard!.instantiateViewController(withIdentifier: "EditTicketTimeVC") as! EditTicketTimeVC
        vc.delegate = self
        vc.timeArray = tripStartTimeArray
        vc.totalSeats = self.taxiData["totalSeats"] as! Int
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onClickEditEndTime(_ sender : UIButton) {
        let btnTag = sender.tag
        editSelectedTag = btnTag
        let vc = storyboard!.instantiateViewController(withIdentifier: "EditTicketTimeVC") as! EditTicketTimeVC
        vc.delegate = self
        vc.timeArray = tripReturnTimeArray
        vc.totalSeats = self.taxiData["totalSeats"] as! Int
        self.present(vc, animated: true, completion: nil)
    }
    func userDidSelectInformation(info: String) {
        if editSelectedTag == 1001 {
            txtStartTime.text = info
        }
        else {
            txtReturnTime.text = info
        }
    }
    
    
    
    func getTaxiDetail() {
        
        
        let taxiID = (ticketData["taxiID"] as! String)
        let db = Firestore.firestore()
        var taxiIDVal = String()
        
        if isTicketEdit {
            let bookingDate = (ticketData["bookingDate"] as! String)
            taxiIDVal = String("\(taxiID)\(bookingDate)")
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMMYYYY"
            let todayDateString =  dateFormatter.string(from: selectedDate)
            taxiIDVal = String("\(taxiID)\(todayDateString)")
            
        }
        
        
        let docRef = db.collection("todayStat").document(taxiIDVal)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.taxiData = document.data()! as NSDictionary
                print(self.taxiData)
                
                let isDeparting = (self.ticketData["startDeparting"] as? Bool) ?? true
                
                if  isDeparting {
                    self.tripReturnTimeArray = (self.taxiData["returnTimingList"] as! NSArray)
                    self.tripStartTimeArray = (self.taxiData["timingList"] as! NSArray)
                }
                else {
                    self.tripReturnTimeArray = (self.taxiData["timingList"] as! NSArray)
                    self.tripStartTimeArray = (self.taxiData["returnTimingList"] as! NSArray)
                }
                print(self.tripStartTimeArray)
                print(self.tripReturnTimeArray)
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    //MARK:- OnClick Action Method
    @IBAction func onClickBackAcn(_ sender : UIButton){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmitAcn(_ sender : UIButton){
        
        if txtName.text == "" {
            let vW = Utility.displaySwiftAlert("", "Enter customer name" , type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        if txtSquareCode.text == "" {
            let vW = Utility.displaySwiftAlert("", "Enter sqaure code" , type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if txtSquareCode.text!.count < 4 {
            let vW = Utility.displaySwiftAlert("", "Square Code must be atleast 4 Character long" , type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else {
            if isTicketEdit {
                getTodayStatData()
            }
            else {
                getTodayStatData()
            }
        }
    }
    
    func cancelBooking() {
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let ticketID = (ticketData["ticketID"] as! String)
        db.collection("manageBooking").document(ticketID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                let vW = Utility.displaySwiftAlert("", "There is some error" , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            } else {
                print("Document successfully removed!")
                self.cancelBookedTicketStat()
                
            }
        }
    }
    func cancelBookedTicketStat() {
        
        let db = Firestore.firestore()
        //        let ticketID = (ticketData["ticketID"] as! String)
        
        //Update Seats
        let tripReturnTime = (ticketData["tripReturnTime"] as! String)
        let tripStartTime = (ticketData["tripStartTime"] as! String)
        let taxiID = (ticketData["taxiID"] as! String)
        let totalSeatsToCancel : Int = Int((ticketData["adult"] as! String))! + Int((ticketData["minor"] as! String))!
        
        
        
        var taxiIDVal = String()
        
        
        if isTicketEdit {
            taxiIDVal = String("\(taxiID)\(ticketData["bookingDate"] as! String)")
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMMYYYY"
            let todayDateString =  dateFormatter.string(from: selectedDate)
            taxiIDVal = String("\(taxiID)\(todayDateString)")
            
        }
        
        let docRef = db.collection("todayStat").document(taxiIDVal)
        
        
        print(taxiID)
        print(tripReturnTime)
        print(tripStartTime)
        print(ticketData)
        
        
        docRef.getDocument { (document, error) in
            Utility.hideActivityIndicator()
            if let document = document, document.exists {
                let todayData : NSDictionary = document.data()! as NSDictionary
                
                
                var startTimeArray = NSMutableArray()
                var returnTimeArray = NSMutableArray()
                let isStatSort = (self.ticketData["startDeparting"] as! Bool)
                
                if isStatSort {
                    startTimeArray = todayData["timingList"] as! NSMutableArray
                    returnTimeArray = todayData["returnTimingList"] as! NSMutableArray
                }
                else {
                    startTimeArray = todayData["returnTimingList"] as! NSMutableArray
                    returnTimeArray = todayData["timingList"] as! NSMutableArray
                }
                
                
                
                print(startTimeArray)
                print(tripStartTime)
                
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
                
                
                docRef.updateData([
                    "timingList":newStartArr,
                    "returnTimingList":newReturnArr
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                        let vW = Utility.displaySwiftAlert("", "Error Occured" , type: SwiftAlertType.error.rawValue)
                        SwiftMessages.show(view: vW)
                    } else {
                        if NetworkMonitor.shared.isReachable {
                            
                            var totalSeats : Int = 0
                            if self.isTicketEdit {
                                totalSeats = Int(truncating: self.taxiData["totalSeats"] as! NSNumber)
                            }
                            else {
                                totalSeats = Int(truncating: self.taxiData["TotalSeats"] as! NSNumber)
                            }
                            let startTime = self.txtStartTime.text!
                            let returnTime = self.txtReturnTime.text!
                            print(self.selectedDate)
                            DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: startTime, timeType: "tripStartTime", startDeparting: isStatSort, completion: { count , backtime in
                                print(count)
                                
                                var newAdultVal = String()
                                var newMinorVal = String()
                                
                                if self.txtAdults.text! == "" {
                                    newAdultVal = "0"
                                }
                                else {
                                    newAdultVal = self.txtAdults.text!
                                }
                                
                                if self.txtMinor.text! == "" {
                                    newMinorVal = "0"
                                }
                                else {
                                    newMinorVal = self.txtMinor.text!
                                }
                                let totalPax = (Int(newAdultVal)! + Int(newMinorVal)!)
                                
                                if totalSeats - count >= totalPax {
                                    DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: returnTime, timeType: "tripReturnTime", startDeparting: isStatSort, completion: { count , backtime in
                                        
                                        print(count)
                                        if totalSeats - count >= totalPax {
                                            self.createBooking(current: 0)
                                        }
                                        else {
                                            let vW = Utility.displaySwiftAlert("", "Not enough return seats", type: SwiftAlertType.error.rawValue)
                                            SwiftMessages.show(view: vW)
                                        }
                                        
                                    })
                                }
                                else {
                                    let vW = Utility.displaySwiftAlert("", "Not enough seats available", type: SwiftAlertType.error.rawValue)
                                    SwiftMessages.show(view: vW)
                                    
                                   
                                }
                            })
                        }
                        else {
                            let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
                            SwiftMessages.show(view: vW)
                        }
                        print("Document successfully updated")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
        
        
    }
    
    func createBooking(current:Int) -> Dictionary<String,Any>{
        totalPaxToBook = 0
        let db = Firestore.firestore()
        //      let todayDate = Utility.getTodayDateString()
        
        let timestamp = NSDate().timeIntervalSince1970
        let intVal : Int = Int(timestamp)
        print(selectedDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMYYYY"
        let todayDateString =  dateFormatter.string(from: selectedDate)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd/MM/YYYY"
        todayDate =  dateFormatter.string(from: selectedDate)
        
        
        var adultVal = String()
        var minorVal = String()
        
        if txtAdults.text! == "" {
            adultVal = "0"
        }
        else {
            adultVal = txtAdults.text!
        }
        
        if txtMinor.text! == "" {
            minorVal = "0"
        }
        else {
            minorVal = txtMinor.text!
        }
        
        var departureSide = String()
        print(isStatTimeSort)
        if isStatTimeSort {
            departureSide = "Bayside Beach"
        }
        else {
            departureSide = "Miami Beach"
        }
        
        var taxiID = String()
        if isTicketEdit {
            taxiID =  taxiData["taxiID"] as! String
            taxiTotalSeats = Int(truncating: taxiData["totalSeats"] as! NSNumber)
        }
        else {
            taxiID =  taxiData["ID"] as! String
            taxiTotalSeats = Int(truncating: taxiData["TotalSeats"] as! NSNumber)
        }
        
        var agentID = String()
        var userName = String()
        var agentName = String()
        if isAdminTicketBook {
            agentID = (selectedAgentData["userID"] as! String)
            agentName = (selectedAgentData["name"] as! String)
        }
        else {
            agentID = CurrentUserInfo.userID!
            agentName = CurrentUserInfo.name!
        }
        
        if isTicketEdit {
            agentID = (ticketData["bookingAgentID"] as! String)
            agentName = (ticketData["agentName"] as! String)
            
        }
        
        
        userName = txtName.text!
        let numVal = String("\(intVal)")
        
        finalTicketID = String("\(userName.prefix(4))\("-")\(numVal.suffix(4))")
        print(finalTicketID)
        
        //        totalPaxToBook = Int(adultVal)! + Int(minorVal)!
        
        if current <= 0 {
            let vW = Utility.displaySwiftAlert("", "Passenger count must atleast one." , type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        //        else if (Int(adultVal)! + Int(minorVal)!) > startAvailableSeats  {
        //            let vW = Utility.displaySwiftAlert("", String(format: "Only %d Seats avaibale in start time", startAvailableSeats) , type: SwiftAlertType.error.rawValue)
        //            SwiftMessages.show(view: vW)
        //        }
        //        else  if (Int(adultVal)! + Int(minorVal)!) > returnAvailableSeats  {
        //            let vW = Utility.displaySwiftAlert("", String(format: "Only %d Seats avaibale in return time", returnAvailableSeats) , type: SwiftAlertType.error.rawValue)
        //            SwiftMessages.show(view: vW)
        //        }
        else {
            let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
            var deviceType = String()
            // 2. check the idiom
            switch (deviceIdiom) {
            case .pad:
                deviceType = "iPad"
                print("iPad style UI")
            case .phone:
                deviceType = "iPhone"
                print("iPhone and iPod touch style UI")
            case .tv:
                deviceType = "tvOS"
                print("tvOS style UI")
            default:
                deviceType = "Unspecified"
                print("Unspecified UI idiom")
            }
            
            
            print(deviceIdiom)
            print(currentAppVersion!)
            
            
            
            //            Utility.showActivityIndicator()
            let taxiIDVal = String("\(taxiID)\(todayDateString)")
            //            print("Document added with")
            //
            //            db.collection("manageBooking").document(finalTicketID).setData(
            return [
                "bookingDate": todayDate,
                "bookingAgentID": agentID,
                "adult" : adultVal,
                "minor" : minorVal,
                "customerName" : txtName.text!,
                "customePhone" : txtPhone.text!,
                "tripStartTime" : txtStartTime.text!,
                "tripReturnTime" : txtReturnTime.text!,
                "taxiID": taxiID,
                "agentName": agentName,
                "status":"Pending",
                "ticketID":finalTicketID,
                "bookingDateTimeStamp": FieldValue.serverTimestamp(),
                "email":txtEmail.text!,
                "comment":txtComment.text!,
                "todayDateString":todayDateString,
                "isAdminTicketBook":isAdminTicketBook,
                "ticketDepartureSide":departureSide,
                "startDeparting":isStatTimeSort,
                "device":"IOS",
                "startDepartureStatus":"Pending",
                "returnDepartureStatus":"Pending",
                "version":currentAppVersion!,
                "deviceIdiom":deviceType,
                "isRoundTrip":isRoundTrip,
                "squareCode":txtSquareCode.text!
            ]
            //            ) { err in
            //                Utility.hideActivityIndicator()
            //                let dictionary = ["bookingDate": self.todayDate, "bookingAgentID": CurrentUserInfo.userID!, "adult": self.txtAdults.text!, "minor": self.txtMinor.text!, "customerName": self.txtName.text!, "customePhone": self.txtPhone.text!, "tripStartTime": self.tripStartTime,"tripReturnTime": self.txtReturnTime.text!,"ticketID":self.finalTicketID,"startDeparting":self.isStatTimeSort] as [String : Any]
            //
            //                let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            //                self.jsonString = String(data: jsonData!, encoding: .utf8)!
            //                print(self.jsonString)
            //
            //
            //                if let err = err {
            //                    Utility.hideActivityIndicator()
            //                    let vW = Utility.displaySwiftAlert("",err.localizedDescription, type: SwiftAlertType.error.rawValue)
            //                    SwiftMessages.show(view: vW)
            //                    print("Error adding document: \(err)")
            //                } else {
            ////                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ////                        self.updateTodayStat(taxiIDVal)
            ////                    }
            //
            //
            //                    let vW = Utility.displaySwiftAlert("","Ticket Created Success", type: SwiftAlertType.success.rawValue)
            //                    SwiftMessages.show(view: vW)
            //
            //
            //                    print("Document successfully updated")
            //                    var isDeparting : Bool = true
            //                    if self.isTicketEdit {
            //                        isDeparting = (self.ticketData["startDeparting"] as? Bool) ?? true
            //                    }
            //                    else {
            //                        isDeparting = self.isStatTimeSort
            //                    }
            //                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "BookingConfirmationVC") as! BookingConfirmationVC
            //                    vc.dataDict = self.jsonString
            //                    vc.customerEmail = self.txtEmail.text!
            //                    vc.customerPhone = self.txtPhone.text!
            //
            //                    vc.tripStartTime = self.txtStartTime.text!
            //                    vc.tripEndTime = self.txtReturnTime.text!
            //                    vc.customerName = self.txtName.text!
            //                    vc.comment = self.txtComment.text!
            //                    vc.departureDate = self.todayDate
            //                    vc.totalPaxToBook = self.totalPaxToBook
            //                    vc.isTicketEdit = self.isTicketEdit
            //                    vc.taxiTotalSeats = self.taxiTotalSeats
            //                    vc.ticketID = self.finalTicketID
            //                    vc.taxiIDVal = taxiIDVal
            //                    vc.isDeparting = isDeparting
            //                    self.navigationController?.pushViewController(vc, animated: true)
            //
            //
            //
            //                }
            //            }
        }
        return ["":""]
    }
    
    func updateTodayStat(_ taxiIDVal : String)  {
        let db = Firestore.firestore()
        
        let docRef = db.collection("todayStat").document(taxiIDVal)
        var flag : Bool = true
        
        docRef.getDocument { [self] (document, error) in
            
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                var startTimeArray = NSMutableArray()
                var returnTimeArray = NSMutableArray()
                
                var isDeparting : Bool = true
                if self.isTicketEdit {
                    isDeparting = (self.ticketData["startDeparting"] as? Bool) ?? true
                }
                else {
                    isDeparting = self.isStatTimeSort
                }
                
                if isDeparting {
                    startTimeArray = dataDescription!["timingList"] as! NSMutableArray
                    returnTimeArray = dataDescription!["returnTimingList"] as! NSMutableArray
                }
                else {
                    startTimeArray = dataDescription!["returnTimingList"] as! NSMutableArray
                    returnTimeArray = dataDescription!["timingList"] as! NSMutableArray
                }
                print(String("\("Start Time:")\(self.txtStartTime.text!)"))
                print(String("\("Return Time:")\(self.txtReturnTime.text!)"))
                
                
                for index in 0..<startTimeArray.count {
                    let data = startTimeArray.object(at: index) as! NSDictionary
                    if (data["time"] as! String) == self.txtStartTime.text! {
                        let alreadyBooked = (data["alreadyBooked"] as! Int)
                        
                        if self.taxiTotalSeats > (totalPaxToBook + alreadyBooked) {
                            let newData : NSDictionary = ["alreadyBooked" :  alreadyBooked + self.totalPaxToBook, "time" : self.txtStartTime.text!]
                            startTimeArray.replaceObject(at: index, with: newData)
                            flag = true
                            break
                        }
                        else {
                            flag = false
                            //self.removeTicketFromDB()
                        }
                    }
                }
                
                for index in 0..<returnTimeArray.count {
                    let data = returnTimeArray.object(at: index) as! NSDictionary
                    if (data["time"] as! String) == self.txtReturnTime.text! {
                        let alreadyBooked = (data["alreadyBooked"] as! Int)
                        
                        if self.taxiTotalSeats > (totalPaxToBook + alreadyBooked) {
                            let newData : NSDictionary = ["alreadyBooked" :  alreadyBooked + self.totalPaxToBook, "time" : self.txtReturnTime.text!]
                            returnTimeArray.replaceObject(at: index, with: newData)
                            flag = true
                            break
                        }
                        else {
                            flag = false
                            // self.removeTicketFromDB()
                        }
                    }
                }
                
                if flag {
                    var tempStartArray = NSMutableArray()
                    var tempReturnArray = NSMutableArray()
                    if isDeparting {
                        tempStartArray = startTimeArray
                        tempReturnArray = returnTimeArray
                    }
                    else {
                        tempStartArray = returnTimeArray
                        tempReturnArray = startTimeArray
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        docRef.updateData([
                            "timingList":tempStartArray,
                            "returnTimingList":tempReturnArray
                        ]) { err in
                            
                            Utility.hideActivityIndicator()
                            if let err = err {
                                let vW = Utility.displaySwiftAlert("","Error in creating ticket,try again!", type: SwiftAlertType.error.rawValue)
                                SwiftMessages.show(view: vW)
                                print("Error updating document: \(err)")
                                //Remove Ticket
                                //  self.removeTicketFromDB()
                                
                            } else {
                                let vW = Utility.displaySwiftAlert("","Count updating success", type: SwiftAlertType.success.rawValue)
                                SwiftMessages.show(view: vW)
                                print("Document successfully updated")
                                
                                let vc = self.storyboard!.instantiateViewController(withIdentifier: "BookingConfirmationVC") as! BookingConfirmationVC
                                vc.dataDict = self.jsonString
                                vc.customerEmail = self.txtEmail.text!
                                vc.customerPhone = self.txtPhone.text!
                                vc.ticketID = self.finalTicketID
                                vc.tripStartTime = self.txtStartTime.text!
                                vc.tripEndTime = self.txtReturnTime.text!
                                vc.customerName = self.txtName.text!
                                vc.comment = self.txtComment.text!
                                vc.departureDate = self.todayDate
                                self.navigationController?.pushViewController(vc, animated: true)
                                
                            }
                        }
                    }
                }
            } else {
                // self.removeTicketFromDB()
                Utility.hideActivityIndicator()
                print("Document does not exist")
            }
        }
        
    }
    
    func removeTicketFromDB()  {
        //Remove Ticket
        let db = Firestore.firestore()
        db.collection("manageBooking").document(self.finalTicketID).delete() { err in
            Utility.hideActivityIndicator()
            if let err = err {
                print("Error removing document: \(err)")
                let vW = Utility.displaySwiftAlert("", "There is some error" , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            } else {
                print("Document successfully removed!")
            }
        }
        
        let vW = Utility.displaySwiftAlert("","Error in ticket creating,try again!", type: SwiftAlertType.error.rawValue)
        SwiftMessages.show(view: vW)
    }
    
    
    
}



extension AgentBookingVC {
    
    
    
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
