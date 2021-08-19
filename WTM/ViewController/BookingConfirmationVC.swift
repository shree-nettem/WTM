//
//  BookingConfirmationVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 01/12/20.
//

import UIKit
import MessageUI
import Firebase
import SwiftMessages

class BookingConfirmationVC: UIViewController , MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var qrCodeImg : UIImageView!
    @IBOutlet weak var lblTicketNumber : UILabel!
    var dataDict = String()
    var customerEmail = String()
    var customerPhone = String()
    var ticketID = String()
    var tripStartTime = String()
    var tripEndTime = String()
    var customerName = String()
    var comment = String()
    var departureDate = String()
    var isTicketEdit : Bool = false
    var totalPaxToBook : Int = 0
    var taxiTotalSeats : Int = 0
    var taxiIDVal = String()
    var isDeparting : Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let timestamp = NSDate().timeIntervalSince1970
        print(timestamp)
        print(dataDict)
        let image = generateQRCode(from: dataDict)
        qrCodeImg.image = image
        
        
        if customerEmail != ""  {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.sendEmail()
            }
        }
        else if customerPhone != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.sendText()
            }
        }
        
        lblTicketNumber.text = ticketID
//        self.updateTodayStat(taxiIDVal)
        
    }
    
//    func updateTodayStat(_ taxiIDVal : String)  {
//        Utility.showActivityIndicator()
//        let db = Firestore.firestore()
//
//        let docRef = db.collection("todayStat").document(taxiIDVal)
//        var flag : Bool = true
//
//        docRef.getDocument { [self] (document, error) in
//
//            if let document = document, document.exists {
//                let dataDescription = document.data()
//
//                var startTimeArray = NSMutableArray()
//                var returnTimeArray = NSMutableArray()
//
//
//                if isDeparting {
//                    startTimeArray = dataDescription!["timingList"] as! NSMutableArray
//                    returnTimeArray = dataDescription!["returnTimingList"] as! NSMutableArray
//                }
//                else {
//                    startTimeArray = dataDescription!["returnTimingList"] as! NSMutableArray
//                    returnTimeArray = dataDescription!["timingList"] as! NSMutableArray
//                }
//
//
//                for index in 0..<startTimeArray.count {
//                    let data = startTimeArray.object(at: index) as! NSDictionary
//                    if (data["time"] as! String) == self.tripStartTime {
//                        let alreadyBooked = (data["alreadyBooked"] as! Int)
//
//                        if self.taxiTotalSeats > (totalPaxToBook + alreadyBooked) {
//                            let newData : NSDictionary = ["alreadyBooked" :  alreadyBooked + self.totalPaxToBook, "time" : self.tripStartTime]
//                            startTimeArray.replaceObject(at: index, with: newData)
//                            flag = true
//                            break
//                        }
//                        else {
//                            flag = false
//                            //self.removeTicketFromDB()
//                        }
//                    }
//                }
//
//                for index in 0..<returnTimeArray.count {
//                    let data = returnTimeArray.object(at: index) as! NSDictionary
//                    if (data["time"] as! String) == self.tripEndTime {
//                         let alreadyBooked = (data["alreadyBooked"] as! Int)
//
//                        if self.taxiTotalSeats > (totalPaxToBook + alreadyBooked) {
//                            let newData : NSDictionary = ["alreadyBooked" :  alreadyBooked + self.totalPaxToBook, "time" : self.tripEndTime]
//                            returnTimeArray.replaceObject(at: index, with: newData)
//                            flag = true
//                            break
//                        }
//                        else {
//                            flag = false
//                           // self.removeTicketFromDB()
//                        }
//                    }
//                }
//
//                if flag {
//                    var tempStartArray = NSMutableArray()
//                    var tempReturnArray = NSMutableArray()
//                    if isDeparting {
//                        tempStartArray = startTimeArray
//                        tempReturnArray = returnTimeArray
//                    }
//                    else {
//                        tempStartArray = returnTimeArray
//                        tempReturnArray = startTimeArray
//                    }
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        docRef.updateData([
//                            "timingList":tempStartArray,
//                            "returnTimingList":tempReturnArray
//                        ]) { err in
//
//                            Utility.hideActivityIndicator()
//                            if let err = err {
//                                let vW = Utility.displaySwiftAlert("","Error in creating ticket,try again!", type: SwiftAlertType.error.rawValue)
//                                SwiftMessages.show(view: vW)
//                                print("Error updating document: \(err)")
//                                //Remove Ticket
//                              //  self.removeTicketFromDB()
//
//                            } else {
//                                let vW = Utility.displaySwiftAlert("","Count updating success", type: SwiftAlertType.success.rawValue)
//                                SwiftMessages.show(view: vW)
//                            }
//                        }
//                    }
//                }
//                Utility.hideActivityIndicator()
//            } else {
//               // self.removeTicketFromDB()
//                Utility.hideActivityIndicator()
//                print("Document does not exist")
//            }
//        }
//
//    }
    
    
    @IBAction func sendText() {
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                let ticketData = String("\("Ticket ID:")\(ticketID)\("\n")\("Customer Name: ")\(customerName)\("\n")\("Sales Agent Name: ")\(CurrentUserInfo.name!)\("\n")\("Departing Date: ")\(departureDate)\("\n")\("Departing Time BS: ")\(tripStartTime)\("\n")\("Departing Time MB: ")\(tripEndTime)\("\n")\("Comment: ")\(comment)")
               // controller.body = ticketData
                controller.recipients = [customerPhone]
                controller.addAttachmentData(qrCodeImg.image!.jpegData(compressionQuality: CGFloat(1.0))!, typeIdentifier: "image/jpeg", filename:  "ticket.jpeg")
                controller.messageComposeDelegate = self
                
                let signatureData = String("\("Water Taxi Miami")\("\n")\("305-600-2511")\("\n")\("Www.Watertaximiami.com")\("\n")\("For Boarding make sure to be at least 5 minutes before boarding time at Water Taxi station")\("\n")\("305-600-2511")\("\n")\("Disclaimer...................")\("\n")\("We are NOT responsible for any weather conditions, Personal belongings, Captain hold the right to change route and cancel trips, This is NOT a Sightseeing tour.")")
                
                controller.body = String("\(ticketData)\("\n")\("\n")\("\n")\("\n")\("\n")\(signatureData)")
                
                self.present(controller, animated: true, completion: nil)
            }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController?.isNavigationBarHidden = false
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([customerEmail])
            mail.addAttachmentData(qrCodeImg.image!.jpegData(compressionQuality: CGFloat(1.0))!, mimeType: "image/jpeg", fileName:  "ticket.jpeg")
            
            let ticketData = String("\("Ticket ID:")\(ticketID)\("\n")\("Customer Name: ")\(customerName)\("\n")\("Sales Agent Name: ")\(CurrentUserInfo.name!)\("\n")\("Departing Date: ")\(departureDate)\("\n")\("Departing Time BS: ")\(tripStartTime)\("\n")\("Departing Time MB: ")\(tripEndTime)\("\n")\("Comment: ")\(comment)")
            
            /*
            Water Taxi Miami
            305-600-2511
            Www.Watertaximiami.com

            For Boarding make sure to be at least 5 minutes before boarding time at Water Taxi station

            Disclaimer...................
            We are NOT responsible for any weather conditions, Personal belongings, Captain hold the right to change route and cancel trips, This is NOT a Sightseeing tour.
             
            */
            
            let signatureData = String("\("Water Taxi Miami")\("\n")\("305-600-2511")\("\n")\("Www.Watertaximiami.com")\("\n")\("For Boarding make sure to be at least 5 minutes before boarding time at Water Taxi station")\("\n")\("305-600-2511")\("\n")\("Disclaimer...................")\("\n")\("We are NOT responsible for any weather conditions, Personal belongings, Captain hold the right to change route and cancel trips, This is NOT a Sightseeing tour.")")
            
            mail.setMessageBody(String("\(ticketData)\("\n")\("\n")\("\n")\("\n")\("\n")\(signatureData)"), isHTML: false)
            mail.setSubject("WTM Ticket")
            
            
           
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    /*
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
 */
    
    func generateQRCode(from string: String) -> UIImage? {
        let ciContext = CIContext()
       // let data = string.data(using: String.Encoding.ascii)
        let data = Data(string.utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            let upScaledImage = filter.outputImage?.transformed(by: transform)

            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            let qrcodeImage = UIImage(cgImage: cgImage!)
            return qrcodeImage
        }
        return nil
    }
    
    
    
    @IBAction func onClickShareAcn(_ sender : UIButton){
   
        if let image = qrCodeImg.image  {
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
            present(vc, animated: true)
        }
    }
    
    @IBAction func onClickBackAcn(_ sender : UIButton){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickHomeAcn(_ sender : UIButton){
        
        /*
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginWithPinVC.self) {
            
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
 */
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginWithPinVC") as! LoginWithPinVC
        self.navigationController?.pushViewController(vc, animated: true)
 
        
        /*
        if Constant.currentUserFlow == "Admin" {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PastTicketListVC") as! PastTicketListVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let  initialViewController : AgentDashboardVC = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
            initialViewController.isFromAdmin = false
            initialViewController.isAgentEditTicket = false
            self.navigationController?.pushViewController(initialViewController, animated: true)
        }
        */
       
        
        
    }

    

}
