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
    
    func getUserFeeds(objectId :String){
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        var parameters = ["objectId":objectId]
        manager.GET( serverURL+"subscribers/get_by_object_id",
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let responseDictionary = responseObject as [String: AnyObject]
                println(responseDictionary)
                let feedArray = responseDictionary["channels"] as NSArray
                
                self.delegate.didReceiveAPIResults(feedArray,message: "",methodCaller: "getUserFeed")
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                let responseObject: AnyObject! =  operation.responseObject
                if responseObject != nil {
                    let response =  responseObject as [String: AnyObject]
                    self.delegate.didReceiveAPIResults([],message: response["message"]!.description,methodCaller: "getUserFeed")
                }else{
                    self.delegate.didReceiveAPIResults([],message: error.localizedDescription,methodCaller: "getUserFeed")
                }
        })
    }
    
    func addFeed(objectId :String, shortId :String ){
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        var parameters = ["channelid":shortId,"objectId":objectId]
        manager.POST( serverURL+"subscribers/add_channel",
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                self.delegate.didReceiveAPIResults([],message: "Feed Added!",methodCaller: "getFeeds")
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
