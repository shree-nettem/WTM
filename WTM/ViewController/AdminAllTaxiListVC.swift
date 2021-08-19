//
//  AdminAllTaxiListVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 23/12/20.
//

import UIKit
import FirebaseFirestore
import SwiftMessages

class AdminAllTaxiListVC: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var tblView : UITableView!
    var taxiListArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    
    @IBAction func onClickBackAcn() {
        _  = self.navigationController?.popViewController(animated: true)
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
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AdminTaxiListCell")! as! AdminTaxiListCell
        let data = taxiListArray.object(at: indexPath.section) as! NSDictionary
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.lblTitle.text = (data["name"] as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = taxiListArray.object(at: indexPath.section) as! NSDictionary
        let vc = storyboard!.instantiateViewController(withIdentifier: "AdminAddTaxiVC") as! AdminAddTaxiVC
        vc.isEdit = true
        vc.taxiDataToEdit = data
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return taxiListArray.count
    }
    

}
