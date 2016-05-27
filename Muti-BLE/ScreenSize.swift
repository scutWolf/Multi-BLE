//
//  ScreenSize.swift
//  DXXD-NewPM-iOS
//
//  Created by Wolf on 15/9/19.
//  Copyright © 2015年 Wolf. All rights reserved.
//

import Foundation
import UIKit



class ScreenSize: NSObject {

    class func screenWidth()->CGFloat{
        let width = UIScreen.mainScreen().bounds.size.width
        return width
    }
    
    
    class func screenHeight()->CGFloat{
        let height = UIScreen.mainScreen().bounds.size.height
        return height
    }
}