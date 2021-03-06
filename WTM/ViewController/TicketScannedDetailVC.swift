//
//  TicketScannedDetailVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 14/12/20.
//

import UIKit
import FirebaseFirestore
import SwiftMessages

class TicketScannedDetailVC: UIViewController {
    
    var ticketData = String()
    @IBOutlet weak var lblDate : UILabel!
    
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblStartTime : UILabel!
    @IBOutlet weak var lblReturnTime : UILabel!
    @IBOutlet weak var lblAdult : UILabel!
    @IBOutlet weak var lblMinor : UILabel!
    
    @IBOutlet weak var lblStartDeparture : UILabel!
    @IBOutlet weak var lblReturnDeparture : UILabel!
    
    
    @IBOutlet weak var btnStartDeparture : UIButton!
    @IBOutlet weak var btnReturnDeparture : UIButton!
    
    var ticketID = String()
    var ticketIDReturn = String()
    
    var scannedObject:NSDictionary?
    
    var isStartDeparting : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonData = ticketData.data(using: .utf8)!
        let dictionary : NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as! NSDictionary
        scannedObject = dictionary
        print(dictionary)
        
        lblName.text = (dictionary["customerName"] as! String)
        lblStartTime.text = (dictionary["tripStartTime"] as! String)
        lblReturnTime.text = (dictionary["tripReturnTime"] as! String)
        lblDate.text = (dictionary["bookingDate"] as! String)
        
        
        ticketID = (dictionary["startDocumentPath"] as? String ?? "")
        ticketIDReturn = (dictionary["returnDocumentPath"] as? String ?? "")
        
        
        print(ticketID)
        print(ticketIDReturn)
        isStartDeparting = (dictionary["startDeparting"] as? Bool) ?? true
        
        
        if isStartDeparting {
            lblStartDeparture.text = "BS Departure"
            lblReturnDeparture.text = "MB Departure"
        }
        else {
            lblStartDeparture.text = "MB Departure"
            lblReturnDeparture.text = "BS Departure"
        }
        
        let minorCount = (dictionary["minor"] as! String)
        let adultCount = (dictionary["adult"] as! String)
        
        if minorCount == "" {
            lblMinor.text = "0"
        }
        else {
            lblMinor.text = minorCount
        }
        if adultCount == "" {
            lblAdult.text = "0"
        }
        else {
            lblAdult.text = adultCount
        }
        
