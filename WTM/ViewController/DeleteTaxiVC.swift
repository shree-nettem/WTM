//
//  DeleteTaxiVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 02/01/21.
//

import UIKit
import Firebase
import SwiftMessages

class DeleteTaxiVC: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var lblNoTicket : UILabel!
    var taxiListArray = NSMutableArray()
    var todayStatListArray = NSMutableArray()
    var selectedTaxiID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        getTaxiDetailFromDB()
        
    }
    
    @IBAction func onClickBackAcn() {
        _  = self.navigationController?.popViewController(animated: true)
    }
    
    
    func getTodayStatFromDB() {
        self.getTodayStatList() { todayStatListArray in
            let db = Firestore.firestore()
            print(todayStatListArray)
            Utility.hideActivityIndicator()
            if todayStatListArray.count > 0 {
                self.todayStatListArray.removeAllObjects()
                self.todayStatListArray = todayStatListArray
                
                for index in 0...self.todayStatListArray.count - 1 {
                    let data = self.todayStatListArray.object(at: index) as! NSDictionary
                    let taxiID = data["taxiIDVal"] as! String
                    
                    db.collection("todayStat").document(taxiID).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                    
                }
                
            }
            else {
                
            }
        }
    }
    
    func getTodayStatList(completion: @escaping (_ todayStatListArray : NSMutableArray) -> Void) {
        Utility.showActivityIndicator()
        let db = Firestore.firestore()
        let bookingRef = db.collection("todayStat").whereField("taxiID", isEqualTo: selectedTaxiID)
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
    
    
    
    func getTaxiDetailFromDB() {
        self.getTaxiList() { taxiListArray in
            
            print(taxiListArray)
            Utility.hideActivityIndicator()
            if taxiListArray.count > 0 {
                self.taxiListArray.removeAllObjects()
                self.taxiListArray = taxiListArray
                self.tblView.reloadData()
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
            return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "DeleteTaxiCell")! as! DeleteTaxiCell
        let data = taxiListArray.object(at: indexPath.section) as! NSDictionary
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.lblName.text = (data["name"] as! String)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return taxiListArray.count
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
      if editingStyle == .delete {
            print("Deleted")
            self.showCancelAlert(indexPath.section)
      }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func cancelBookedTicket(_ selectedIndex : Int) {
        let data = taxiListArray.object(at: selectedIndex) as! NSDictionary
        print(data)
        let db = Firestore.firestore()
        let taxiID = (data["ID"] as! String)
        selectedTaxiID = taxiID
        db.collection("TaxiDetail").document(taxiID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                let vW = Utility.displaySwiftAlert("", "There is some error" , type: SwiftAlertType.error.rawValue)
                SwiftMessages.show(view: vW)
            } else {
                print("Document successfully removed!")
                let vW = Utility.displaySwiftAlert("", "Taxi Deleted" , type: SwiftAlertType.success.rawValue)
                SwiftMessages.show(view: vW)
                self.getTaxiDetailFromDB()
                self.getTodayStatFromDB()
            }
        }
        db.collection("todayStat").document(taxiID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }

}
