//
//  AgentBookingTblCell.swift
//  WTM
//
//  Created by Tarun Sachdeva on 30/11/20.
//

import UIKit

class AgentBookingTblCell: UITableViewCell {

    
    @IBOutlet weak var lblTimeSlot : UILabel!
    @IBOutlet weak var lblLeftSeats : UILabel!
    @IBOutlet weak var vwDashedLine : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
