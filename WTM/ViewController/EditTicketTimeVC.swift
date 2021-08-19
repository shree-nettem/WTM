//
//  EditTicketTimeVC.swift
//  WTM
//
//  Created by Tarun Sachdeva on 08/01/21.
//

import UIKit

protocol TimeSelectedDelegate: class {
    func userDidSelectInformation(info: String)
}

class EditTicketTimeVC: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView : UITableView!
    var timeArray = NSArray()
    
    var totalSeats : Int = 0
    weak var delegate: TimeSelectedDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func onClickCloseAcn(){
        self.dismiss(animated: true, completion: nil)
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
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AgentBookingTblCell")! as! AgentBookingTblCell
        let data = timeArray.object(at: indexPath.section) as! NSDictionary
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.vwDashedLine.makeDashedBorderLine()
        print(data)
        
        cell.lblTimeSlot.text = (data["time"] as! String)
        let aleadyBookedSeats =  (data["alreadyBooked"] as! Int)

        let availableSeats = totalSeats - aleadyBookedSeats
        cell.lblLeftSeats.text = String("\(availableSeats)")
            
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = timeArray.object(at: indexPath.section) as! NSDictionary
        delegate?.userDidSelectInformation(info: (data["time"] as! String))
        dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return timeArray.count
    }

}
