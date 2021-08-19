//
//  AgentListTblCell.swift
//  WTM
//
//  Created by Tarun Sachdeva on 27/12/20.
//

import UIKit

class AgentListTblCell: UITableViewCell {

    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblEmail : UILabel!
    @IBOutlet weak var lblEnrollDate : UILabel!
    @IBOutlet weak var lblAgentPIN : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
