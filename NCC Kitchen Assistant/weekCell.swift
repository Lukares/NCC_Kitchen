//
//  weekCell.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 2/27/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit

class weekCell: UITableViewCell {

    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet var dayLabels: [UILabel]!
    @IBOutlet weak var clientButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
