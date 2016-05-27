//
//  ChattingRoomTableViewCell.swift
//  Muti-BLE
//
//  Created by Wolf on 16/5/27.
//  Copyright © 2016年 Wolf. All rights reserved.
//

import UIKit

class ChattingRoomTableViewCell: UITableViewCell {

    @IBOutlet var avatarLabel: UILabel!
    @IBOutlet var roomLabel: UILabel!
    @IBOutlet var lastMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCellWith(chattingRoom:ChattingRoom){
        let name = chattingRoom.roomName
        if name.characters.count > 0{
            self.avatarLabel.text = name.substringToIndex(name.startIndex.advancedBy(1))
        }
        self.roomLabel.text = name == "Default" ? "公开聊天室" : name
        self.lastMessageLabel.text = chattingRoom.lastMessage
    }

}
