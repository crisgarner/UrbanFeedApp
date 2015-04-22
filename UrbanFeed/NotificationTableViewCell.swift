//
//  NotificationTableViewCell.swift
//  UrbanFeed
//
//  Created by Cristian Garner on 2/22/15.
//  Copyright (c) 2015 Cristian Garner. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet var owner: UILabel!
    
    @IBOutlet var title: UILabel!
    
    @IBOutlet var message: UILabel!
    
    @IBOutlet var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func loadItem(#owner: String,title: String,message: String, date: String) {
        self.owner.text = owner
        self.title.text = title
        self.message.text = message
        self.date.text = date
        self.message.numberOfLines = 0;
        self.message.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.title.numberOfLines = 0;
        self.title.lineBreakMode = NSLineBreakMode.ByWordWrapping
    }
    
}
