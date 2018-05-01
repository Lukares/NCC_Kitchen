//
//  mainCell.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 4/1/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit

class mainCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
