//
//  AgentBookingReturnTblCell.swift
//  WTM
//
//  Created by Tarun Sachdeva on 08/12/20.
//

import UIKit

class AgentBookingReturnTblCell: UITableViewCell {

    @IBOutlet weak var lblTimeSlot : UILabel!
    @IBOutlet weak var lblLeftSeats : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
