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
        api!.getFeeds()
        var installation:PFInstallation = PFInstallation.currentInstallation()
        if (installation.channels != nil)
        {
            println("xD")
            println(installation)
            userFeeds = installation.channels as Array<String>
        }
        println("xD")
        println(installation)
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
        if(contains(self.userFeeds, String(rowData["name"] as String))){
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
            dispatch_async(dispatch_get_main_queue(), {
                self.feedsData = NSMutableArray(array:resultsArr)
                self.feedsTableView!.reloadData()
            })
        }
    }
    
    func addFeed(indexPath:AnyObject){
        var rowData: NSDictionary = self.feedsData[indexPath.row] as NSDictionary
      //  api!.addFeed(String(rowData["name"]), userId: self.userId)
        var channel = (rowData["name"] as String)
        channel = channel.stringByReplacingOccurrencesOfString(" ", withString: "")
        var installation:PFInstallation = PFInstallation.currentInstallation()
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
