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

protocol MultiConnectManagerDelegate {
    func didPeerChangeState(peer:MCPeerID,state: MCSessionState)
    func didConnectPeersCountChanges(count:Int)
    func didSendMessage(message:String)
    func didReceivedMessage(message:String)
    func didMultiConnectError(error:NSError)
}

protocol MessageManagerDelegate {
    func didLog(string:String)
//    func didLog(string:String)
    
}

class MultiConnectManager: NSObject {
    private let serviceType = "mul-ple-wf"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser

    var logDelegate:MessageManagerDelegate?
    var delegate:MultiConnectManagerDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    override init() {


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
            self.logDelegate?.didLog("no connected peers")
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
        self.logDelegate?.didLog("send:\(message)")

        let data = NSKeyedArchiver.archivedDataWithRootObject(message)
        do{
            try self.session.sendData(data, toPeers:peers, withMode: MCSessionSendDataMode.Reliable)
        }
        catch{
            self.logDelegate?.didLog("\(error)");
        }

    }
    
}


extension MultiConnectManager:MCNearbyServiceAdvertiserDelegate{

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Oops, have not started advertising! error :\(error)");
        self.logDelegate?.didLog("Oops, have not started advertising! error :\(error)")
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("did received invitation from \(peerID.displayName)")
        self.logDelegate?.didLog("did received invitation from \(peerID.displayName)")
        invitationHandler(true, self.session)
    }
}

extension MultiConnectManager: MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers: \(error)")
        self.logDelegate?.didLog("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID.displayName)")
        self.logDelegate?.didLog("lostPeer: \(peerID.displayName)")

    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID.displayName)")
        self.logDelegate?.didLog("foundPeer: \(peerID.displayName)")
        //invite
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
}

extension MultiConnectManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        let s = "peer \(peerID.displayName) didChangeState: \(state.stringValue())"
        NSLog(s)
        self.logDelegate?.didLog(s)
        self.logDelegate?.didLog(s)
    
        self.delegate?.didPeerChangeState(peerID, state: state)
        self.delegate?.didConnectPeersCountChanges(self.session.connectedPeers.count)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {

        if let dict:NSDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String:AnyObject]{
            let s = "didReceiveData: \(dict["message"])"
            self.logDelegate?.didLog("dict:\(dict)")
            self.logDelegate?.didLog(s)
//            self.logDelegate?.didLog(s)
            
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
//        self.logDelegate?.didLog(s)
        self.logDelegate?.didLog(s)
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
        let s = "didFinishReceivingResourceWithName";
//        self.logDelegate?.didLog(s)
        self.logDelegate?.didLog(s)
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
        let s = "didStartReceivingResourceWithName";
        self.logDelegate?.didLog(s)
//        self.logDelegate?.didLog(s)
    }
    
}







