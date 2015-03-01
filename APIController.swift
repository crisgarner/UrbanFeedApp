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
    
    func getFeedsByCity(city:String,country:String){
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        var parameters = ["city":city, "country":country]
        manager.GET( serverURL+"channels/get_by_city",
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let responseDictionary = responseObject as [String: AnyObject]
                if let feedArray = responseDictionary["items"] as? NSArray{
                    self.delegate.didReceiveAPIResults(feedArray,message: "",methodCaller: "getFeeds")
                }else{
                    self.delegate.didReceiveAPIResults([],message: "",methodCaller: "getFeeds")
                }
                
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
                if let feedArray: NSArray = responseDictionary["channels"] as? NSArray{
                      self.delegate.didReceiveAPIResults(feedArray,message: "",methodCaller: "getUserFeed")
                }else{
                    self.delegate.didReceiveAPIResults([],message: "",methodCaller: "getUserFeed")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                let responseObject: AnyObject! =  operation.responseObject
                if responseObject != nil {
                    let response =  responseObject as [String: AnyObject]
                    self.delegate.didReceiveAPIResults([],message: error.localizedDescription,methodCaller: "getUserFeed")
                }else{
                    self.delegate.didReceiveAPIResults([],message: error.localizedDescription,methodCaller: "getUserFeed")
                }
        })
    }
    
    func getNotifications(channels :String){
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        var parameters = ["channels":channels]
        manager.GET( serverURL+"messages/get_by_channels",
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                let responseDictionary = responseObject as [String: AnyObject]
                println(responseDictionary)
                if let feedArray: NSArray = responseDictionary["items"] as? NSArray{
                    self.delegate.didReceiveAPIResults(feedArray,message: "",methodCaller: "getNotifications")
                }else{
                    self.delegate.didReceiveAPIResults([],message: "",methodCaller: "getNotifications")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                let responseObject: AnyObject! =  operation.responseObject
                if responseObject != nil {
                    let response =  responseObject as [String: AnyObject]
                    self.delegate.didReceiveAPIResults([],message: error.localizedDescription,methodCaller: "getNotifications")
                }else{
                    self.delegate.didReceiveAPIResults([],message: error.localizedDescription,methodCaller: "getNotifications")
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
                self.delegate.didReceiveAPIResults([],message: "Feed Added!",methodCaller: "addFeed")
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                let responseObject: AnyObject! =  operation.responseObject
                if responseObject != nil {
                    let response =  responseObject as [String: AnyObject]
                    self.delegate.didReceiveAPIResults([],message: response["message"]!.description,methodCaller: "addFeed")
                }else{
                    self.delegate.didReceiveAPIResults([],message: error.localizedDescription,methodCaller: "addFeed")
                }
        })
    }
    
    func deleteFeed(objectId :String, shortId :String ){
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        var parameters = ["channelid":shortId,"objectId":objectId]
        manager.POST( serverURL+"subscribers/remove_channel",
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                self.delegate.didReceiveAPIResults([],message: "Feed Deleted!",methodCaller: "deleteFeed")
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                let responseObject: AnyObject! =  operation.responseObject
                if responseObject != nil {
                    let response =  responseObject as [String: AnyObject]
                    self.delegate.didReceiveAPIResults([],message: response["message"]!.description,methodCaller: "deleteFeed")
                }else{
                    self.delegate.didReceiveAPIResults([],message: error.localizedDescription,methodCaller: "deleteFeed")
                }
        })
    }
    
    
    func addUser(objectId :String){
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
        var parameters = ["object_id":objectId]
        manager.POST(serverURL+"subscribers/insert",
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                self.delegate.didReceiveAPIResults([],message: "success",methodCaller: "addUser")
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                let responseObject: AnyObject! =  operation.responseObject
                if responseObject != nil {
                    let response =  responseObject as [String: AnyObject]
                    self.delegate.didReceiveAPIResults([],message:  error.localizedDescription,methodCaller: "addUser")
                }else{
                    self.delegate.didReceiveAPIResults([],message: error.localizedDescription,methodCaller: "addUser")
                }
        })
    }
    
    
}
