//
//  AgentDashboardVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 30/11/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SideMenu
import FSCalendar
import SwiftMessages

class AgentDashboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource,FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var lblMessageCount : UILabel!
    @IBOutlet weak var menuView : UIView!
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
    @IBOutlet weak var notificationImg : UIImageView!
    
    @IBOutlet weak var btnTodayDate : UIButton!
    
    @IBOutlet weak var calenderView : UIView!
    @IBOutlet weak var calendar: FSCalendar!
    var selectedDate : Date!
    @IBOutlet weak var calendarHeightConstraint : NSLayoutConstraint!
    
    
    @IBOutlet weak var startTimeImg : UIImageView!
    @IBOutlet weak var returnTimeImg : UIImageView!
    var isStatTimeSort : Bool = true
    @IBOutlet weak var timeSortViewHeight : NSLayoutConstraint!
    
    @IBOutlet weak var ticketStartTimeImg : UIImageView!
    @IBOutlet weak var ticketReturnTimeImg : UIImageView!
    var ticketBoardingPoint : Bool = true
    @IBOutlet weak var ticketBoardingViewHeight : NSLayoutConstraint!
    @IBOutlet weak var ticketBoardingLbl : UILabel!
    var isAgentTicketList : Bool = false
    
    @IBOutlet weak var oneWayTrip : UIImageView!
    @IBOutlet weak var roundWayTrip : UIImageView!
    var isRoundTrip : Bool = true
    
    
    var breakForLoop:Bool = false
    var tableViewReloaded:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(NetworkMonitor.shared.isReachable)
        
        isStatTimeSort = true
        startTimeImg.image = UIImage(named: "RadioON")
        returnTimeImg.image = UIImage(named: "RadioOFF")
        
        
        
        
        selectedDate = Date()
        
        hiddenSections = [1]
        
        UserDefaults.standard.set(true, forKey: SharedData.isAlreadyLogin)
        UserDefaults.standard.synchronize()
        
        
        if isFromAdmin {
            notificationImg.image = UIImage(named: "Write")
        }
        else if  isAgentTicketList {
            notificationImg.image = UIImage(named: "Notification")
        }
        else {
        }
        
        ticketBoardingViewHeight.constant = 70.0
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            self.checkAppVersion()
//        }
        
        //Calender
        calendar.dataSource = self
        calendar.delegate = self
        calendar.firstWeekday = 1
        calendar.allowsSelection = true
        calendar.appearance.titleWeekendColor = #colorLiteral(red: 0.06893683225, green: 0.2285976112, blue: 0.6367123723, alpha: 1)
        calendar.allowsMultipleSelection = false
        calendar.isHidden = true
       
        selectedDate = Date()
 
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.taxiDetailAdded(notification:)), name: Notification.Name("TaxiDetailChanges"), object: nil)

      
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblMessageCount.isHidden = true
        
        getTodayMessage()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-YYYY"
        btnTodayDate.setTitle(dateFormatter.string(from: selectedDate), for: .normal)
        
        getDashBoardTicketDetails()
        
      
    }
    
    @objc func taxiDetailAdded(notification: Notification) {
        
        getTaxiDetailFromDB()
        
    }
    
    func getTaxiDetailFromDB() {
        //Get Today Day Of Week   // 1 = Sunday, 2 = Monday, etc.
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: selectedDate)
        dayOfWeek = calendar.component(.weekday, from: today)
        print(dayOfWeek)
        
        self.getTaxiList() { taxiListArray in
            
            print(taxiListArray)
            Utility.hideActivityIndicator()
            if taxiListArray.count > 0 {
                self.taxiListArray.removeAllObjects()
                self.taxiListArray = taxiListArray
                
                print(self.taxiListArray.count)
                
                for index in 0..<self.taxiListArray.count {
                    let data = self.taxiListArray.object(at: index) as! NSDictionary
                    print(data)
                    
                    self.updateAlreadyExistData(data)
                    
                    if self.dayOfWeek == 1 || self.dayOfWeek == 7 {
                        self.tempTimmeList = data["weekEndStartTiming"] as! NSMutableArray
                        self.tempReturnTimeList = data["weekEndReturnTiming"] as! NSMutableArray
                    }
                    else {
                        self.tempTimmeList = data["weekDayStartTiming"] as! NSMutableArray
                        self.tempReturnTimeList = data["weekDayReturnTiming"] as! NSMutableArray
                    }
                }
            }
            else {
                
            }
        }
    }
    
    func getTaxiList(completion: @escaping (_ taxiListArray : NSMutableArray) -> Void) {
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let bookingRef = db.collection("TaxiDetail")
        let taxiArray =  NSMutableArray()
        bookingRef.getDocuments() { (querySnapshot, err) in
                Utility.hideActivityIndicator()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        taxiArray.add(document.data())
                    }
                }
            completion(taxiArray)
        }
    }
    
    func updateAlreadyExistData(_ data : NSDictionary) {
        let taxiID : String = data["ID"] as! String
        print(data)
        let db = Firestore.firestore()
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMYYYY"
        let todayDateString =  dateFormatter.string(from: selectedDate)
        let taxiIDVal = String("\(taxiID)\(todayDateString)")
        let docRef = db.collection("todayStat").document(taxiIDVal)
        
        //Updated Data, If any
        let name : String = data["name"] as! String
        let totalSeats =  (data["TotalSeats"] as! Int)
        
        var newStartTimeArray = NSMutableArray()
        var newReturnTimeArray = NSMutableArray()
        if self.dayOfWeek == 1 || self.dayOfWeek == 7 {
            newStartTimeArray = data["weekEndStartTiming"] as! NSMutableArray
            newReturnTimeArray = data["weekEndReturnTiming"] as! NSMutableArray
        }
        else {
            newStartTimeArray = data["weekDayStartTiming"] as! NSMutableArray
            newReturnTimeArray = data["weekDayReturnTiming"] as! NSMutableArray
        }
        
        print(newStartTimeArray)
        print(newReturnTimeArray)
        
        print(taxiIDVal)
        //Update Time Change, If any
        let updatedStartTime = NSMutableArray()
        let updatedReturnTime = NSMutableArray()
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data : NSDictionary = document.data()! as NSDictionary
                print(data)
                let existingReturnTimeArray = data["returnTimingList"] as! NSArray
                let existingStartTimeArray = data["timingList"] as! NSArray
                
                print(existingStartTimeArray)
                print(newStartTimeArray)
                
                
                //Start Time Updation
                for item in newStartTimeArray {
                    print(item)
                 let predicate = NSPredicate(format: "time = %@", item as! String)
                 let tempArr : NSArray = existingStartTimeArray.filtered(using: predicate) as NSArray
                 print(tempArr)
                    let newTimeEntry = NSMutableDictionary()
                    if tempArr.count > 0 {
                        let tempData : NSDictionary = tempArr.object(at: 0) as! NSDictionary
                        let alreadyBooked : Int = Int(truncating: tempData["alreadyBooked"] as! NSNumber)
                        newTimeEntry.setObject(alreadyBooked, forKey: "alreadyBooked" as NSCopying)
                        newTimeEntry.setObject(item, forKey: "time" as NSCopying)
                    }
                    else {
                        newTimeEntry.setObject(0, forKey: "alreadyBooked" as NSCopying)
                        newTimeEntry.setObject(item, forKey: "time" as NSCopying)
                    }
                    updatedStartTime.add(newTimeEntry)
                }
                
                //Return Time Updation
                for item in newReturnTimeArray {
                    print(item)
                 let predicate = NSPredicate(format: "time = %@", item as! String)
                    let tempArr : NSArray = existingReturnTimeArray.filtered(using: predicate) as NSArray
                 print(tempArr)
                    let newTimeEntry = NSMutableDictionary()
                    if tempArr.count > 0 {
                        let tempData : NSDictionary = tempArr.object(at: 0) as! NSDictionary
                        let alreadyBooked : Int = Int(truncating: tempData["alreadyBooked"] as! NSNumber)
                        newTimeEntry.setObject(alreadyBooked, forKey: "alreadyBooked" as NSCopying)
                        newTimeEntry.setObject(item, forKey: "time" as NSCopying)
                    }
                    else {
                        newTimeEntry.setObject(0, forKey: "alreadyBooked" as NSCopying)
                        newTimeEntry.setObject(item, forKey: "time" as NSCopying)
                    }
                    updatedReturnTime.add(newTimeEntry)
                }
                
                //Update Data in Firestore
                docRef.updateData([
                    "name": name,
                    "totalSeats":totalSeats,
                    "timingList":updatedStartTime,
                    "returnTimingList":updatedReturnTime
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                      
                    }
                }
                
            }
        }
        
        
        
    }
    
    
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
    
        DatabseManager.getTodayStatData(selectedDate : selectedDate) { statArray in
            Utility.hideActivityIndicator()
            if self.tableViewReloaded {
                
                let finalStatArray = statArray
//                if finalStatArray.count > 0 {
//
//                        for statArrayIndex in 0..<finalStatArray.count {
//                        var signleDocument = finalStatArray[statArrayIndex] as? Dictionary<String,Any>
//
////                        if signleDocument?["taxiID"] as? String ?? "" == taxiID {
//
//
//                            var weekdaystarttimes = signleDocument?["timingList"] as! Array<Dictionary<String,Any>>
//                            print(self.isStatTimeSort)
//                            if !self.isStatTimeSort {
//                                weekdaystarttimes = signleDocument?["returnTimingList"] as! Array<Dictionary<String,Any>>
//                            }
//
//                            for timeIndex in 0..<weekdaystarttimes.count {
//
////                                if timeStramp == weekdaystarttimes[timeIndex]["time"] as? String {
//                                    weekdaystarttimes[timeIndex]["alreadyBooked"] = 0
//
////                                }
//                            }
//                            if self.isStatTimeSort {
//                                signleDocument?["timingList"] = weekdaystarttimes
//                            } else {
//                                signleDocument?["returnTimingList"] = weekdaystarttimes
//
//                            }
//
//
//                            print(weekdaystarttimes)
////                        }
//
//                            finalStatArray[statArrayIndex] = signleDocument ?? [:]
//
//                    }
//
//
//
//
//                }
                
                
                
                
                if finalStatArray.count > 0 {
                    self.todayStatArray = finalStatArray
                    print(self.todayStatArray)
                    self.tblView.reloadData()
                }
            }
           
        }
    }

    func checkAppVersion()  {
        let db = Firestore.firestore()
        let docRef = db.collection("currentAppVersion").document("86pI022tovflaYg8orSB")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                 _ = document.data().map(String.init(describing:)) ?? "nil"
                 let latestVersion = document["version"] as! String
                 self.forceUpgrade(serverVersion: latestVersion)
            } else {
                print("Document does not exist")
            }
        }
        Utility.hideActivityIndicator()
    }
    
    func forceUpgrade(serverVersion : String) {
        
        //Compare App Versions
        let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        
        let minAppVersionComponents : NSArray = serverVersion.components(separatedBy: ".") as NSArray
        let appVersionComponents : NSArray = currentAppVersion!.components(separatedBy: ".") as NSArray
        
        var needToUpdate = false
        
        for i in 0..<min(minAppVersionComponents.count, appVersionComponents.count)
        {
            let minAppVersionComponent = minAppVersionComponents.object(at: i) as! String
            let appVersionComponent = appVersionComponents.object(at: i) as! String
            
            let minApp: String = minAppVersionComponent
            let appVer: String = appVersionComponent
            
            if (minApp != appVer)
            {
                needToUpdate = (appVer < minApp)
                break;
            }
        }
        if (needToUpdate)
        {
            Utility.hideActivityIndicator()
            let alert = UIAlertController(title: "New Version Available", message: "There is a newer version available for download! Please update the app by visiting the Apple Store.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: { alertAction in
                if let url = URL(string: "https://itunes.apple.com/app/id1545116369"),
                    UIApplication.shared.canOpenURL(url)
                {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
        }
    }
    
    /*
    func getTaxiDetailFromDB() {
        //Get Today Day Of Week   // 1 = Sunday, 2 = Monday, etc.
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: selectedDate)
        dayOfWeek = calendar.component(.weekday, from: today)
        print(dayOfWeek)
        
        self.getTaxiList() { taxiListArray in
            
            print(taxiListArray)
            Utility.hideActivityIndicator()
            if taxiListArray.count > 0 {
                self.taxiListArray.removeAllObjects()
                self.taxiListArray = taxiListArray
                
                print(self.taxiListArray.count)
                
                for index in 0..<self.taxiListArray.count {
                    let data = self.taxiListArray.object(at: index) as! NSDictionary
                    print(data)
                    if self.dayOfWeek == 1 || self.dayOfWeek == 7 {
                        self.tempTimmeList = data["weekEndStartTiming"] as! NSMutableArray
                        self.tempReturnTimeList = data["weekEndReturnTiming"] as! NSMutableArray
                    }
                    else {
                        self.tempTimmeList = data["weekDayStartTiming"] as! NSMutableArray
                        self.tempReturnTimeList = data["weekDayReturnTiming"] as! NSMutableArray
                    }
                    
                    if index ==  self.taxiListArray.count - 1 {
                        self.initializeTodayStat(data["ID"] as! String, true, data["name"] as! String, data["TotalSeats"] as! Int, data)
                    }
                    else {
                        self.initializeTodayStat(data["ID"] as! String, false, data["name"] as! String, data["TotalSeats"] as! Int , data)
                    }
                }
            }
            else {
                
            }
        }
    }
    
    func getTaxiList(completion: @escaping (_ taxiListArray : NSMutableArray) -> Void) {
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let bookingRef = db.collection("TaxiDetail")
        let taxiArray =  NSMutableArray()
        bookingRef.getDocuments() { (querySnapshot, err) in
                Utility.hideActivityIndicator()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        taxiArray.add(document.data())
                    }
                }
            completion(taxiArray)
        }
    }
    
    func initializeTodayStat(_ taxiID : String, _ isLastRecord : Bool , _ name : String , _ totalSeats : Int, _ taxiData : NSDictionary) {
        let timingArray = NSMutableArray()
        let returnTimingArray = NSMutableArray()
        for index in 0..<tempTimmeList.count {
            let timeStr = tempTimmeList.object(at: index) as! String
            let tempDict : NSDictionary = ["time" : timeStr, "alreadyBooked" : 0]
            timingArray.add(tempDict)
        }
        for index in 0..<tempReturnTimeList.count {
            let timeStr = tempReturnTimeList.object(at: index) as! String
            let tempDict : NSDictionary = ["time" : timeStr, "alreadyBooked" : 0]
            returnTimingArray.add(tempDict)
        }
        setTodayStatData(timingArray, returnTimingArray  , taxiID, name, totalSeats , taxiData, isLastRecord)
    }
    
    
    
    func setTodayStatData(_ timingArray : NSMutableArray, _ returnTimingArray : NSMutableArray, _ taxiID : String, _ name : String, _ totalSeats: Int , _ taxiData : NSDictionary, _ isLastRecord : Bool) {
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        
        let enrollDate = formatter.string(from: selectedDate)
        let db = Firestore.firestore()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMYYYY"
        let todayDateString =  dateFormatter.string(from: selectedDate)
        let taxiIDVal = String("\(taxiID)\(todayDateString)")
        let docRef = db.collection("todayStat").document(taxiIDVal)

        
        print(timingArray)
        print(returnTimingArray)
        
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                let data : NSDictionary = document.data()! as NSDictionary
                if data["todayDate"] as! String == enrollDate {
                     print("Already Exist")
                     self.updateAlreadyExistData(taxiData , data)
                }
                else {
                    self.updateTodayStat(timingArray, returnTimingArray , taxiID, name, totalSeats)
                }

            } else {
                print("Document does not exist")
                
                db.collection("todayStat").document(taxiIDVal).setData([
                    "taxiID": taxiID,
                    "todayDate":enrollDate,
                    "timingList":timingArray,
                    "name": name,
                    "totalSeats":totalSeats,
                    "returnTimingList":returnTimingArray,
                    "taxiIDVal":taxiIDVal
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            }
        }
        
        if isLastRecord {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.getTodayStatData() { statArray in
                    Utility.hideActivityIndicator()
                    if statArray.count > 0 {
                        self.todayStatArray = statArray
                        print(self.todayStatArray)
                        self.tblView.reloadData()
                    }
                }
            }
        }
        
    }
    
    func updateAlreadyExistData(_ data : NSDictionary, _ todayStatData : NSDictionary) {
        let taxiID : String = data["ID"] as! String
        print(data)
        let db = Firestore.firestore()
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMYYYY"
        let todayDateString =  dateFormatter.string(from: selectedDate)
        let taxiIDVal = String("\(taxiID)\(todayDateString)")
        let docRef = db.collection("todayStat").document(taxiIDVal)
        
        //Updated Data, If any
        let name : String = data["name"] as! String
        let totalSeats =  (data["TotalSeats"] as! Int)
        
        var newStartTimeArray = NSMutableArray()
        var newReturnTimeArray = NSMutableArray()
        if self.dayOfWeek == 1 || self.dayOfWeek == 7 {
            newStartTimeArray = data["weekEndStartTiming"] as! NSMutableArray
            newReturnTimeArray = data["weekEndReturnTiming"] as! NSMutableArray
        }
        else {
            newStartTimeArray = data["weekDayStartTiming"] as! NSMutableArray
            newReturnTimeArray = data["weekDayReturnTiming"] as! NSMutableArray
        }
        
        print(newStartTimeArray)
        print(newReturnTimeArray)
        
        print(taxiIDVal)
        //Update Time Change, If any
        let updatedStartTime = NSMutableArray()
        let updatedReturnTime = NSMutableArray()
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data : NSDictionary = document.data()! as NSDictionary
                print(data)
                let existingReturnTimeArray = data["returnTimingList"] as! NSArray
                let existingStartTimeArray = data["timingList"] as! NSArray
                
                print(existingStartTimeArray)
                print(newStartTimeArray)
                
                
                //Start Time Updation
                for item in newStartTimeArray {
                    print(item)
                 let predicate = NSPredicate(format: "time = %@", item as! String)
                 let tempArr : NSArray = existingStartTimeArray.filtered(using: predicate) as NSArray
                 print(tempArr)
                    let newTimeEntry = NSMutableDictionary()
                    if tempArr.count > 0 {
                        let tempData : NSDictionary = tempArr.object(at: 0) as! NSDictionary
                        let alreadyBooked : Int = Int(truncating: tempData["alreadyBooked"] as! NSNumber)
                        newTimeEntry.setObject(alreadyBooked, forKey: "alreadyBooked" as NSCopying)
                        newTimeEntry.setObject(item, forKey: "time" as NSCopying)
                    }
                    else {
                        newTimeEntry.setObject(0, forKey: "alreadyBooked" as NSCopying)
                        newTimeEntry.setObject(item, forKey: "time" as NSCopying)
                    }
                    updatedStartTime.add(newTimeEntry)
                }
                
                //Return Time Updation
                for item in newReturnTimeArray {
                    print(item)
                 let predicate = NSPredicate(format: "time = %@", item as! String)
                    let tempArr : NSArray = existingReturnTimeArray.filtered(using: predicate) as NSArray
                 print(tempArr)
                    let newTimeEntry = NSMutableDictionary()
                    if tempArr.count > 0 {
                        let tempData : NSDictionary = tempArr.object(at: 0) as! NSDictionary
                        let alreadyBooked : Int = Int(truncating: tempData["alreadyBooked"] as! NSNumber)
                        newTimeEntry.setObject(alreadyBooked, forKey: "alreadyBooked" as NSCopying)
                        newTimeEntry.setObject(item, forKey: "time" as NSCopying)
                    }
                    else {
                        newTimeEntry.setObject(0, forKey: "alreadyBooked" as NSCopying)
                        newTimeEntry.setObject(item, forKey: "time" as NSCopying)
                    }
                    updatedReturnTime.add(newTimeEntry)
                }
                
                //Update Data in Firestore
                docRef.updateData([
                    "name": name,
                    "totalSeats":totalSeats,
                    "timingList":updatedStartTime,
                    "returnTimingList":updatedReturnTime
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                      
                    }
                }
                
            }
        }
        
        
        
    }
    
    func updateTodayStat(_ timingArray : NSMutableArray, _ returnTimingArray : NSMutableArray, _ taxiID : String, _ name : String, _ totalSeats: Int )  {
        
        
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd-MMM-yyyy"
        let enrollDate = formatter1.string(from: selectedDate)
        
       // let enrollDate = Utility.getTodayDateString()
        let db = Firestore.firestore()
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMMyyyy"
        let todayDateString =  formatter.string(from: selectedDate)
        let taxiIDVal = String("\(taxiID)\(todayDateString)")
       // "todayDate":enrollDate,
        
        let docRef = db.collection("todayStat").document(taxiIDVal)
        docRef.updateData([
           
            "timingList":timingArray,
            "name": name,
            "totalSeats":totalSeats,
            "returnTimingList":returnTimingArray
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                
            }
        }
    }

    
    
    func getTodayStatData(completion: @escaping (_ statArray : NSMutableArray) -> Void) {
        let db = Firestore.firestore()
        Utility.showActivityIndicator()
        
        let dateFormatter = DateFormatter()
       // dateFormatter.dateFormat = "dd-MMM-YYYY"
        dateFormatter.dateFormat = "dd-MMM-YYYY"
        
       // dateFormatter.dateFormat = "dd/MM/YYYY"
        let todayDateString =  dateFormatter.string(from: selectedDate)
        
        
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
     */
    
    func getTodayMessage() {
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let todayDate = Utility.getTodayDateString()
        let bookingRef = db.collection("adminMessage")
        self.todayMessageArray.removeAllObjects()
        bookingRef.getDocuments() { (querySnapshot, err) in
                Utility.hideActivityIndicator()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data : NSDictionary = document.data() as NSDictionary
                        if (data["messageDate"] as! String == todayDate ){
                            self.todayMessageArray.add(data)
                            self.lblMessageCount.isHidden = false
                           // self.lblMessageCount.text = String("\(self.todayMessageArray.count)")
                            break
                        }
                    }
                }
        }
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
        
        if !isFromAdmin {
            return Date()
        }else {
            let previousYear = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
            return previousYear
        }
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
       
        print(date)
        calendar.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        btnTodayDate.setTitle(dateFormatter.string(from: date), for: .normal)
        selectedDate = date
        self.tableViewReloaded = true
        getDashBoardTicketDetails()
    
//        //Get Completed List
//        DatabseManager.getTaxiList() { taxiListArray in
//            for index in 0..<taxiListArray.count {
//                let data = taxiListArray.object(at: index) as! NSDictionary
//                print(data)
//
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "ddMMMYYYY"
//                let todayDateString =  dateFormatter.string(from: self.selectedDate)
//                let taxiID : String = data["ID"] as! String
//
//
//
//
//                let weekdaystarttimes = data["weekDayStartTiming"] as! Array<String>
//
//                for timeIndex in 0..<weekdaystarttimes.count {
//
//
//                    let timeStramp = weekdaystarttimes[timeIndex]
//                    let taxiIDVal = String("\(taxiID)\(todayDateString)\(timeStramp)")
//
//
//                let db = Firestore.firestore()
//
//                let docRef = db.collection("bookings").document(taxiIDVal)
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
//            }
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
                           
                            weekdaystarttimes[timeIndex]["alreadyBooked"] = bookedSeats
                          
                        } else {
//                            weekdaystarttimes[timeIndex]["alreadyBooked"] = bookedSeats
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
    
    //MARK:- OnClick Action Method
    @IBAction func onClickTripTypeAcn(_ sender : UIButton){
        let btnTag = sender.tag
        
        if btnTag == 1 {
            isRoundTrip = true
            roundWayTrip.image = UIImage(named: "RadioON")
            oneWayTrip.image = UIImage(named: "RadioOFF")
        }
        else {
            isRoundTrip = false
            roundWayTrip.image = UIImage(named: "RadioOFF")
            oneWayTrip.image = UIImage(named: "RadioON")
        }
    }
    @IBAction func onClickTodayDateAcn(_ sender : UIButton){
        calendar.isHidden = false
        
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
    
    @IBAction func onClickTicketBoardAcn(_ sender : UIButton){
        let btnTag = sender.tag
        
        if btnTag == 1 {
            ticketBoardingPoint = true
            ticketStartTimeImg.image = UIImage(named: "RadioON")
            ticketReturnTimeImg.image = UIImage(named: "RadioOFF")
        }
        else {
            ticketBoardingPoint = false
            ticketStartTimeImg.image = UIImage(named: "RadioOFF")
            ticketReturnTimeImg.image = UIImage(named: "RadioON")
        }
        
    }
    
    @IBAction func onClickBookingAcn(_ sender : UIButton){
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "AgentBookingVC") as! AgentBookingVC
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func onClickViewMessageAcn(_ sender : UIButton){
        
        if isFromAdmin {
            let vc = storyboard!.instantiateViewController(withIdentifier: "SendMessageVC") as! SendMessageVC
            if todayMessageArray.count > 0 {
                vc.messageData = todayMessageArray.object(at: 0) as! NSDictionary
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = storyboard!.instantiateViewController(withIdentifier: "ViewMessageVC") as! ViewMessageVC
            if todayMessageArray.count > 0 {
                vc.messageData = todayMessageArray.object(at: 0) as! NSDictionary
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    /*
    @IBAction func onClickSyncAcn(_ sender : UIButton){
        
        DatabseManager.getTodayStatData(selectedDate: self.selectedDate) { statArray in
            Utility.hideActivityIndicator()
            if statArray.count > 0 {
                print(statArray)
                
                for index in 0..<statArray.count {
                    let data = (statArray.object(at: index) as! NSDictionary)
                    let returnTimeList = (data["returnTimingList"] as! NSArray)
                    let timingList = (data["timingList"] as! NSArray)
                    let taxiID = (data["taxiID"] as! String)
                    
                    let newStartTimeArray = NSMutableArray()
                    let newReturnTimeArray = NSMutableArray()
                    var startUpdate : Bool = false
                    var returnUpdate : Bool = false
                    
                    
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "ddMMMYYYY"
                    let todayDateString =  dateFormatter.string(from: self.selectedDate)
                    let taxiIDVal = String("\(taxiID)\(todayDateString)")
                    print(taxiIDVal)
                    let db = Firestore.firestore()
                    let docRef = db.collection("todayStat").document(taxiIDVal)
                    
                    for tempIndex in 0..<returnTimeList.count {
                         let tempData = (returnTimeList.object(at: tempIndex) as! NSDictionary)
                         let time = (tempData["time"] as! String)
                        DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: time, timeType: "tripReturnTime", completion: { count , backtime in
                            print(count)
                            let data = ["alreadyBooked":count,"time":backtime] as NSDictionary
                            newReturnTimeArray.add(data)
                            
                            if tempIndex == returnTimeList.count - 1 {
                                returnUpdate = true
                            }
                      })
                    }
                    
                    for tempIndex in 0..<timingList.count {
                         let tempData = (timingList.object(at: tempIndex) as! NSDictionary)
                         let time = (tempData["time"] as! String)
                        DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: time, timeType: "tripStartTime", completion: { count , backtime in
                            print(count)
                            let data = ["alreadyBooked":count,"time":backtime] as NSDictionary
                            newStartTimeArray.add(data)
                            
                            if tempIndex == timingList.count - 1 {
                                let sArray = self.sort(newStartTimeArray)
                                let rArray = self.sort(newReturnTimeArray)
                                
                                print(newStartTimeArray)
                                print(sArray)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    docRef.updateData([
                                            "timingList":newStartTimeArray,
                                            "returnTimingList":newReturnTimeArray
                                        ]) { err in
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                            } else {
                                                print("Document successfully updated")
                                            }
                                    }
                                }
                                startUpdate = true
                            }
                      })
                    }
                }
            }
        }
    }
    
    
    func sort(_ unsortArray  : NSMutableArray) -> NSArray  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        let sortedTimes = unsortArray.sortedArray(comparator: { obj1, obj2  in
            
            let startDict = obj1 as! NSDictionary
            let endDict = obj1 as! NSDictionary
            
            let date1 = dateFormatter.date(from: startDict.value(forKey: "time") as! String)
            let date2 = dateFormatter.date(from: endDict.value(forKey: "time")  as! String)
            if let date2 = date2 {
                return date1?.compare(date2) ?? ComparisonResult.orderedSame
            }
            return ComparisonResult.orderedSame
        })
        return sortedTimes as NSArray
    }
 */
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.hiddenSections.contains(section) {
                return 0
            }
            let data = self.todayStatArray.object(at: section) as! NSDictionary
            print(data)
           // let arr : NSArray = data["timingList"] as! NSArray
            var arr = NSArray()
            if isStatTimeSort {
                arr = data["timingList"] as! NSArray
            }
            else {
                arr = data["returnTimingList"] as! NSArray
            }
            return arr.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
           return self.todayStatArray.count
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
       // cell.accessoryType = .detailDisclosureButton
        print(indexPath.section)
        let data = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
        //
        
        var arr = NSArray()
        
        if isStatTimeSort {
             arr = data["timingList"] as! NSArray
        }
        else {
             arr = data["returnTimingList"] as! NSArray
        }
        

        print(arr)
        print(indexPath.row)
        
//        let timeStramp = weekdaystarttimes[timeIndex]
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
        
        
        
       
       
        
       
        
//        if availableSeats > 0 {
//            cell.lblLeftSeats.isHidden = true
//        }
//        else {
//            cell.lblLeftSeats.text = "Booked"
//            cell.lblLeftSeats.isHidden = false
//        }
        
        return cell
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if NetworkMonitor.shared.isReachable {
            if isFromAdmin {
                let vc = storyboard!.instantiateViewController(withIdentifier: "AdminTicketListVC") as! AdminTicketListVC
                let data : NSDictionary = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
                vc.taxiData = self.taxiListArray.object(at:indexPath.section) as! NSDictionary
                var arr = NSArray()
                if isStatTimeSort {
                     arr = data["timingList"] as! NSArray
                }
                else {
                     arr = data["returnTimingList"] as! NSArray
                }
               
                // let arr : NSArray = data["timingList"] as! NSArray
                
                let rowData = arr.object(at: indexPath.row) as! NSDictionary
                vc.tripStartTime = (rowData["time"] as! String)
                vc.isFromAdmin = true
                vc.selectedDate = selectedDate
                vc.isStatTimeSort = isStatTimeSort
                vc.isticketBoardingPoint = ticketBoardingPoint
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if Constant.currentUserFlow == "Normal" {
                
      
                let vc = storyboard!.instantiateViewController(withIdentifier: "AgentBookingReturnTimeVC") as! AgentBookingReturnTimeVC
                
                let data : NSDictionary = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
                vc.taxiData = self.taxiListArray.object(at:indexPath.section) as! NSDictionary
                print(data)
                let arr : NSArray = data["timingList"] as! NSArray
                
                
                
                
                let rowData = arr.object(at: indexPath.row) as! NSDictionary
                print(rowData)
                vc.tripStartTime = (rowData["time"] as! String)
                
                vc.returnTimeArray = data["returnTimingList"] as! NSArray
                vc.tripStartTimeArray = arr
                print(Int(truncating: data["totalSeats"] as! NSNumber))
                vc.totalSeatsInTaxi = Int(truncating: data["totalSeats"] as! NSNumber)
                vc.selectedDate = selectedDate
                vc.isAdminTicketBook = false
                vc.isStatTimeSort = isStatTimeSort
                vc.startAvailableSeats = Int(truncating: data["totalSeats"] as! NSNumber) - Int(truncating: rowData["alreadyBooked"] as! NSNumber)
                print( vc.startAvailableSeats)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                if isAgentEditTicket {
                    isAgentEditTicket = false
                    let vc = storyboard!.instantiateViewController(withIdentifier: "AdminTicketListVC") as! AdminTicketListVC
                    let data : NSDictionary = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
                    vc.taxiData = self.taxiListArray.object(at:indexPath.section) as! NSDictionary
                   // let arr : NSArray = data["timingList"] as! NSArray
                    
                    var arr = NSArray()
                    if isStatTimeSort {
                         arr = data["timingList"] as! NSArray
                    }
                    else {
                         arr = data["returnTimingList"] as! NSArray
                    }
                    
                    
                    
                    let rowData = arr.object(at: indexPath.row) as! NSDictionary
                    vc.tripStartTime = (rowData["time"] as! String)
                    vc.isFromAdmin = false
                    vc.selectedDate = selectedDate
                    vc.isStatTimeSort = isStatTimeSort
                    vc.isticketBoardingPoint = ticketBoardingPoint
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    /*
                    //New Update
                    var arr = NSArray()
                    var ticketType = String()
                    let data : NSDictionary = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
                    let totalSeats = Int(truncating: data["totalSeats"] as! NSNumber)
                    
                    if isStatTimeSort {
                         ticketType = "tripStartTime"
                         arr = data["timingList"] as! NSArray
                    }
                    else {
                         ticketType = "tripReturnTime"
                         arr = data["returnTimingList"] as! NSArray
                    }
                    let rowData = arr.object(at: indexPath.row) as! NSDictionary
                    let ticketTime = (rowData["time"] as! String)
                    DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: ticketTime, timeType: ticketType, completion: { count , backtime in
                        print(count)
                        
                        
                        if (totalSeats - count) > 0 {
                            let availableSeats = String("\("Available Seats: ")\(totalSeats - count)\(" For Time: ")\(ticketTime)")
                            let alert = UIAlertController(title: availableSeats, message: "Do you wish to continue?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
                                self.goForTicketBooking(count: count, indexPath: indexPath)
                            }))
                            alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { action in
                                //Cancel
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            let vW = Utility.displaySwiftAlert("","All Tickets are Booked", type: SwiftAlertType.error.rawValue)
                            SwiftMessages.show(view: vW)
                        }
                    })
 */
                    
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
//                            if totalSeats - count > 0 {
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
//                            }
//                            else {
//                                let vW = Utility.displaySwiftAlert("","Tickets Not Available", type: SwiftAlertType.error.rawValue)
//                                SwiftMessages.show(view: vW)
//                            }
                        }
                        else {
                            //Selected date is same as today date, Agent can book even after 30 minutes past of ticket time
//                            if totalSeats - count > 0 {
                                
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
                                
                                
//                            }
//                            else {
//                                let vW = Utility.displaySwiftAlert("","Tickets Not Available", type: SwiftAlertType.error.rawValue)
//                                SwiftMessages.show(view: vW)
//                            }
                        }
                  })
                    
                    
                    
                 /*
                    if selectedDate > now {
                        // Selected Date is bigger than today date
                        
                        
                        
                        
                        
                        
                        if totalSeats - alreadyBooked > 0 {
                            vc.tripStartTime = (rowData["time"] as! String)
                            if isStatTimeSort {
                                vc.returnTimeArray = data["returnTimingList"] as! NSArray
                            }
                            else {
                                vc.returnTimeArray = data["timingList"] as! NSArray
                            }
                           // vc.returnTimeArray = data["returnTimingList"] as! NSArray
                            vc.tripStartTimeArray = arr
                            print(Int(truncating: data["totalSeats"] as! NSNumber))
                            vc.totalSeatsInTaxi = Int(truncating: data["totalSeats"] as! NSNumber)
                            vc.selectedDate = selectedDate
                            vc.isAdminTicketBook = false
                            vc.startAvailableSeats = Int(truncating: data["totalSeats"] as! NSNumber) - Int(truncating: rowData["alreadyBooked"] as! NSNumber)
                            print(isStatTimeSort)
                            vc.isStatTimeSort = isStatTimeSort
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        else {
                            let vW = Utility.displaySwiftAlert("","Can't Book", type: SwiftAlertType.error.rawValue)
                            SwiftMessages.show(view: vW)
                        }
                    }
                    else {
                        //Selected date is same as today date, Agent can book even after 30 minutes past of ticket time
                        
                        let data : NSDictionary = self.todayStatArray.object(at: indexPath.section) as! NSDictionary
                        vc.taxiData = self.taxiListArray.object(at:indexPath.section) as! NSDictionary
                        print(data)
                        
                        var arr = NSArray()
                        if isStatTimeSort {
                             arr = data["timingList"] as! NSArray
                        }
                        else {
                             arr = data["returnTimingList"] as! NSArray
                        }
                        let rowData = arr.object(at: indexPath.row) as! NSDictionary
                        print(rowData)
                        
                        let totalSeats = Int(truncating: data["totalSeats"] as! NSNumber)
                        let alreadyBooked = Int(truncating: rowData["alreadyBooked"] as! NSNumber)
                        
                        if totalSeats - alreadyBooked > 0 {
                            vc.tripStartTime = (rowData["time"] as! String)
                            let selectedSlot = (rowData["time"] as! String)
                            
                            //Convert Date from Hours
                            let outStr = dateTimeChangeFormat(str: selectedSlot,
                                                              inDateFormat:  "h:mm a",
                                                              outDateFormat: "HH:mm")
                            
                            print(outStr)
                            let calendar = Calendar.current
                            let time=calendar.dateComponents([.hour,.minute,.second], from: Date())
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "HH:mm"
                            dateFormatter.timeZone = .current
                            let selectedTicketTime = dateFormatter.date(from: outStr)!
                           // let selectedTicketTime = dateFormatter.date(from: "14:00")!
                            let currentAgentTime = dateFormatter.date(from: String("\(time.hour!):\(time.minute!)"))!
           
                            print(selectedTicketTime)
                            print(currentAgentTime)
                            
                            if selectedTicketTime > currentAgentTime   {
                               // vc.returnTimeArray = data["returnTimingList"] as! NSArray
                                
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
                                vc.isAdminTicketBook = false
                                vc.startAvailableSeats = Int(truncating: data["totalSeats"] as! NSNumber) - Int(truncating: rowData["alreadyBooked"] as! NSNumber)
                                vc.isStatTimeSort = isStatTimeSort
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
                    } */
                }
            }
        }
        else {
            let vW = Utility.displaySwiftAlert("", "No Internet Connection", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
    }
  
    
    func goForTicketBooking(count : Int , indexPath : IndexPath) {
         
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
        
      //  DatabseManager.getTicketCount(selectedDate: self.selectedDate, ticketTime: ticketTime, timeType: ticketType, completion: { count , backtime in
      //      print(count)
            
            
            if self.selectedDate > now {
                
                // Selected Date is bigger than today date
//                if totalSeats - count > 0 {
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
//                }
//                else {
//                    let vW = Utility.displaySwiftAlert("","Tickets Not Available", type: SwiftAlertType.error.rawValue)
//                    SwiftMessages.show(view: vW)
//                }
            }
            else {
                //Selected date is same as today date, Agent can book even after 30 minutes past of ticket time
//                if totalSeats - count > 0 {
                    
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
                    
                    
//                }
//                else {
//                    let vW = Utility.displaySwiftAlert("","Tickets Not Available", type: SwiftAlertType.error.rawValue)
//                    SwiftMessages.show(view: vW)
//                }
            }
      //})
        
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
        
       
        // return outFormatter.string(from: date)
        /*
        //Add 30 Min to date 
        let earlyDate = Calendar.current.date(
          byAdding: .minute,
          value: 30,
            to: date)! as Date
        print(date)
        print(earlyDate)
        
        if isFromAdmin {
            return outFormatter.string(from: earlyDate)
        }
        else {
            return outFormatter.string(from: date)
        }
 */
        
        
    }

    

}

extension AgentDashboardVC {
    
    
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
