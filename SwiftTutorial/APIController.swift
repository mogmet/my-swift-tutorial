//
//  APIController.swift
//  SwiftTutorial
//
//  Created by mogmet on 2014/06/26.
//  Copyright (c) 2014年 mogmet. All rights reserved.
//

import UIKit
protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
}

class APIController: NSObject {
    var delegate: APIControllerProtocol?
    
    init(delegate: APIControllerProtocol?) {
        self.delegate = delegate
    }
        
    func searchItunesFor(searchTerm: String) {
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        var itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        var escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music&entity=album"
        var url: NSURL = NSURL(string: urlPath)
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            self._completeTask(data, response: response, error: error)
            })
        task.resume()
    }
    
    func _completeTask(data: NSData!, response:NSURLResponse!, error:NSError!)
    {
        println("Task completed")
        if(error) {
            // If there is an error in the web request, print it to the console
            println(error.localizedDescription)
        }
        var err: NSError?
        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
        
        if(err?) {
            // If there is an error parsing JSON, print it to the console
            println("JSON Error \(err!.localizedDescription)")
        }
        self.delegate?.didReceiveAPIResults(jsonResult)        
    }

}
