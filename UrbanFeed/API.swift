//
//  API.h
//  UrbanFeed
//
//  Created by Cristian Garner on 2/21/15.
//  Copyright (c) 2015 Cristian Garner. All rights reserved.
//


import Foundation

protocol APIProtocol {
    func didReceiveAPIResults(results: NSArray, message: String, methodCaller: String)
}

class API{
    
    
    //let serverURL = "http://localhost:5100/" // Local Testing
    var delegate: APIProtocol
    
    init(delegate: APIProtocol) {
        self.delegate = delegate
    }
    
    func getFeeds(){
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        var parameters = ["" : ""]
        manager.POST( serverURL+"feeds",
                     parameters: parameters,
                     success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                         let feedArray = responseObject as NSArray
                         self.delegate.didReceiveAPIResults(feedArray,message: "getFeeds",methodCaller: "getFeeds")
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

