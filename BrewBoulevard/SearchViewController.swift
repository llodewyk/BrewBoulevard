//
//  ViewController.swift
//  BrewBoulevard
//
//  Created by 2015 Laura Lodewyk on 12/01/15.
//  Copyright (c) 2015 Laura Lodewyk. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  var search = Search()
  
  var landscapeViewController: LandscapeViewController?
  
  weak var splitViewDetail: DetailViewController?
  
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
    tableView.rowHeight = 80
    
    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)

    cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    
    if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
      searchBar.becomeFirstResponder()
    }

    title = NSLocalizedString("Search", comment: "Split-view master button")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func hideMasterPane() {
    UIView.animateWithDuration(0.25, animations: {
      self.splitViewController!.preferredDisplayMode = .PrimaryHidden
    }, completion: { _ in
      self.splitViewController!.preferredDisplayMode = .Automatic
    })
  }
  
  @IBAction func segmentChanged(sender: UISegmentedControl) {
    performSearch()
  }

  func showNetworkError() {
    let alert = UIAlertController(
      title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
      message: NSLocalizedString("There was an error... Please try again.", comment: "Error alert: message"),
      preferredStyle: .Alert)
    
    let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Error alert: cancel button"), style: .Default, handler: nil)
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowDetail" {
      switch search.state {
      case .Results(let list):
        let detailViewController = segue.destinationViewController as! DetailViewController
        let indexPath = sender as! NSIndexPath
        let searchResult = list[indexPath.row]
        detailViewController.searchResult = searchResult
        detailViewController.isPopUp = true
        detailViewController.search = self.search
      default:
        break
      }
    }
    
    if segue.identifier == "ShowMap"{
        switch search.state{
        case .Results(let list):
             //println(list)
            let showMap:MapViewController = segue.destinationViewController as! MapViewController
            showMap.search = self.search
        default:
            break
        }
    }
  }

  override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    
    let rect = UIScreen.mainScreen().bounds
    if (rect.width == 736 && rect.height == 414) ||   // portrait
       (rect.width == 414 && rect.height == 736) {    // landscape
        if presentedViewController != nil {
          dismissViewControllerAnimated(true, completion: nil)
        }
    } else if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
      switch newCollection.verticalSizeClass {
      case .Compact:
        showLandscapeViewWithCoordinator(coordinator)
      case .Regular, .Unspecified:
        hideLandscapeViewWithCoordinator(coordinator)
      }
    }
  }
    
    
  
  func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
    precondition(landscapeViewController == nil)

    landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
    if let controller = landscapeViewController {
      controller.search = search

      controller.view.frame = view.bounds
      controller.view.alpha = 0

      view.addSubview(controller.view)
      addChildViewController(controller)

      coordinator.animateAlongsideTransition({ _ in
        controller.view.alpha = 1
        self.searchBar.resignFirstResponder()

        if self.presentedViewController != nil {
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      },
      completion: { _ in
        controller.didMoveToParentViewController(self)
      })
    }
  }
  
  func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
    if let controller = landscapeViewController {
      controller.willMoveToParentViewController(nil)

      coordinator.animateAlongsideTransition({ _ in
        controller.view.alpha = 0

        if self.presentedViewController != nil {
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      }, completion: { _ in
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        self.landscapeViewController = nil
      })
    }
  }
}

extension SearchViewController: UISearchBarDelegate {
  func performSearch() {
      search.performSearchForText(searchBar.text, completion: {
        success in

        if let controller = self.landscapeViewController {
          controller.searchResultsReceived()
        }

        if !success {
          self.showNetworkError()
        }
        
        self.tableView.reloadData()
      })
      
      tableView.reloadData()
      searchBar.resignFirstResponder()
  }

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    performSearch()
  }

  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}

extension SearchViewController: UITableViewDataSource {
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
      cell.configureForSearchResult(searchResult)
      
      return cell
    }
  }
}

extension SearchViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .Compact {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      performSegueWithIdentifier("ShowDetail", sender: indexPath)
    } else {
      switch search.state {
      case .Results(let list):
        splitViewDetail?.searchResult = list[indexPath.row]
      default:
        break
      }
      
      if splitViewController!.displayMode != .AllVisible {
        hideMasterPane()
      }
    }
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    switch search.state {
    case .NotSearchedYet, .Loading, .NoResults:
      return nil
    case .Results:
      return indexPath
    }
  }
}
