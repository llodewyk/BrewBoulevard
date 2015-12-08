//
//  BreweryViewController.swift
//  BrewBoulevard
//
//  Created by Laura Lodewyk on 12/5/15.
//  Copyright (c) 2015 Laura Lodewyk. All rights reserved.
//

import UIKit

class BreweryViewController: UIViewController {
    
    var searchResult: SearchResult?
    var search = BrewSearch()
    var tableSearch = Search()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var brewName: UILabel!
    //@IBOutlet weak var brewAdress: UILabel!
    //@IBOutlet weak var brewCity: UILabel!
    @IBOutlet weak var brewHours: UILabel!
    @IBOutlet weak var brewDescription: UILabel!
    //@IBOutlet weak var brewWebsite: UILabel!
    //@IBOutlet weak var brewPhone: UILabel!
    
     var downloadTask: NSURLSessionDownloadTask?
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var id = searchResult!.id as String
        search.performSearchForBeer(id, completion: {
            success in
            if !success {
                self.showNetworkError()
            }
            
            self.tableView.reloadData()
        })
        tableView.reloadData()
        
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        
        
        if let result = searchResult{
            if let url = NSURL(string: result.smallIcon) {
                downloadTask = iconImage.loadImageWithURL(url)
            }
            brewName.text = result.name
            //brewAdress.text = result.address
            //brewCity.text = result.city
            brewHours.text = result.hours
            brewDescription.text = result.description
            //brewWebsite.text = result.website
            //brewPhone.text = result.phone
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTable"{
            let showTable:SearchViewController = segue.destinationViewController as! SearchViewController
            //showTable.searchBar.text = self.searchResult!.city
            showTable.search = self.tableSearch
        }
    }
    
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
            message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again.", comment: "Error alert: message"),
            preferredStyle: .Alert)
        
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Error alert: cancel button"), style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}

    extension BreweryViewController: UITableViewDataSource {
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch search.state {
            case .NotSearchedYet:
                return 0
            case .Loading:
                return 1
            case .NoResults:
                return 1
            case .Results(let list):
                return list.count
            }
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            switch search.state {
            case .NotSearchedYet:
                fatalError("Should never get here")
                
            case .Loading:
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath:indexPath) as! UITableViewCell
                
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                
                return cell
                
            case .NoResults:
                return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! UITableViewCell
                
            case .Results(let list):
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
                
                let searchResult = list[indexPath.row]
                cell.configureForBrewResult(searchResult)
                
                return cell
            }
        }
    }
