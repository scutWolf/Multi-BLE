//
//  ViewController.swift
//  Muti-BLE
//
//  Created by Wolf on 16/5/3.
//  Copyright © 2016年 Wolf. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class ViewController: UIViewController,MessageManagerDelegate,MultiConnectManagerDelegate {

    @IBOutlet var firstTextView: UITextView!
//    @IBOutlet var secondTextView: UITextView!
    
    var manager:MultiConnectManager?
    
    var adString:String = ""
    var broString:String = ""
    var connectedCount = 0 {
        didSet{
            dispatch_async(dispatch_get_main_queue()) {
                self.title = "已连接：\(self.connectedCount)个"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectedCount = 0
        // Do any additional setup after loading the view, typically from a nib.
        
        self.manager = MultiConnectManager()
        manager!.logDelegate = self
        manager!.delegate = self
        manager!.start()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sayGoodBye(sender: AnyObject) {
        self.manager?.sendNewMessage("good bye")
    }
    @IBAction func sayHi(sender: AnyObject) {
        self.manager?.sendNewMessage("hi")
    }
    
//    func didAdvertiser(string:String){
//        self.adString = self.adString + string + "\n"
//        dispatch_async(dispatch_get_main_queue()) {
//            self.firstTextView.text = self.adString
//        }
//    }
//    
    func didLog(string: String) {
        self.adString = self.adString + string + "\n"
        dispatch_async(dispatch_get_main_queue()) {
            self.firstTextView.text = self.adString
        }
    }
    
//    func didBrowser(string:String){
//        self.broString = self.broString + string + "\n"
//        dispatch_async(dispatch_get_main_queue()) {
//            self.secondTextView.text = self.broString
//        }
//    }
    func didMultiConnectPeerChangeState(peer:MCPeerID,state: MCSessionState){
    
    }
    
    func didMultiConnectConnectPeersCountChanges(count:Int){
        self.connectedCount = count
    }
    func didMultiConnectSendMessage(message:String){}
    func didMultiConnectReceivedMessage(message:String){}
    func didMultiConnectError(error:NSError){}



}

