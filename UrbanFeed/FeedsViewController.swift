//
//  FeedsViewController.swift
//  UrbanFeed
//
//  Created by Cristian Garner on 2/21/15.
//  Copyright (c) 2015 Cristian Garner. All rights reserved.
//

import UIKit

class FeedsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIProtocol {

    var feedsData: NSMutableArray = []
    let kCellIdentifier: String = "FeedCell"
    var api : API?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "UserFeedTableCell", bundle: nil)
        feedsTableView?.registerNib(nib, forCellReuseIdentifier: kCellIdentifier)
        api = APIController(delegate: self)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
