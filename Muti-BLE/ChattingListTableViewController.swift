//
//  ChattingListTableViewController.swift
//  Muti-BLE
//
//  Created by Wolf on 16/5/27.
//  Copyright © 2016年 Wolf. All rights reserved.
//

import UIKit

class ChattingRoom:NSObject,NSCoding{
    
    var roomName:String
    var lastMessage:String?
    
    init(roomName:String){
        self.roomName = roomName
    }
    
    func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(self.roomName, forKey: "roomName")
        aCoder.encodeObject(self.lastMessage, forKey: "lastMessage")
    }
    
    required init?(coder aDecoder: NSCoder){
        if let name = aDecoder.decodeObjectForKey("roomName"){
            self.roomName = name as! String
        }
        else{
            self.roomName = "???"
            assert(false,"nil room name")
        }
        self.lastMessage = aDecoder.decodeObjectForKey("lastMessage") as? String
    }
}


class ChattingListTableViewController: UITableViewController {

    var rooms:[ChattingRoom] = []
    let defaultName = "公开聊天室"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let data:NSData = NSUserDefaults.standardUserDefaults().objectForKey("roomListArray") as? NSData{
            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [ChattingRoom]{
                self.rooms.removeAll()
                self.rooms.appendContentsOf(array)
            }
        }
        self.configureRoomList()
        self.tableView.reloadData()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
    }

    @IBAction func didAddButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "新建房间", message: "输入房间名字", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField:UITextField) -> Void in
            textField.keyboardType = UIKeyboardType.Default
        }
        
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default,handler: { (action:UIAlertAction) -> Void in
            
            let textField = alert.textFields?.first
            if let text = textField?.text{
                if text.characters.count > 0 && text != self.defaultName{
                    for room in self.rooms{
                        if room.roomName == text{
                            //log
                            return
                        }
                    }
                    
                    let room = ChattingRoom(roomName: text)
                    self.rooms.append(room)
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.rooms.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                    NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(self.rooms), forKey: "roomListArray")
                }
                else{
                    //log something
                }
            }
        })
        
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func configureRoomList(){
        var isDefaultExist = false
        for room in rooms{
            if room.roomName == self.defaultName{
                isDefaultExist = true
                break
            }
        }
        if !isDefaultExist{
            let room = ChattingRoom(roomName: self.defaultName)
            self.rooms.insert(room, atIndex: 0)
        }
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(self.rooms), forKey: "roomListArray")

    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.rooms.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChattingRoomCell", forIndexPath: indexPath) as! ChattingRoomTableViewCell

        cell.configureCellWith(self.rooms[indexPath.row])

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("pushToChat", sender: indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle==UITableViewCellEditingStyle.Delete{
            self.rooms.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(self.rooms), forKey: "roomListArray")
            // to delete history too
        }
        
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0{
            return false
        }
        return true 
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let controller = segue.destinationViewController as? BleChattingViewController{
            if let indexPath = sender as? NSIndexPath{
                let room = self.rooms[indexPath.row]
                controller.roomName = room.roomName
            }
        }
        
    }
 

}
