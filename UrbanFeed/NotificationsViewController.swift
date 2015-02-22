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
    
    @IBOutlet var notificationsTableView: UITableView!

    override func viewDidLoad() {
        self.tabBarController?.tabBar.selectedImageTintColor = UIColor.whiteColor()
        self.notificationsTableView?.rowHeight = UITableViewAutomaticDimension
        super.viewDidLoad()
        var nib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        notificationsTableView?.registerNib(nib, forCellReuseIdentifier: kCellIdentifier)
        api = APIController(delegate: self)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
       // var installation:PFInstallation = PFInstallation.currentInstallation()
        if let installation:PFInstallation = PFInstallation.currentInstallation(){
            api!.getUserFeeds(installation.objectId)
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
        if message != "" {
            var alert: UIAlertView = UIAlertView()
            alert.title = "Notification"
            alert.message = message
            alert.addButtonWithTitle("Ok")
            alert.show()
        }else{
            if methodCaller == "getUserFeed" {
                dispatch_async(dispatch_get_main_queue(), {
                    self.userFeeds = resultsArr as Array<String>
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
