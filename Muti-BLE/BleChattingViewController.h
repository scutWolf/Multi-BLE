//
//  BleChattingViewController.h
//  Muti-BLE
//
//  Created by Wolf on 16/5/23.
//  Copyright © 2016年 Wolf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessagesViewController.h"
#import "JSQMessages.h"

@interface BleChattingViewController : JSQMessagesViewController<UIActionSheetDelegate>

@property (strong,nonatomic) NSString *roomName;

@end
