//
//  FeedTableViewCell.swift
//  UrbanFeed
//
//  Created by Cristian Garner on 2/21/15.
//  Copyright (c) 2015 Cristian Garner. All rights reserved.
//

import UIKit

protocol FeedTableProtocol {
    func addFeed(indexRow:AnyObject)
}

class FeedTableViewCell: UITableViewCell {
    
    var delegate: FeedTableProtocol?
    var indexPath: AnyObject?
    @IBOutlet var feedName: UILabel!
    @IBOutlet var addFeedButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func loadItem(#feedName: String, indexPath: AnyObject = NSNull()) {
        self.feedName.text = feedName
        if(indexPath as NSObject == NSNull()){
            addFeedButton.enabled = false
            addFeedButton.alpha = 0
        }else{
            addFeedButton.enabled = true
            addFeedButton.alpha = 1
        }
        self.indexPath = indexPath
    }
    
    @IBAction func add(sender: AnyObject) {
        addFeedButton.enabled = false
        addFeedButton.alpha = 0
        self.delegate?.addFeed(indexPath!)
    }
    
    
}
