//
//  AdminAddTaxiVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 05/12/20.
//

import UIKit
import FirebaseFirestore
import SwiftMessages

class AdminAddTaxiVC: UIViewController , UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate {

    @IBOutlet weak var weekdayStartTimeTblView : UITableView!
    @IBOutlet weak var weekdayReturnTimeTblView : UITableView!
    
    @IBOutlet weak var weekEndStartTimeTblView : UITableView!
    @IBOutlet weak var weekEndReturnTimeTblView : UITableView!
    @IBOutlet weak var startTimeTF : UITextField!
    @IBOutlet weak var returnTimeTF : UITextField!
    @IBOutlet weak var weekEndStartTimeTF : UITextField!
    @IBOutlet weak var weekEndReturnTimeTF : UITextField!
    
    @IBOutlet weak var taxiNameTF : UITextField!
    @IBOutlet weak var totalSeatsTF : UITextField!
    @IBOutlet weak var taxiFareTF : UITextField!
    @IBOutlet weak var baseViewHeight : NSLayoutConstraint!
    
    
    @IBOutlet weak var startTimeViewHeight : NSLayoutConstraint!
    @IBOutlet weak var startTimeTblHeight : NSLayoutConstraint!
    @IBOutlet weak var returnTimeViewHeight : NSLayoutConstraint!
    @IBOutlet weak var returnTimeTblHeight : NSLayoutConstraint!
    
    @IBOutlet weak var weekendStartTimeViewHeight : NSLayoutConstraint!
    @IBOutlet weak var weekendStartTimeTblHeight : NSLayoutConstraint!
    @IBOutlet weak var weekendReturnTimeViewHeight : NSLayoutConstraint!
    @IBOutlet weak var weekendReturnTimeTblHeight : NSLayoutConstraint!
    
    
    var startTimeArray = NSMutableArray()
    var returnTimeArray = NSMutableArray()
    var weekendStartTimeArray = NSMutableArray()
    var weekendReturnTimeArray = NSMutableArray()
    
    
    let timePicker = UIDatePicker()
    var datePicker : UIDatePicker!
    var selectedTF : UITextField!
    var isEdit : Bool = false
    var taxiDataToEdit = NSDictionary()
    @IBOutlet weak var btnAdd : UIButton!
    
    
    @IBOutlet weak var weekdayStartHeadingTF : UITextField!
    @IBOutlet weak var weekdayReturnHeadingTF : UITextField!
    @IBOutlet weak var weekendStartHeadingTF : UITextField!
    @IBOutlet weak var weekendReturnHeadingTF : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.weekdayStartTimeTblView.isEditing = true
        self.weekdayReturnTimeTblView.isEditing = true
        self.weekEndStartTimeTblView.isEditing = true
        self.weekEndReturnTimeTblView.isEditing = true
        
        
        if isEdit {
            btnAdd.setTitle("UPDATE", for: .normal)
            let totalSeats : Int = (taxiDataToEdit["TotalSeats"] as! Int)
            taxiNameTF.text = (taxiDataToEdit["name"] as! String)
            totalSeatsTF.text = String("\(totalSeats)")
            taxiFareTF.text = (taxiDataToEdit["ticketPrice"] as! String)
            
            
            startTimeArray = (taxiDataToEdit["weekDayStartTiming"] as! NSMutableArray)
            returnTimeArray = (taxiDataToEdit["weekDayReturnTiming"] as! NSMutableArray)
            weekendStartTimeArray = (taxiDataToEdit["weekEndStartTiming"] as! NSMutableArray)
            weekendReturnTimeArray = (taxiDataToEdit["weekEndReturnTiming"] as! NSMutableArray)
            
            weekdayStartHeadingTF.text = (taxiDataToEdit["weekdayStartHeading"] as! String)
            weekdayReturnHeadingTF.text = (taxiDataToEdit["weekdayReturnHeading"] as! String)
            weekendStartHeadingTF.text = (taxiDataToEdit["weekendStartHeading"] as! String)
            weekendReturnHeadingTF.text = (taxiDataToEdit["weekendReturnHeading"] as! String)
            
            weekdayStartTimeTblView.reloadData()
            weekdayReturnTimeTblView.reloadData()
            weekEndStartTimeTblView.reloadData()
            weekEndReturnTimeTblView.reloadData()
        }
        else {
            btnAdd.setTitle("ADD", for: .normal)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        
        let startTimeVWHeight = startTimeArray.count * 60
        startTimeViewHeight.constant = CGFloat(startTimeVWHeight + 80)
        startTimeTblHeight.constant = CGFloat(startTimeArray.count * 60)
        
        let returnTimeVWHeight = returnTimeArray.count * 60
        returnTimeViewHeight.constant = CGFloat(returnTimeVWHeight + 80)
        returnTimeTblHeight.constant = CGFloat(returnTimeArray.count * 60)
        
        
        let weekendStartTimeVWHeight = weekendStartTimeArray.count * 60
        weekendStartTimeViewHeight.constant = CGFloat(weekendStartTimeVWHeight + 80)
        weekendStartTimeTblHeight.constant = CGFloat(weekendStartTimeArray.count * 60)
        
        let weekendReturnTimeVWHeight = weekendReturnTimeArray.count * 60
        weekendReturnTimeViewHeight.constant = CGFloat(weekendReturnTimeVWHeight + 80)
        weekendReturnTimeTblHeight.constant = CGFloat(weekendReturnTimeArray.count * 60)
        
        baseViewHeight.constant = startTimeViewHeight.constant + returnTimeViewHeight.constant +  200 + weekendStartTimeViewHeight.constant + weekendReturnTimeViewHeight.constant
    }

