//
//  BrewSearch.swift
//  BrewBoulevard
//
//  Created by Laura Lodewyk on 12/6/15.
//  Copyright (c) 2015 Laura Lodewyk. All rights reserved.
//

import Foundation
import UIKit


class BrewSearch {
    
    enum State {
        case NotSearchedYet
        case Loading
        case NoResults
        case Results([BrewResult])
    }
    
    
    var resultArray = [BrewResult]()
    
    private(set) var state: State = .NotSearchedYet
    
    private var dataTask: NSURLSessionDataTask? = nil
    
    func performSearchForBeer(text: String, completion: SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            state = .Loading
            
            let url = urlWithSearchText(text)
            //println(url)
            
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: {
                data, response, error in
                
                self.state = .NotSearchedYet
                var success = false
                
                if let error = error {
                    println("0")
                    if error.code == -999 { return }  // Search was cancelled
                    
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let dictionary = self.parseJSON(data) {
                            var searchResults = self.parseDictionary(dictionary)
                            if searchResults.isEmpty {
                                self.state = .NoResults
                            } else {
                                //searchResults.sort(<)
                                self.resultArray = searchResults
                                self.state = .Results(searchResults)
                            }
                            success = true
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completion(success)
                }
            })
            
            dataTask?.resume()
        }
    }
    
    private func urlWithSearchText(searchText: String) -> NSURL {
        let locale = NSLocale.autoupdatingCurrentLocale()
        let language = locale.localeIdentifier
        let countryCode = locale.objectForKey(NSLocaleCountryCode) as! String
        
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let urlString = String("http://api.brewerydb.com/v2/brewery/\(escapedSearchText)/beers?key=98a6121c97f20cae344d0e7506c15827")
        
        let url = NSURL(string: urlString)
        
        //println("URL: \(url)")
        return url!
    }
    
    private func parseJSON(data: NSData) -> [String: AnyObject]? {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
            return json
        } else if let error = error {
            println("JSON Error: \(error)")
        } else {
            println("Unknown JSON Error")
        }
        return nil
    }
    
    private func parseDictionary(dictionary: [String: AnyObject]) -> [BrewResult] {
        var searchResults = [BrewResult]()
        if let array: AnyObject = dictionary["data"] {
            //println("Array: \(array)")
            for resultDict in array as! [AnyObject] {
                if let resultDict = resultDict as? [String: AnyObject] {
                    let searchResult = BrewResult()
                    //println("THIS IS A NEW ONE: ----------------")
                    //println(resultDict)
                    searchResult.name = resultDict["name"] as! String
                    
                    if (resultDict["labels"] != nil){
                        var images = resultDict["labels"] as! NSDictionary
                        searchResult.smallIcon = images["icon"] as! String
                    }
                    if (resultDict["description"] != nil){
                        searchResult.description = resultDict["description"] as! String
                    }
                    if (resultDict["style"] != nil){
                        let style = resultDict["style"] as! NSDictionary
                        if ((style["name"]) != nil){
                            searchResult.style = style["name"] as! String
                        }
                    }
                    
                    
                    
                    searchResults.append(searchResult)
                    
                } else {
                    println("Expected a dictionary")
                }
            }
        } else {
            println("Expected 'results' array")
        }
        
        return searchResults
    }
}

