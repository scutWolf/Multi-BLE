//
//  PeersListTableViewController.swift
//  Muti-BLE
//
//  Created by Wolf on 16/5/27.
//  Copyright © 2016年 Wolf. All rights reserved.
//

import UIKit

@objc protocol PeerListDelegate{
    func didPeerListStartSingleChatting(target:String)
}

class PeersListTableViewController: UITableViewController {

    var peers:[String] = []
    weak var delegate:PeerListDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
    }
    
    func configurePeers(array:NSArray){
        self.peers.removeAll()
        for i in 0..<array.count{
            if let ele = array[i] as? String{
                self.peers.append(ele)
            }
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peers.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PeerCell", forIndexPath: indexPath) as! PeersTableViewCell

        cell.configureCell(self.peers[indexPath.row])
        
        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let alert = UIAlertController(title: "发起单聊", message: "是否发起单聊？", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        let okay = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) -> Void in
            
            self.delegate?.didPeerListStartSingleChatting(self.peers[indexPath.row])
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(cancel)
        alert.addAction(okay)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

}
