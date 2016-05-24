//
//  MultiConnectManager.swift
//  Muti-BLE
//
//  Created by Wolf on 16/5/3.
//  Copyright © 2016年 Wolf. All rights reserved.
//

import UIKit
import MultipeerConnectivity

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
//        default: return "Unknown"
        }
    }
    
}

@objc protocol MultiConnectManagerDelegate {
    func didMultiConnectPeerChangeState(peer:MCPeerID,state: MCSessionState)
    func didMultiConnectConnectPeersCountChanges(count:Int)
    func didMultiConnectSendMessage(message:String)
    func didMultiConnectReceivedMessage(message:String,displayName:String,uuid:String)
    func didMultiConnectError(error:NSError)
    func didMultiConnectAlert(alert:String)
}
//
//protocol MessageManagerDelegate {
//    func didLog(string:String)
////    func didLog(string:String)
//    
//}

class MultiConnectManager: NSObject {
    private let serviceType = "mul-ple-wf"
    
    private let myPeerId:MCPeerID
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
//    var logDelegate:MessageManagerDelegate?
    var delegate:MultiConnectManagerDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
        session.delegate = self
        return session
    }()
    
    init(displayName:String,uuid:String) {
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            let uuid = appDelegate.uuid
            self.myPeerId = MCPeerID(displayName: "\(displayName)[ble]\(uuid)")
        }
        else{
            self.myPeerId = MCPeerID(displayName: "guest[ble]testing")
        }
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()

        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        //browser
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()

    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func start(){
    
    }
    
    func sendNewMessage(string:String){
        
        if self.session.connectedPeers.count == 0 {
//            self.delegate?.didMultiConnectAlert("no connected peers")
            self.delegate?.didMultiConnectAlert("no connected peers")
            return
        }
        
        var peers = [self.myPeerId.displayName]
        for peer in self.session.connectedPeers{
            peers.append(peer.displayName)
        }
        
        self.send(["message":string,"peers":peers], peers: self.session.connectedPeers)
    }
    
    //message:["message":"","peers":[peer.displayname]]
    private func send(message:[String:AnyObject],peers:[MCPeerID]){
//        
//        if let data = NSKeyedArchiver.archivedDataWithRootObject(message){
//        }
//        self.delegate?.didMultiConnectAlert("send:\(message)")

        let data = NSKeyedArchiver.archivedDataWithRootObject(message)
        do{
            try self.session.sendData(data, toPeers:peers, withMode: MCSessionSendDataMode.Reliable)
        }
        catch{
            self.delegate?.didMultiConnectAlert("\(error)");
            return
        }
        if let m = message["message"] as? String{
            self.delegate?.didMultiConnectSendMessage(m)
        }

    }
    
}


extension MultiConnectManager:MCNearbyServiceAdvertiserDelegate{

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Oops, have not started advertising! error :\(error)");
        self.delegate?.didMultiConnectAlert("Oops, have not started advertising! error :\(error)")
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("did received invitation from \(peerID.displayName)")
        self.delegate?.didMultiConnectAlert("did received invitation from \(peerID.displayName)")
        invitationHandler(true, self.session)
    }
}

extension MultiConnectManager: MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers: \(error)")
        self.delegate?.didMultiConnectAlert("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID.displayName)")
        self.delegate?.didMultiConnectAlert("lostPeer: \(peerID.displayName)")

    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID.displayName)")
        self.delegate?.didMultiConnectAlert("foundPeer: \(peerID.displayName)")
        //invite
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
}

extension MultiConnectManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        let s = "peer \(peerID.displayName) didChangeState: \(state.stringValue())"
        NSLog(s)
        self.delegate?.didMultiConnectAlert(s)
    
        self.delegate?.didMultiConnectPeerChangeState(peerID, state: state)
        self.delegate?.didMultiConnectConnectPeersCountChanges(self.session.connectedPeers.count)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {

        if let dict:NSDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String:AnyObject]{
            let s = "didReceiveData: \(dict["message"])"
            if let m = dict["message"] as? String{
                var displayname = "guest"
                var uuid = "test"
                let arr = peerID.displayName.componentsSeparatedByString("[ble]")
                if arr.count == 2{
                    displayname = arr[0]
                    uuid = arr[1]
                }
                self.delegate?.didMultiConnectReceivedMessage(m,displayName: displayname,uuid: uuid)
            }
            self.delegate?.didMultiConnectAlert("dict:\(dict)")
            self.delegate?.didMultiConnectAlert(s)
//            self.delegate?.didMultiConnectAlert(s)
            
            var peersToRepost:[MCPeerID] = []
            var peers:[String] = []
            if let array = dict.objectForKey("peers") as? [String]{
                peers += array
                for connectPeer in self.session.connectedPeers{
                    var exist = false
                    for peer in array{
                        if connectPeer.displayName == peer{
                            exist = true
                            break
                        }
                    }
                    if !exist{
                        peersToRepost.append(connectPeer)
                        peers.append(connectPeer.displayName)
                    }
                }
            }
            if peersToRepost.count != 0 {
                if let message = dict["message"]{
//
                    let toSend = ["message":message,"peers":peers]
                    self.send(toSend, peers: peersToRepost)
                }
            }
            
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
        let s = "didReceiveStream";
//        self.delegate?.didMultiConnectAlert(s)
        self.delegate?.didMultiConnectAlert(s)
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
        let s = "didFinishReceivingResourceWithName";
//        self.delegate?.didMultiConnectAlert(s)
        self.delegate?.didMultiConnectAlert(s)
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
        let s = "didStartReceivingResourceWithName";
        self.delegate?.didMultiConnectAlert(s)
//        self.delegate?.didMultiConnectAlert(s)
    }

    
}







