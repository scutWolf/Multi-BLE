//
//  BleChattingViewController.m
//  Muti-BLE
//
//  Created by Wolf on 16/5/23.
//  Copyright © 2016年 Wolf. All rights reserved.
//

#import "BleChattingViewController.h"
#import "MBProgressHUD.h"
#import "Muti_BLE-Swift.h"

@interface BleChattingViewController ()<MultiConnectManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PeerListDelegate>

@property (strong,nonatomic) NSMutableArray *messages;
@property (assign,nonatomic) NSInteger connectedCount;
@property (strong,nonatomic) MultiConnectManager *manager;
@property (strong,nonatomic) NSString *displayName;
@property (strong,nonatomic) NSString *uuid;
//@property (strong,nonatomic) NSString
@property (assign,nonatomic) bool isSingleChatting;
@property (strong,nonatomic) NSString *charttingTarget;
@property (assign,nonatomic) bool targetExist;
@property (strong,nonatomic) NSString *inviteString;
@end

@implementation BleChattingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.title = @"Multi-BLE";
    self.connectedCount = 0 ;

    self.uuid = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).uuid;
    self.displayName = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chattingUserName;
    
    self.senderId = self.uuid;
    self.senderDisplayName = self.displayName;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;

//    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    if (!self.roomName){
        self.roomName = @"Default";
    }
    NSString *serviceType = [NSString stringWithFormat:@"mulple-%lu",self.roomName.hash%10000];
    
    self.manager = [[MultiConnectManager alloc]initWithDisplayName:self.displayName uuid:self.uuid serviceType:serviceType];
    self.manager.delegate = self;
