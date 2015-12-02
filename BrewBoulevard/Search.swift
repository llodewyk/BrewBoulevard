import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
  enum Category: Int {
    case All = 0
    case Music = 1
    case Software = 2
    case EBook = 3
    
    var entityName: String {
      switch self {
      case .All: return ""
      case .Music: return "musicTrack"
      case .Software: return "software"
      case .EBook: return "ebook"
      }
    }
  }

  enum State {
    case NotSearchedYet
    case Loading
    case NoResults
    case Results([SearchResult])
  }

  private(set) var state: State = .NotSearchedYet
  
  private var dataTask: NSURLSessionDataTask? = nil
  
  func performSearchForText(text: String, category: Category, completion: SearchComplete) {
    if !text.isEmpty {
      dataTask?.cancel()
      
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      
      state = .Loading
      
      let url = urlWithSearchText(text, category: category)
      
      let session = NSURLSession.sharedSession()
      dataTask = session.dataTaskWithURL(url, completionHandler: {
        data, response, error in
        
        self.state = .NotSearchedYet
        var success = false
        
        if let error = error {
          if error.code == -999 { return }  // Search was cancelled
          
        } else if let httpResponse = response as? NSHTTPURLResponse {
          if httpResponse.statusCode == 200 {
            if let dictionary = self.parseJSON(data) {
              var searchResults = self.parseDictionary(dictionary)
              if searchResults.isEmpty {
                self.state = .NoResults
              } else {
                searchResults.sort(<)
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
  
  private func urlWithSearchText(searchText: String, category: Category) -> NSURL {
    let entityName = category.entityName
    let locale = NSLocale.autoupdatingCurrentLocale()
    let language = locale.localeIdentifier
    let countryCode = locale.objectForKey(NSLocaleCountryCode) as! String

    let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

    let urlString = String("http://api.brewerydb.com/v2/locations?locality=\(escapedSearchText)&key=98a6121c97f20cae344d0e7506c15827")
    
    let url = NSURL(string: urlString)
    
    println("URL: \(url)")
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
  
  private func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
    var searchResults = [SearchResult]()
    
    if let array: AnyObject = dictionary["data"] {
      for resultDict in array as! [AnyObject] {
        if let resultDict = resultDict as? [String: AnyObject] {
          let searchResult = SearchResult()
            //println("THIS IS A NEW ONE: ----------------")
            //println(resultDict["brewery"])
            var brewery = resultDict["brewery"] as! NSDictionary
            searchResult.name = brewery["name"] as! String
            
            if (brewery["images"] != nil){
                var images = brewery["images"] as! NSDictionary
                searchResult.smallIcon = images["icon"] as! String
                searchResult.largeIcon = images["medium"] as! String
            }

            if (resultDict["streetAddress"] != nil){
                searchResult.address = resultDict["streetAddress"] as! String
            }
            else{
                searchResult.address = "Unknown"
            }

            if (resultDict["website"] != nil){
                searchResult.website = resultDict["website"] as! String
            }else{
                searchResult.website = "N/A"
            }
          
          searchResult.latitude = resultDict["latitude"] as! Double
          searchResult.longitude = resultDict["longitude"] as! Double
            if (brewery["description"] != nil){
                searchResult.description = brewery["description"] as! String
            }
            else{
                searchResult.description = "No description currently available"
            }
          
            if (brewery["phone"] != nil){
                searchResult.phone = brewery["phone"] as! String
            }else{
                searchResult.phone = ""
            }
            if (resultDict["hoursOfOperation"] != nil){
                searchResult.hours = resultDict["hoursOfOperation"] as! String
            }
            else{
                searchResult.hours = "No hours currently Available"
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
