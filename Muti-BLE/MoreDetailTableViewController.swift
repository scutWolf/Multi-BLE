//
//  MoreDetailTableViewController.swift
//  Muti-BLE
//
//  Created by Wolf on 16/5/27.
//  Copyright © 2016年 Wolf. All rights reserved.
//

import UIKit

class MoreDetailTableViewController: UITableViewController {

    @IBOutlet var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.configureViews()
        self.tableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)

    }

    func configureViews(){
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            self.userNameLabel.text = appDelegate.chattingUserName
        }
        self.tableView.tableFooterView = UIView()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "修改名字", message: "输入要修改的名字", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler { (textField:UITextField) -> Void in
                textField.keyboardType = UIKeyboardType.Default
            }
            
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default,handler: { (action:UIAlertAction) -> Void in
                
                let textField = alert.textFields?.first
                if let text = textField?.text{
                    if text.characters.count == 0{
                        return
                    }
                    NSUserDefaults.standardUserDefaults().setObject(text, forKey: "chatingUserName")
                    self.configureViews()
                    
                    let completeAlert = UIAlertController(title: "成功", message: "修改成功", preferredStyle: UIAlertControllerStyle.Alert)
                    let okay = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil)
                    completeAlert.addAction(okay)
                    self.presentViewController(completeAlert, animated: true, completion: nil)

                }
            })
            alert.addAction(cancel)
            alert.addAction(ok)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

}
