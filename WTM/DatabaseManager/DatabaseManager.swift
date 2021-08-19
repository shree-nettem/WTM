//
//  DatabaseManager.swift
//  WTM
//
//  Created by Tarun Sachdeva on 29/06/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class DatabseManager: NSObject {
    
    
    
   static func getTaxiList(completion: @escaping (_ taxiListArray : NSMutableArray) -> Void) {
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let bookingRef = db.collection("TaxiDetail")
        let taxiArray =  NSMutableArray()
        bookingRef.getDocuments() { (querySnapshot, err) in
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

    static func setTodayStatData( selectedDate : Date){
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: selectedDate)
        let dayOfWeek : Int = calendar.component(.weekday, from: today)
        print(dayOfWeek)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
       
        
        var tempStartTimeList = NSMutableArray()
        var tempReturnTimeList = NSMutableArray()
        
        self.getTaxiList() { taxiListArray in
            if taxiListArray.count > 0 {
                for index in 0..<taxiListArray.count {
                    let data = taxiListArray.object(at: index) as! NSDictionary
                    print(data)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "ddMMMYYYY"
                    let todayDateString =  dateFormatter.string(from: selectedDate)
                    let taxiID : String = data["ID"] as! String
                    let taxiIDVal = String("\(taxiID)\(todayDateString)")
                    
                    let db = Firestore.firestore()
                    let docRef = db.collection("todayStat").document(taxiIDVal)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            Utility.hideActivityIndicator()
                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                             //Already Exist, No need to do anything
                        } else {
                           //Create New Document
                            //Check WeekDay Or Weekend
                            if  dayOfWeek == 1 || dayOfWeek == 7 {
                                 tempStartTimeList = data["weekEndStartTiming"] as! NSMutableArray
                                tempReturnTimeList = data["weekEndReturnTiming"] as! NSMutableArray
                            }
                            else {
                                tempStartTimeList = data["weekDayStartTiming"] as! NSMutableArray
                                tempReturnTimeList = data["weekDayReturnTiming"] as! NSMutableArray
                            }
                            
                            self.initializeTodayStat(data["ID"] as! String, data["name"] as! String, data["TotalSeats"] as! Int , data, tempStartTimeList , tempReturnTimeList, selectedDate)
                        }
                    }
                }
            }
        }
    }
    
    static  func initializeTodayStat(_ taxiID : String, _ name : String , _ totalSeats : Int, _ taxiData : NSDictionary ,_ tempStartTime : NSMutableArray, _ tempReturnTime : NSMutableArray, _ selectedDate : Date) {
        let startTimingArray = NSMutableArray()
        let returnTimingArray = NSMutableArray()
        for index in 0..<tempStartTime.count {
            let timeStr = tempStartTime.object(at: index) as! String
            let tempDict : NSDictionary = ["time" : timeStr, "alreadyBooked" : 0]
            startTimingArray.add(tempDict)
        }
        for index in 0..<tempReturnTime.count {
            let timeStr = tempReturnTime.object(at: index) as! String
            let tempDict : NSDictionary = ["time" : timeStr, "alreadyBooked" : 0]
            returnTimingArray.add(tempDict)
        }
        setTodayStatData(startTimingArray, returnTimingArray  , taxiID, name, totalSeats , taxiData, selectedDate: selectedDate)
    }
    
    static  func setTodayStatData(_ timingArray : NSMutableArray, _ returnTimingArray : NSMutableArray, _ taxiID : String, _ name : String, _ totalSeats: Int , _ taxiData : NSDictionary, selectedDate : Date) {
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        
        let enrollDate = formatter.string(from: selectedDate)
        
        
        let db = Firestore.firestore()
        print(taxiID)
        print("Document does not exist")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMYYYY"
        let todayDateString =  dateFormatter.string(from: selectedDate)
        let taxiIDVal = String("\(taxiID)\(todayDateString)")
        
        
        db.collection("todayStat").document(taxiIDVal).setData([
            "taxiID": taxiID,
            "todayDate":enrollDate,
            "timingList":timingArray,
            "name": name,
            "totalSeats":totalSeats,
            "returnTimingList":returnTimingArray
        ]) { err in
            Utility.hideActivityIndicator()
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                print("Document successfully written!")
            }
          }
    }
    
    static func getTodayStatData(selectedDate : Date, completion: @escaping (_ statArray : NSMutableArray) -> Void) {
        
        let db = Firestore.firestore()
        Utility.showActivityIndicator()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-YYYY"
        
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
    
    static func getTicketCount(selectedDate : Date, ticketTime : String, timeType : String, startDeparting: Bool, completion: @escaping (_ count : Int, _ backtime : String) -> Void) {

        let db = Firestore.firestore()
        Utility.showActivityIndicator()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMYYYY"
        
        let todayDateString =  dateFormatter.string(from: selectedDate)
        
      //  let bookingRef = db.collection("manageBooking").whereField("bookingDate", isEqualTo: todayDateString).whereField(timeType, isEqualTo: ticketTime)
        
        let bookingRef = db.collection("manageBooking").whereField("bookingDate", isEqualTo: todayDateString)
        
        print(bookingRef)
       
        var count : Int = 0
        bookingRef.getDocuments() { (querySnapshot, err) in
                Utility.hideActivityIndicator()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let tempArray = NSMutableArray()
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if (data["status"] as! String) == "Cancelled" {
                            //Nothing
                        }
                        else {
                            tempArray.add(data)
                        }
                    }
                    if startDeparting {
                        let predicate1 = NSPredicate(format: "startDeparting = %d AND tripStartTime = %@", true, ticketTime)
                        let predicate2 = NSPredicate(format: "startDeparting = %d AND tripReturnTime = %@", false, ticketTime)
                        let filterArray1 = tempArray.filtered(using: predicate1) as NSArray
                        let filterArray2 = tempArray.filtered(using: predicate2) as NSArray
                        let finalArray : NSArray = filterArray1.addingObjects(from: filterArray2 as! [Any]) as NSArray
                        for index in 0..<finalArray.count {
                            let data = finalArray.object(at: index) as! NSDictionary
                            count = count + Int(data["adult"] as! String)! + Int(data["minor"] as! String)!
                        }
                        print(finalArray)
                    }
                    else {
                        let predicate1 = NSPredicate(format: "startDeparting = %d AND tripStartTime = %@", false, ticketTime)
                        let predicate2 = NSPredicate(format: "startDeparting = %d AND tripReturnTime = %@", true, ticketTime)
                        let filterArray1 = tempArray.filtered(using: predicate1) as NSArray
                        let filterArray2 = tempArray.filtered(using: predicate2) as NSArray
                        let finalArray : NSArray = filterArray1.addingObjects(from: filterArray2 as! [Any]) as NSArray
                        for index in 0..<finalArray.count {
                            let data = finalArray.object(at: index) as! NSDictionary
                            count = count + Int(data["adult"] as! String)! + Int(data["minor"] as! String)!
                        }
                       
                    }
                }
            completion(count, ticketTime)
        }
    }
 
}
