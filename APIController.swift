//
//  API.swift
//  UrbanFeed
//
//  Created by Cristian Garner on 2/21/15.
//  Copyright (c) 2015 Cristian Garner. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSArray, message: String, methodCaller: String)
}

class APIController
{
    
    
    let serverURL = "https://city-notifications.appspot.com/_ah/api/urbanfeed/v1/" // Local Testing
    var delegate: APIControllerProtocol
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    
    func getFeeds(){
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.GET( serverURL+"channels/list",
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let responseDictionary = responseObject as [String: AnyObject]
                let feedArray = responseDictionary["items"] as NSArray
                println(feedArray)
                self.delegate.didReceiveAPIResults(feedArray,message: "",methodCaller: "getFeeds")
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                let responseObject: AnyObject! =  operation.responseObject
                if responseObject != nil {
                    let response =  responseObject as [String: AnyObject]
                    self.delegate.didReceiveAPIResults([],message: response["message"]!.description,methodCaller: "getFeeds")
                }else{
                    self.delegate.didReceiveAPIResults([],message: error.localizedDescription,methodCaller: "getFeeds")
                }
        })
    }
    
    
    
}
