//
//  AdminTicketListCell.swift
//  WTM
//
//  Created by Tarun Sachdeva on 15/12/20.
//

import UIKit

class AdminTicketListCell: UITableViewCell {

    @IBOutlet weak var lblAgentName : UILabel!
    @IBOutlet weak var lblBookingName : UILabel!
    @IBOutlet weak var lblStartTime : UILabel!
    @IBOutlet weak var lblReturnTime : UILabel!
    @IBOutlet weak var lblPassengers : UILabel!
    @IBOutlet weak var lblTripDate : UILabel!
    @IBOutlet weak var lblAdults : UILabel!
    @IBOutlet weak var lblComment : UILabel!
    @IBOutlet weak var lblTicketID : UILabel!
    @IBOutlet weak var lblDeparture : UILabel!
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var lblStartDepartureStatus : UILabel!
    @IBOutlet weak var lblReturnDepartureStatus : UILabel!
    @IBOutlet weak var lblTripType : UILabel!
    @IBOutlet weak var lblSqaureCode : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
