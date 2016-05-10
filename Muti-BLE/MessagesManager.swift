//
//  MessagesManager.swift
//  Muti-BLE
//
//  Created by Wolf on 16/5/10.
//  Copyright © 2016年 Wolf. All rights reserved.
//

import UIKit

class MessagesManager: NSObject {

    lazy var multiConnetManager:MultiConnectManager = {
    
        let manager = MultiConnectManager()
        
        
        
        return manager
        
    }()
    
    
}
