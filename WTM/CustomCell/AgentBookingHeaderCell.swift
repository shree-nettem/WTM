//
//  AgentBookingHeaderCell.swift
//  WTM
//
//  Created by Tarun Sachdeva on 03/12/20.
//

import UIKit

class AgentBookingHeaderCell: UITableViewCell {

    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnHide : UIButton!
    @IBOutlet weak var imgStatus : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