//    [self.manager start];
    
    
    /**
     *  OPT-IN: allow cells to be deleted
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    

    
}

-(NSString *)inviteString{
    return @"邀请你进入单聊。";
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.manager = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)messages{
    if(!_messages){
        _messages = [NSMutableArray array];
    }
    return _messages;
}

-(void)setConnectedCount:(NSInteger)connectedCount{
//
//    dispatch_async(dispatch_get_main_queue()) {
//        self.title = "已连接：\(self.connectedCount)个"
//    }
//
    _connectedCount = connectedCount;
    if (_isSingleChatting){
        return ;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
       self.title = [NSString stringWithFormat:@"%@（%ld）",self.roomName,connectedCount];
    });
}

-(void)setIsSingleChatting:(bool)isSingleChatting{
    _isSingleChatting = isSingleChatting;
    if (isSingleChatting){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = self.charttingTarget;
            self.targetExist = _targetExist;
        });
        [self removeAll];

    }
    else{
        self.charttingTarget = nil;
        self.connectedCount = _connectedCount;
        [self removeAll];
        
    }
}

-(void)setTargetExist:(bool)targetExist{
    _targetExist = targetExist;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = [NSString stringWithFormat:@"%@(已断开连接)",self.charttingTarget];
    });
}

-(void)removeAll{
    NSInteger count = self.messages.count;
    [self.messages removeAllObjects];
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0;i<count;i++){
        [array addObject:([NSIndexPath indexPathForRow:i inSection:0])];
    }
    [self.collectionView deleteItemsAtIndexPaths:array];
}

-(void)sendImage:(UIImage *)image{
    id<JSQMessageMediaData> newMediaData = [[JSQPhotoMediaItem alloc]initWithImage:image];
    JSQMessage *newMessage = [JSQMessage messageWithSenderId:self.uuid
                                                 displayName:self.displayName
                                                       media:newMediaData];
    
    [self.messages addObject:newMessage];
    
//    [self.manager sendNewMessage:text];
    
    [self finishSendingMessageAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.messages addObject:message];
    
    if (!self.isSingleChatting){
        [self.manager sendNewMessage:text];
    }
    else{
        [self.manager sendPrivateMessage:text target:self.charttingTarget];
    }
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
//    [self.inputToolbar.contentView.textView resignFirstResponder];
//    
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", @"Send audio", nil];
//    
//    [sheet showFromToolbar:self.inputToolbar];
    
    [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.messages objectAtIndex:indexPath.row];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }
    
    return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 4 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    
    JSQMessage *message = self.messages[indexPath.row];
    if ([message.text isEqualToString:self.inviteString] && message.senderId != self.senderId){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"邀请单聊" message:@"是否单聊？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"加入" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self joinPivateChatting:[MultiConnectManager peerName:message.senderDisplayName uuid:message.senderId]];
            
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}
//
//#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods
//
//
//- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
//{
////    if ([UIPasteboard generalPasteboard].image) {
////        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
////        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
////        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
////                                                 senderDisplayName:self.senderDisplayName
////                                                              date:[NSDate date]
////                                                             media:item];
////        [self.messages addObject:message];
////        [self finishSendingMessage];
////        return NO;
////    }
////    return YES;
//}

#pragma mark - message delegate 

-(void)didMultiConnectError:(NSError *)error{

}

-(void)didMultiConnectSendMessage:(NSString *)message{
    //success
}


-(void)didMultiConnectReceivedMessage:(NSString *)message displayName:(NSString *)displayName uuid:(NSString *)uuid{
    
    if (self.isSingleChatting){
        return;
    }
    
    self.showTypingIndicator = !self.showTypingIndicator;

    [self scrollToBottomAnimated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:uuid
                                                    senderDisplayName:displayName
                                                                 date:[NSDate date]
                                                                 text:message];
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
    });

}

-(void)didMultiConnectReceivedPrivateMessage:(NSString *)message displayName:(NSString *)displayName uuid:(NSString *)uuid{
    self.showTypingIndicator = !self.showTypingIndicator;
    
    [self scrollToBottomAnimated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:uuid
                                                    senderDisplayName:displayName
                                                                 date:[NSDate date]
                                                                 text:message];
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
    });

}

-(void)didMultiConnectPeerChangeState:(MCPeerID *)peer state:(MCSessionState)state{

}

-(void)didMultiConnectAlert:(NSString *)alert{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.uuid
//                                                 senderDisplayName:self.displayName
//                                                              date:[NSDate date]
//                                                              text:[NSString stringWithFormat:@"log: %@",alert]];
//        
//        [self.messages addObject:message];
//        
//        [self finishSendingMessageAnimated:YES];
//    
//    });
}

-(void)didMultiConnectConnectPeersCountChanges:(NSInteger)count{
    self.connectedCount = count;
}

-(void)didMultiConnectSharePeersChanged:(NSArray<NSString *> *)peers{
    if (self.isSingleChatting){
        bool exist = NO;
        for (NSString *peer in peers){
            if ([peer isEqualToString:self.charttingTarget]){
                exist = YES;
            }
        }
        self.targetExist = exist;
    }
}

#pragma mark - image picker methods

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    picker.allowsEditing = NO;
    
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    
    //获得编辑过的图片
    UIImage* image = [info objectForKey: @"UIImagePickerControllerOriginalImage"];
    
    //    [self uploadImage:image];
    [self sendImage:image];
    
    [self dismissImagePickerController:picker];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    //    [self uploadImage:image];
    [self sendImage:image];
    
    [self dismissImagePickerController:picker];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissImagePickerController:picker];
    
}

- (void)dismissImagePickerController:(UIImagePickerController *)picker
{
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - peer list deleagte


-(void)didPeerListStartSingleChatting:(NSString *)target{

    [self joinPivateChatting:target];
    [self.manager sendPrivateMessage:self.inviteString target:self.charttingTarget];
}

-(void)joinPivateChatting:(NSString *)target{
    self.charttingTarget = target;
    self.isSingleChatting = YES;
    
    if (self.isSingleChatting){
        bool exist = NO;
        for (NSString *peer in self.manager.allPeers){
            if ([peer isEqualToString:self.charttingTarget]){
                exist = YES;
            }
        }
        self.targetExist = exist;
    }
}

#pragma  mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[PeersListTableViewController class]]){
        PeersListTableViewController *controller = segue.destinationViewController;
        [controller configurePeers:self.manager.allPeers];
        controller.delegate = self;
    }

}




@end
