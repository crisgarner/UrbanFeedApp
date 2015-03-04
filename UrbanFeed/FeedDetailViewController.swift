//
//  FeedDetailViewController.swift
//  UrbanFeed
//
//  Created by Cristian Garner on 2/27/15.
//  Copyright (c) 2015 Cristian Garner. All rights reserved.
//

import UIKit

class FeedDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    var feedId:String?
    var feedName:String?
    
    var notificationsData: NSMutableArray = []
    var userFeeds = Array<String>()
    var api : APIController?
    var imageCache = [String : UIImage]()
    let kCellIdentifier: String = "NotificationFeedCell"
    @IBOutlet var notificationsTableView: UITableView!
    
    @IBOutlet var addFeedButton: UIBarButtonItem!

    override func viewDidLoad() {
        addFeedButton.tintColor = UIColor.whiteColor()
        addFeedButton.title = "        "
        addFeedButton.enabled = false
        var attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.tabBarController?.tabBar.selectedImageTintColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.selectedImageTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor =  UIColor.whiteColor()
        self.notificationsTableView?.rowHeight = UITableViewAutomaticDimension
        super.viewDidLoad()
        var nib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        notificationsTableView?.registerNib(nib, forCellReuseIdentifier: kCellIdentifier)
        api = APIController(delegate: self)
        self.notificationsTableView?.estimatedRowHeight = 107.0
        self.notificationsTableView?.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.api!.getNotifications(self.feedId!)
    }
    
    @IBAction func addFeed(sender: AnyObject) {
        
        var channel = self.feedId
        var installation:PFInstallation = PFInstallation.currentInstallation()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let identifier = defaults.stringForKey("UserIdentifier"){
            api!.addFeed(identifier, shortId: channel!)
        }
        if (installation.channels == nil)
        {
            installation.channels = NSArray()
        }
        installation.addUniqueObject(channel, forKey: "channels")
        installation.saveEventually()
        addFeedButton.title = "        "
        addFeedButton.enabled = false

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NotificationTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as NotificationTableViewCell
        var rowData: NSDictionary = self.notificationsData[indexPath.row] as NSDictionary
        cell.loadItem(owner: rowData["channel_name"] as String, title: rowData["title"] as String,message: rowData["content"] as String)
        return cell
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        /*var rowData: NSDictionary = self.feedsData[indexPath.row] as NSDictionary
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
        api?.deleteFeed(rowData["id"]!.stringValue)
        feedsData.removeObjectAtIndex(indexPath.row)
        self.feedsTableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        Flurry.logEvent("Business_Feed_Deleted")
        }*/
    }
    
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        
        var shareAction = UITableViewRowAction(style: .Default, title: "Share") { (action, indexPath) -> Void in
            var rowData: NSDictionary = self.notificationsData[indexPath.row] as NSDictionary
            var caption = (rowData["channel_name"] as String) + ": " + (rowData["content"] as String)
            let objectsToShare = [caption]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = ([UIActivityTypePrint, UIActivityTypeAssignToContact,UIActivityTypeAirDrop,UIActivityTypePostToVimeo])
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
        shareAction.backgroundColor = UIColor.grayColor()
        // return [deleteAction, shareAction] No feed share for this version
        return [shareAction]
    }
    
    
    func didReceiveAPIResults(results: NSArray, message: String, methodCaller: String) {
        var resultsArr: NSArray = results
        if methodCaller == "getUserFeed" {
            if(!resultsArr.containsObject(self.feedId!)){
                addFeedButton.title = "Add Feed"
                addFeedButton.enabled = true
            }
        }else{
            if message != "" {
                var alert: UIAlertView = UIAlertView()
                alert.title = "Notification"
                alert.message = message
                alert.addButtonWithTitle("Ok")
                alert.show()
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.notificationsData = NSMutableArray(array:resultsArr)
                    self.notificationsTableView!.reloadData()
                    let defaults = NSUserDefaults.standardUserDefaults()
                    if let identifier = defaults.stringForKey("UserIdentifier"){
                        self.api!.getUserFeeds(identifier)
                    }
                })
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

}
