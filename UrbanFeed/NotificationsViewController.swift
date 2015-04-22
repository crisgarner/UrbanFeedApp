//
//  NotificationsViewController.swift
//  UrbanFeed
//
//  Created by Cristian Garner on 2/22/15.
//  Copyright (c) 2015 Cristian Garner. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    var notificationsData: NSMutableArray = []
    let kCellIdentifier: String = "NotificationCell"
    var userFeeds = Array<String>()
    var api : APIController?
    var imageCache = [String : UIImage]()
    var channels = ""
    
    @IBOutlet var locationButton: UIBarButtonItem!
    @IBOutlet var notificationsTableView: UITableView!

    override func viewDidLoad() {
        locationButton.tintColor = UIColor.whiteColor()
        var attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
        self.notificationsTableView?.rowHeight = UITableViewAutomaticDimension
        super.viewDidLoad()
        var nib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        notificationsTableView?.registerNib(nib, forCellReuseIdentifier: kCellIdentifier)
        api = APIController(delegate: self)
        self.notificationsTableView!.reloadData()
        self.notificationsTableView?.estimatedRowHeight = 107.0
        self.notificationsTableView?.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
       // var installation:PFInstallation = PFInstallation.currentInstallation()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userCreated = defaults.stringForKey("UserCreated"){
            if let identifier = defaults.stringForKey("UserIdentifier"){
                api!.getUserFeeds(identifier)
            }
        }else{
            if let identifier = defaults.stringForKey("UserIdentifier"){
                 api!.addUser(identifier)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NotificationTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! NotificationTableViewCell
        var rowData: NSDictionary = self.notificationsData[indexPath.row] as! NSDictionary
        var dateArray = (rowData["date"] as! String).componentsSeparatedByString("T")
        var dateTime =  dateArray[1].componentsSeparatedByString(":")
        var date =  dateTime[0] + ":" +  dateTime[1] + " " + dateArray[0]
        cell.loadItem(owner: rowData["channel_name"] as! String, title: rowData["title"] as! String,message: rowData["content"] as! String, date:date)
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        /*var rowData: NSDictionary = self.feedsData[indexPath.row] as NSDictionary
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
        api?.deleteFeed(rowData["id"]!.stringValue)
        feedsData.removeObjectAtIndex(indexPath.row)
        self.feedsTableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        Flurry.logEvent("Business_Feed_Deleted")
        }*/
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var shareAction = UITableViewRowAction(style: .Default, title: "Share") { (action, indexPath) -> Void in
            var rowData: NSDictionary = self.notificationsData[indexPath.row] as! NSDictionary
            var caption = (rowData["channel_name"] as! String) + ": " + (rowData["content"] as! String)
            let objectsToShare = [caption]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = ([UIActivityTypePrint, UIActivityTypeAssignToContact,UIActivityTypeAirDrop,UIActivityTypePostToVimeo])
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
        shareAction.backgroundColor = UIColor.grayColor()
        var flagAction = UITableViewRowAction(style: .Default, title: "Report") { (action, indexPath) -> Void in
            var rowData: NSDictionary = self.notificationsData[indexPath.row] as! NSDictionary
            self.api?.flagMessage(rowData["id"] as! String, channel_id: rowData["channel_id"] as! String)
        }
        flagAction.backgroundColor = UIColor.redColor()
        return [shareAction, flagAction]

    }
    
    
    func didReceiveAPIResults(results: NSArray, message: String, methodCaller: String) {
        var resultsArr: NSArray = results
        
        if methodCaller == "addUser" {
            if message == "success"{
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject("true", forKey: "UserCreated")
            }else{
                println("Couldn't add USer")
            }
        }else{
            if methodCaller == "flagMessage" {
                var alert: UIAlertView = UIAlertView()
                alert.title = "Notification"
                alert.message = "Message has been flagged administrators will take care of it"
                alert.addButtonWithTitle("Ok")
                alert.show()
                
            }else{
                if message != "" {
                    var alert: UIAlertView = UIAlertView()
                    alert.title = "Notification"
                    alert.message = message
                    alert.addButtonWithTitle("Ok")
                    alert.show()
                }else{
                    if methodCaller == "getUserFeed" {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.userFeeds = resultsArr as! Array<String>
                            self.channels = ""
                            var first = true
                            for feed in self.userFeeds{
                                if first{
                                    first = false
                                    self.channels += feed
                                }else{
                                    self.channels += "," + feed
                                }
                                
                                
                            }
                            self.api!.getNotifications(self.channels)
                        })
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.notificationsData = NSMutableArray(array:resultsArr)
                            self.notificationsTableView!.reloadData()
                        })
                    }
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func dateformatterDateString(dateString: NSString) -> NSDate?
    {
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        
        return dateFormatter.dateFromString(dateString as String)
    }


}
