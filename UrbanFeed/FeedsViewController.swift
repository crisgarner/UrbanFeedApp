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
    
    @IBOutlet var feedsTableView: UITableView!
    
    override func viewDidLoad() {
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
            cell.loadItem(feedName: rowData["name"] as String)
        }else{
            cell.loadItem(feedName: rowData["name"] as String,indexPath:indexPath)
        }
        
        
        return cell
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
