//
//  AgentRequestTblCell.swift
//  WTM
//
//  Created by Tarun Sachdeva on 27/12/20.
//

import UIKit

class AgentRequestTblCell: UITableViewCell {

    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblEmail : UILabel!
    @IBOutlet weak var lblEnrollDate : UILabel!
    @IBOutlet weak var btnApprove : UIButton!
    @IBOutlet weak var btnReject : UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
