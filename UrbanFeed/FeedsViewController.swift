//
//  FeedsViewController.swift
//  UrbanFeed
//
//  Created by Cristian Garner on 2/21/15.
//  Copyright (c) 2015 Cristian Garner. All rights reserved.
//

import UIKit

class FeedsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FeedTableProtocol, APIControllerProtocol {

   // var feedsData: NSMutableArray = []
    var feedsData: NSMutableArray = []
    let kCellIdentifier: String = "FeedCell"
    var userFeeds = Array<String>()
    var api : APIController?
    var imageCache = [String : UIImage]()
    
    @IBOutlet var feedsTableView: UITableView!
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.selectedImageTintColor = UIColor.whiteColor()
        super.viewDidLoad()
        var nib = UINib(nibName: "FeedTableViewCell", bundle: nil)
        feedsTableView?.registerNib(nib, forCellReuseIdentifier: kCellIdentifier)
        api = APIController(delegate: self)


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        var installation:PFInstallation = PFInstallation.currentInstallation()
        api!.getUserFeeds(installation.objectId)
        api!.getFeeds()
        self.feedsTableView!.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FeedTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as FeedTableViewCell
        cell.delegate = self
        var rowData: NSDictionary = self.feedsData[indexPath.row] as NSDictionary
        if(contains(self.userFeeds, String(rowData["short_id"] as String))){
            // println(rowData["feed_id"])
            cell.loadItem(feedName: rowData["name"] as String, image: UIImage(named: "Blank52")!)
        }else{
            cell.loadItem(feedName: rowData["name"] as String, image: UIImage(named: "Blank52")!,indexPath:indexPath)
        }
        
        let urlString = (rowData["logo_url"] as String)
        var image = self.imageCache[urlString]
        
        
        if( image == nil ) {
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: urlString)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FeedTableViewCell {
                            //cellToUpdate.imageView?.image = image
                            //  cellToUpdate.productImage.image = nil
                            cellToUpdate.logo.image = image
                            //   tableView.reloadData()
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FeedTableViewCell {
                    cellToUpdate.logo.image = image
                }
            })
        }
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

        var deleteAction = UITableViewRowAction(style: .Default, title: "Unfollow") { (action, indexPath) -> Void in
            tableView.editing = false
            var rowData: NSDictionary = self.feedsData[indexPath.row] as NSDictionary
            var installation:PFInstallation = PFInstallation.currentInstallation()
            self.api!.deleteFeed(installation.objectId, shortId: rowData["short_id"] as String)
            if (installation.channels == nil)
            {
                installation.channels = NSArray()
            }
            var channel = (rowData["name"] as String)
            channel = channel.stringByReplacingOccurrencesOfString(" ", withString: "")
            installation.removeObject(channel, forKey: "channels")
            installation.saveInBackground()

      //      self.feedsData.removeObjectAtIndex(indexPath.row)
        //    self.feedsTableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        // return [deleteAction, shareAction] No feed share for this version
        return [deleteAction]
    }
    
    

    
    func didReceiveAPIResults(results: NSArray, message: String, methodCaller: String) {
        var resultsArr: NSArray = results
        if message != "" {
            var alert: UIAlertView = UIAlertView()
            alert.title = "Notification"
            alert.message = message
            alert.addButtonWithTitle("Ok")
            alert.show()
            self.feedsTableView!.reloadData()
        }else{
            if methodCaller == "getUserFeed" {
                dispatch_async(dispatch_get_main_queue(), {
                    self.userFeeds = resultsArr as Array<String>
                    self.feedsTableView!.reloadData()
                })
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.feedsData = NSMutableArray(array:resultsArr)
                    self.feedsTableView!.reloadData()
                })
            }
        }
    }
    
    
    
    
    func addFeed(indexPath:AnyObject){
        var rowData: NSDictionary = self.feedsData[indexPath.row] as NSDictionary
        
        var channel = (rowData["name"] as String)
        channel = channel.stringByReplacingOccurrencesOfString(" ", withString: "")
        var installation:PFInstallation = PFInstallation.currentInstallation()
        api!.addFeed(installation.objectId, shortId: rowData["short_id"] as String)
        if (installation.channels == nil)
        {
            installation.channels = NSArray()
        }
        installation.addUniqueObject(channel, forKey: "channels")
        installation.saveEventually()
        api!.getFeeds()
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
