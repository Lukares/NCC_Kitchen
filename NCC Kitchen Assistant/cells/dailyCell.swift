//
//  dailyCell.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 4/2/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit

class dailyCell: UITableViewCell {

    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var completedSwitch: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