        getUpdatedTicketData()
    }
    
    
    func getUpdatedTicketData()  {
        if ticketID != "" {
            let db = Firestore.firestore()
            let ticketRef = db.collection("bookings").document(ticketID)
            ticketRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let ticketDetail = document.data()! as NSDictionary
                    if ticketDetail.count > 0 {
                        
                        for (_,values) in ticketDetail {
                            let singleDoc = values as? Dictionary<String,Any>
                            if (singleDoc?["ticketID"] as? String == self.scannedObject?["ticketID"] as? String) {
                                let startTicketDeparture = (singleDoc?["startDepartureStatus"] as? String) ?? "Pending"
                                let returnTicketDeparture = (singleDoc?["returnDepartureStatus"] as? String) ?? "Pending"
                                
                                if startTicketDeparture == "Approved" {
                                    self.btnStartDeparture.setTitle("Approved", for: .normal)
                                    self.btnStartDeparture.isUserInteractionEnabled = false
                                }
                                else {
                                    self.btnStartDeparture.setTitle("Pending", for: .normal)
                                    self.btnStartDeparture.isUserInteractionEnabled = true
                                }
                                
                                
                                if self.ticketIDReturn != "" {
                                    self.btnReturnDeparture.isHidden = false
                                    if returnTicketDeparture == "Approved" {
                                        self.btnReturnDeparture.setTitle("Approved", for: .normal)
                                        self.btnReturnDeparture.isUserInteractionEnabled = false
                                    }
                                    else {
                                        self.btnReturnDeparture.setTitle("Pending", for: .normal)
                                        self.btnReturnDeparture.isUserInteractionEnabled = true
                                    }
                                } else {
                                    self.btnReturnDeparture.isHidden = true
                                }
                                
                                
                                
                                
                            }
                        }
                        
                        
                    }
                    
                } else {
                    
                }
            }
            
        } else {
            
        }
    }
    
    @IBAction func onClickBackAcn()  {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickApproveAcn(_ sender : UIButton)  {
        
        if ticketID != "" {
            
       
        
        let btnTag = sender.tag
        let db = Firestore.firestore()
        let ticketRef = db.collection("bookings").document(ticketID)
        var ticketReturnRef:DocumentReference?
        if self.ticketIDReturn != "" {
            ticketReturnRef = db.collection("bookings").document(ticketIDReturn)
        }
        
        print(ticketID)
        
        if btnTag == 0 {
            db.runTransaction { (transaction, error) -> Any? in
                let sfDocumentdepartureref: DocumentSnapshot
                let sfDocumentreturnref: DocumentSnapshot
                do {
                    try sfDocumentdepartureref = transaction.getDocument(ticketRef)
                    
                    if self.ticketIDReturn != "" {
                        try sfDocumentreturnref = transaction.getDocument(ticketReturnRef!)
                        
                        if let returnTicketData = sfDocumentreturnref.data()  {
                            var bookingDocument:Dictionary<String,Any>?
                            
                            if !returnTicketData.isEmpty {
                                
                                for (_,values) in returnTicketData {
                                    let singleDoc = values as? Dictionary<String,Any>
                                    if (singleDoc?["ticketID"] as? String == self.scannedObject?["ticketID"] as? String) {
                                        bookingDocument = singleDoc
                                        
                                    }
                                }
                                
                                //                                _ = returnTicketData.mapValues { (element)  in
                                //                                    let signleDocument = element as? Dictionary<String,Any>
                                //                                    if (signleDocument?["ticketID"] as? String == self.scannedObject?["ticketID"] as? String) {
                                //                                        bookingDocument = signleDocument
                                //
                                //                                    }
                                //                                }
                            }
                            bookingDocument?["startDepartureStatus"] = "Approved"
                            
                            transaction.updateData([self.scannedObject?["ticketID"] as? String: bookingDocument!], forDocument: ticketReturnRef!)
                            
                            
                        }
                        
                    }
                    
                    if let startTicketData = sfDocumentdepartureref.data()  {
                        var bookingDocument:Dictionary<String,Any>?
                        
                        if !startTicketData.isEmpty {
                            for (_,values) in startTicketData {
                                let singleDoc = values as? Dictionary<String,Any>
                                if (singleDoc?["ticketID"] as? String == self.scannedObject?["ticketID"] as? String) {
                                    bookingDocument = singleDoc
                                    
                                }
                            }
                            //                                _ = startTicketData.mapValues { (element)  in
                            //                                    let signleDocument = element as? Dictionary<String,Any>
                            //                                    if (signleDocument?["ticketID"] as? String == self.scannedObject?["ticketID"] as? String) {
                            //                                        bookingDocument = signleDocument
                            //
                            //                                    }
                            //                                }
                        }
                        bookingDocument?["startDepartureStatus"] = "Approved"
                        
                        transaction.updateData([self.scannedObject?["ticketID"] as? String: bookingDocument!], forDocument: ticketRef)
                    }
                    
                    
                    
                    return nil
                } catch let fetchError as NSError {
                    error?.pointee = fetchError
                    return nil
                }
            } completion: { (data, error) in
                if let err = error {
                    print(err.localizedDescription)
                } else  {
                    
                    self.updateTicketFinalStatus()
                    let vW = Utility.displaySwiftAlert("", "Ticket Approved" , type: SwiftAlertType.success.rawValue)
                    SwiftMessages.show(view: vW)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "TicketCheckVC") as! TicketCheckVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
            //                    ticketRef.getDocument { (document, error) in
            //                        if let document = document, document.exists {
            //                            ticketRef.updateData([
            //                                "startDepartureStatus":"Approved"
            //                            ])
            
            //                        } else {
            //                            print("Document does not exist")
            //                            let vW = Utility.displaySwiftAlert("", "Error Occured" , type: SwiftAlertType.error.rawValue)
            //                            SwiftMessages.show(view: vW)
            //                        }
            //                    }
        }
        else {
            
            db.runTransaction { (transaction, error) -> Any? in
                let sfDocumentdepartureref: DocumentSnapshot
                let sfDocumentreturnref: DocumentSnapshot
                do {
                    try sfDocumentdepartureref = transaction.getDocument(ticketRef)
                    
                    if self.ticketIDReturn != "" {
                        try sfDocumentreturnref = transaction.getDocument(ticketReturnRef!)
                        if let returnTicketData = sfDocumentreturnref.data()  {
                            var bookingDocument:Dictionary<String,Any>?
                            
                            if !returnTicketData.isEmpty {
                                _ = returnTicketData.mapValues { (element)  in
                                    let signleDocument = element as? Dictionary<String,Any>
                                    if (signleDocument?["ticketID"] as? String == self.scannedObject?["ticketID"] as? String) {
                                        bookingDocument = signleDocument
                                        
                                    }
                                }
                            }
                            bookingDocument?["returnDepartureStatus"] = "Approved"
                            
                            transaction.updateData([self.scannedObject?["ticketID"] as? String: bookingDocument!], forDocument: ticketReturnRef!)
                            
                        }
                    }
                    
                    if let startTicketData = sfDocumentdepartureref.data()  {
                        var bookingDocument:Dictionary<String,Any>?
                        
                        if !startTicketData.isEmpty {
                            _ = startTicketData.mapValues { (element)  in
                                let signleDocument = element as? Dictionary<String,Any>
                                if (signleDocument?["ticketID"] as? String == self.scannedObject?["ticketID"] as? String) {
                                    bookingDocument = signleDocument
                                    
                                }
                            }
                        }
                        bookingDocument?["returnDepartureStatus"] = "Approved"
                        
                        transaction.updateData([self.scannedObject?["ticketID"] as? String: bookingDocument!], forDocument: ticketRef)
                    }
                    
                    
                    return nil
                } catch let fetchError as NSError {
                    error?.pointee = fetchError
                    return nil
                }
            } completion: { (data, error) in
                if let err = error {
                    print(err.localizedDescription)
                } else  {
                    
                    self.updateTicketFinalStatus()
                    let vW = Utility.displaySwiftAlert("", "Ticket Approved" , type: SwiftAlertType.success.rawValue)
                    SwiftMessages.show(view: vW)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "TicketCheckVC") as! TicketCheckVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            //                    ticketRef.getDocument { (document, error) in
            //                        if let document = document, document.exists {
            //                            ticketRef.updateData([
            //                                "returnDepartureStatus":"Approved"
            //                            ])
            //                            self.updateTicketFinalStatus()
            
            //                            }
            //                        } else {
            //                            print("Document does not exist")
            //                            let vW = Utility.displaySwiftAlert("", "Error Occured" , type: SwiftAlertType.error.rawValue)
            //                            SwiftMessages.show(view: vW)
            //                        }
            //                    }
            
        }
        /*
         ticketRef.getDocument { (document, error) in
         if let document = document, document.exists {
         ticketRef.updateData([
         "status":"Approved"
         ])
         let vW = Utility.displaySwiftAlert("", "Ticket Approved" , type: SwiftAlertType.success.rawValue)
         SwiftMessages.show(view: vW)
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
         let vc = self.storyboard!.instantiateViewController(withIdentifier: "TicketCheckVC") as! TicketCheckVC
         self.navigationController?.pushViewController(vc, animated: true)
         }
         } else {
         print("Document does not exist")
         let vW = Utility.displaySwiftAlert("", "Error Occured" , type: SwiftAlertType.error.rawValue)
         SwiftMessages.show(view: vW)
         }
         }
         */
        
        } else {
            DispatchQueue.main.async {
                let vW = Utility.displaySwiftAlert("", "Error Occured" , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
            
        }
    }
    
    @IBAction func onClickRejectAcn()  {
        let db = Firestore.firestore()
        let ticketRef = db.collection("manageBooking").document(ticketID)
        ticketRef.getDocument { (document, error) in
            if let document = document, document.exists {
                ticketRef.updateData([
                    "status":"Rejected"
                ])
                let vW = Utility.displaySwiftAlert("", "Ticket Rejected" , type: SwiftAlertType.success.rawValue)
                SwiftMessages.show(view: vW)
            } else {
                print("Document does not exist")
                let vW = Utility.displaySwiftAlert("", "Error Occured" , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            }
        }
    }
    
    func updateTicketFinalStatus() {
        let db = Firestore.firestore()
        let ticketRef = db.collection("bookings").document(ticketID)
        var ticketReturnRef:DocumentReference?
        if ticketIDReturn != "" {
            ticketReturnRef = db.collection("bookings").document(ticketIDReturn)
        }
        
        
        
        
        db.runTransaction { (transaction, error) -> Any? in
            let sfDocumentdepartureref: DocumentSnapshot
            let sfDocumentreturnref: DocumentSnapshot
            do {
                try sfDocumentdepartureref = transaction.getDocument(ticketRef)
                
                if self.ticketIDReturn != "" {
                    try sfDocumentreturnref = transaction.getDocument(ticketReturnRef!)
                    if let returnTicketData = sfDocumentreturnref.data()  {
                        var bookingDocument:Dictionary<String,Any>?
                        
                        if !returnTicketData.isEmpty {
                            _ = returnTicketData.mapValues { (element)  in
                                let signleDocument = element as? Dictionary<String,Any>
                                if (signleDocument?["ticketID"] as? String == self.scannedObject?["ticketID"] as? String) {
                                    bookingDocument = signleDocument
                                    
                                }
                            }
                        }
                        
                        let startTicketDeparture = (bookingDocument?["startDepartureStatus"] as? String) ?? "Pending"
                        let returnTicketDeparture = (bookingDocument?["returnDepartureStatus"] as? String) ?? "Pending"
                        //                    bookingDocument?["returnDepartureStatus"] = "Approved"
                        if startTicketDeparture == "Approved" && returnTicketDeparture == "Approved"{
                            bookingDocument?["status"] = "Approved"
                            transaction.updateData([self.scannedObject?["ticketID"] as? String: bookingDocument!], forDocument: ticketReturnRef!)
                        }
                        
                        
                        
                    }
                }
                
                if let startTicketData = sfDocumentdepartureref.data()  {
                    var bookingDocument:Dictionary<String,Any>?
                    
                    if !startTicketData.isEmpty {
                        _ = startTicketData.mapValues { (element)  in
                            let signleDocument = element as? Dictionary<String,Any>
                            if (signleDocument?["ticketID"] as? String == self.scannedObject?["ticketID"] as? String) {
                                bookingDocument = signleDocument
                                
                            }
                        }
                    }
                    
                    let startTicketDeparture = (bookingDocument?["startDepartureStatus"] as? String) ?? "Pending"
                    let returnTicketDeparture = (bookingDocument?["returnDepartureStatus"] as? String) ?? "Pending"
                    //                    bookingDocument?["returnDepartureStatus"] = "Approved"
                    if startTicketDeparture == "Approved" && returnTicketDeparture == "Approved"{
                        bookingDocument?["status"] = "Approved"
                        transaction.updateData([self.scannedObject?["ticketID"] as? String: bookingDocument!], forDocument: ticketRef)
                    } else if startTicketDeparture == "Approved" && self.ticketIDReturn == "" {
                        bookingDocument?["status"] = "Approved"
                        transaction.updateData([self.scannedObject?["ticketID"] as? String: bookingDocument!], forDocument: ticketRef)
                    }
                    
                }
                
                return nil
            } catch let fetchError as NSError {
                error?.pointee = fetchError
                return nil
            }
        } completion: { (data, error) in
            if let err = error {
                print(err.localizedDescription)
            } else  {
                print("successsssssssss")
            }
        }
        
        
        //        ticketRef.getDocument { (document, error) in
        //            if let document = document, document.exists {
        //                let ticketDetail = document.data()! as NSDictionary
        //                let startTicketDeparture = (ticketDetail["startDepartureStatus"] as? String) ?? "Pending"
        //                let returnTicketDeparture = (ticketDetail["returnDepartureStatus"] as? String) ?? "Pending"
        //
        //                if startTicketDeparture == "Approved" && returnTicketDeparture == "Approved"{
        //                    ticketRef.updateData([
        //                        "status":"Approved"
        //                    ])
        //                }
        //            }
        //        }
    }
    
    
}
