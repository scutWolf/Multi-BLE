//
//  PeersTableViewCell.swift
//  Muti-BLE
//
//  Created by Wolf on 16/5/27.
//  Copyright © 2016年 Wolf. All rights reserved.
//

import UIKit

class PeersTableViewCell: UITableViewCell {

    @IBOutlet var peerNameLabel: UILabel!
    @IBOutlet var displayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(peerName:String){
        if peerName.characters.count > 0{
            self.displayLabel.text = peerName.substringToIndex(peerName.startIndex.advancedBy(1))
        }
        self.peerNameLabel.text = peerName
    }

}