    @IBAction func onClickStartTimeAddAcn(){
        startTimeArray.add(startTimeTF.text!)
        startTimeTF.text = ""
        weekdayStartTimeTblView.reloadData()
    }
    @IBAction func onClickReturnTimeAddAcn(){
        returnTimeArray.add(returnTimeTF.text!)
        returnTimeTF.text = ""
        weekdayReturnTimeTblView.reloadData()
    }
    @IBAction func onClickWeekendStartTimeAddAcn(){
        weekendStartTimeArray.add(weekEndStartTimeTF.text!)
        weekEndStartTimeTF.text = ""
        weekEndStartTimeTblView.reloadData()
    }
    @IBAction func onClickWeekendReturnTimeAddAcn(){
        weekendReturnTimeArray.add(weekEndReturnTimeTF.text!)
        weekEndReturnTimeTF.text = ""
        weekEndReturnTimeTblView.reloadData()
    }
    @IBAction func onClickBackAcn(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addDataToDB() {
        
        if taxiNameTF.text! == "" {
            let vW = Utility.displaySwiftAlert("", "Enter Taxi Title", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if totalSeatsTF.text! == "" {
            let vW = Utility.displaySwiftAlert("", "Enter total seats", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if taxiFareTF.text! == "" {
            let vW = Utility.displaySwiftAlert("", "Enter ticket Price", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
         /*
        else if startTimeArray.count <= 0 {
            let vW = Utility.displaySwiftAlert("", "choose start timings", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        else if returnTimeArray.count <= 0 {
            let vW = Utility.displaySwiftAlert("", "Choose return timings", type: SwiftAlertType.error.rawValue)
            SwiftMessages.show(view: vW)
        }
        */
        else  {
            Utility.showActivityIndicator()
            let db = Firestore.firestore()
            let seats : Int = Int(totalSeatsTF.text!)!
            
            var weekdayStartHeading = String()
            var weekdayReturnHeading = String()
            var weekendStartHeading = String()
            var weekendReturnHeading = String()
            
            
            if weekdayStartHeadingTF.text == "" {
                weekdayStartHeading = ""
            }
            else {
                weekdayStartHeading = weekdayStartHeadingTF.text!
            }
            
            if weekdayReturnHeadingTF.text == "" {
                weekdayReturnHeading = ""
            }
            else {
                weekdayReturnHeading = weekdayReturnHeadingTF.text!
            }
            
            if weekendStartHeadingTF.text == "" {
                weekendStartHeading = ""
            }
            else {
                weekendStartHeading = weekendStartHeadingTF.text!
            }
            
            if weekendReturnHeadingTF.text == "" {
                weekendReturnHeading = ""
            }
            else {
                weekendReturnHeading = weekendReturnHeadingTF.text!
            }
            
            
            if isEdit {
               let taxiID = (taxiDataToEdit["ID"] as! String)
               let docRef = db.collection("TaxiDetail").document(taxiID)
                
                docRef.updateData([
                    "TotalSeats":  seats,
                    "name" : taxiNameTF.text!,
                    "ticketPrice" : taxiFareTF.text!,
                    "weekDayReturnTiming" : returnTimeArray,
                    "weekDayStartTiming" : startTimeArray,
                    "weekEndStartTiming" : weekendStartTimeArray,
                    "weekEndReturnTiming" : weekendReturnTimeArray,
                    "weekdayStartHeading" : weekdayStartHeading,
                    "weekdayReturnHeading" : weekdayReturnHeading,
                    "weekendStartHeading" : weekendStartHeading,
                    "weekendReturnHeading" : weekendReturnHeading
                ]) { err in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error updating document: \(err)")
                        let vW = Utility.displaySwiftAlert("", "There is some error.", type: SwiftAlertType.error.rawValue)
                        SwiftMessages.show(view: vW)
                    } else {
                        NotificationCenter.default.post(name: Notification.Name("TaxiDetailChanges"), object: nil)
                        

                        print("Document successfully updated")
                        let vW = Utility.displaySwiftAlert("", "Data Updated Successfully!", type: SwiftAlertType.success.rawValue)
                        SwiftMessages.show(view: vW)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.navigateToDashboard()
                        }
                    }
                }
            }
            else {
                let timestamp = NSDate().timeIntervalSince1970
                let intVal : Int = Int(timestamp)
                db.collection("TaxiDetail").document(String("\(intVal)")).setData([
                    "ID":String("\(intVal)"),
                    "TotalSeats":  seats,
                    "name" : taxiNameTF.text!,
                    "ticketPrice" : taxiFareTF.text!,
                    "weekEndReturnTiming" : weekendReturnTimeArray,
                    "weekDayStartTiming" : startTimeArray,
                    "weekEndStartTiming" : weekendStartTimeArray,
                    "weekDayReturnTiming" : returnTimeArray,
                    "weekdayStartHeading" : weekdayStartHeading,
                    "weekdayReturnHeading" : weekdayReturnHeading,
                    "weekendStartHeading" : weekendStartHeading,
                    "weekendReturnHeading" : weekendReturnHeading
                ]) { err in
                    Utility.hideActivityIndicator()
                    if let err = err {
                        print("Error writing document: \(err)")
                        let vW = Utility.displaySwiftAlert("", "There is some error.", type: SwiftAlertType.error.rawValue)
                        SwiftMessages.show(view: vW)
                        print("Error adding document: \(err)")
                    } else {
                        NotificationCenter.default.post(name: Notification.Name("TaxiDetailChanges"), object: nil)
                        print("Document successfully written!")
                        let vW = Utility.displaySwiftAlert("", "Taxi Details Added", type: SwiftAlertType.success.rawValue)
                        SwiftMessages.show(view: vW)
                        print("Document added with")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.navigateToDashboard()
                        }
                        
                    }
                }
            }
        }
    }
    
    
    func navigateToDashboard() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "AgentDashboardVC") as! AgentDashboardVC
        vc.isFromAdmin = true
        vc.isAgentEditTicket = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- UIDatePicker Delegate
    func pickUpDate(_ textField : UITextField){
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
       // self.datePicker.minimumDate = Date()
        
        self.datePicker.datePickerMode = UIDatePicker.Mode.time
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
        if selectedTF == startTimeTF {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "h:mm a"
            startTimeTF.text = dateFormatter1.string(from: datePicker.date)
            startTimeTF.resignFirstResponder()
        }
        else if selectedTF == returnTimeTF  {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "h:mm a"
            returnTimeTF.text = dateFormatter1.string(from: datePicker.date)
            returnTimeTF.resignFirstResponder()
        }
        else if selectedTF == weekEndStartTimeTF  {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "h:mm a"
            weekEndStartTimeTF.text = dateFormatter1.string(from: datePicker.date)
            weekEndStartTimeTF.resignFirstResponder()
        }
        else if selectedTF == weekEndReturnTimeTF  {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "h:mm a"
            weekEndReturnTimeTF.text = dateFormatter1.string(from: datePicker.date)
            weekEndReturnTimeTF.resignFirstResponder()
        }
    }
    
    @objc func cancelClick() {
        selectedTF.resignFirstResponder()
    }
    
    //MARK:- UITextfield Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTF = textField
        if textField == startTimeTF {
            self.pickUpDate(startTimeTF)
        }
        else if textField == returnTimeTF {
            self.pickUpDate(returnTimeTF)
        }
        else if textField == weekEndStartTimeTF {
            self.pickUpDate(weekEndStartTimeTF)
        }
        else if textField == weekEndReturnTimeTF {
            self.pickUpDate(weekEndReturnTimeTF)
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
            return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == weekdayStartTimeTblView {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "AddTaxiStartTimeCell")! as! AddTaxiStartTimeCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lblTitle.text = (startTimeArray.object(at: indexPath.section) as! String)
            return cell
        }
        else if tableView == weekdayReturnTimeTblView{
            let cell  = tableView.dequeueReusableCell(withIdentifier: "AddTaxiReturnTimeCell")! as! AddTaxiReturnTimeCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lblTitle.text = (returnTimeArray.object(at: indexPath.section) as! String)
            return cell
        }
        else if tableView == weekEndStartTimeTblView{
            let cell  = tableView.dequeueReusableCell(withIdentifier: "AddTaxiReturnTimeCell")! as! AddTaxiReturnTimeCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lblTitle.text = (weekendStartTimeArray.object(at: indexPath.section) as! String)
            return cell
        }
        else {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "AddTaxiReturnTimeCell")! as! AddTaxiReturnTimeCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lblTitle.text = (weekendReturnTimeArray.object(at: indexPath.section) as! String)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == weekdayStartTimeTblView {
            return startTimeArray.count
        }
        else if tableView == weekdayReturnTimeTblView{
            return returnTimeArray.count
        }
        else if tableView == weekEndStartTimeTblView{
            return weekendStartTimeArray.count
        }
        else if tableView == weekEndReturnTimeTblView{
            return weekendReturnTimeArray.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
      if editingStyle == .delete {
            print("Deleted")
        if tableView == weekdayStartTimeTblView {
            print(startTimeArray)
            print(indexPath.section)
            self.startTimeArray.removeObject(at: indexPath.section)
            print(startTimeArray)
            self.weekdayStartTimeTblView.reloadData()
        }
        else if tableView == weekdayReturnTimeTblView {
            self.returnTimeArray.removeObject(at: indexPath.section)
            self.weekdayReturnTimeTblView.reloadData()
        }
        else if tableView == weekEndStartTimeTblView {
            self.weekendStartTimeArray.removeObject(at: indexPath.section)
            self.weekEndStartTimeTblView.reloadData()
        }
        else if tableView == weekEndReturnTimeTblView {
            self.weekendReturnTimeArray.removeObject(at: indexPath.section)
            self.weekEndReturnTimeTblView.reloadData()
        }
      }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
   func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
       return false
   }
   func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    
   
    if tableView == weekdayStartTimeTblView {
        print(startTimeArray)
        let movedObject = self.startTimeArray[sourceIndexPath.section]
        startTimeArray.removeObject(at: sourceIndexPath.section)
        startTimeArray.insert(movedObject, at: destinationIndexPath.section)
        weekdayStartTimeTblView.reloadData()
    }
    else if tableView == weekdayReturnTimeTblView {
        let movedObject = self.returnTimeArray[sourceIndexPath.section]
        returnTimeArray.removeObject(at: sourceIndexPath.section)
        returnTimeArray.insert(movedObject, at: destinationIndexPath.section)
        weekdayReturnTimeTblView.reloadData()
    }
    else if tableView == weekEndStartTimeTblView {
        let movedObject = self.weekendStartTimeArray[sourceIndexPath.section]
        weekendStartTimeArray.removeObject(at: sourceIndexPath.section)
        weekendStartTimeArray.insert(movedObject, at: destinationIndexPath.section)
        weekEndStartTimeTblView.reloadData()
    }
    else if tableView == weekEndReturnTimeTblView {
        let movedObject = self.weekendReturnTimeArray[sourceIndexPath.section]
        weekendReturnTimeArray.removeObject(at: sourceIndexPath.section)
        weekendReturnTimeArray.insert(movedObject, at: destinationIndexPath.section)
        weekEndReturnTimeTblView.reloadData()
    }
   }
    

}
