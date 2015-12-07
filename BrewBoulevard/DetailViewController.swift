//
//  DetailViewController.swift
//  BrewBoulevard
//
//  Created by Laura Lodewyk on 12/01/15.
//  Copyright (c) 2015 Laura Lodewyk. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController {

  @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var largeIconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
  
    var search = Search()

    var searchResult: SearchResult! {
    didSet {
      if isViewLoaded() {
        updateUI()
      }
    }
  }

  var downloadTask: NSURLSessionDownloadTask?

  enum AnimationStyle {
    case Slide
    case Fade
  }
  
  var dismissAnimationStyle = AnimationStyle.Fade
  
  var isPopUp = false
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalPresentationStyle = .Custom
    transitioningDelegate = self
  }
  
  deinit {
    println("deinit \(self)")
    downloadTask?.cancel()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    popupView.layer.cornerRadius = 10

    if isPopUp {
      let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
      gestureRecognizer.cancelsTouchesInView = false
      gestureRecognizer.delegate = self
      view.addGestureRecognizer(gestureRecognizer)

      view.backgroundColor = UIColor.clearColor()
    } else {
      view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
      popupView.hidden = true
      
      if let displayName = NSBundle.mainBundle().localizedInfoDictionary?["CFBundleDisplayName"] as? String {
        title = displayName
      }
    }
    
    if searchResult != nil {
      updateUI()
    }
  }

  func updateUI() {
    nameLabel.text = searchResult.name
    
    if searchResult.address.isEmpty {
      addressLabel.text = NSLocalizedString("Unknown", comment: "Unknown artist name")
    } else {
      addressLabel.text = searchResult.address
    }
    
    websiteLabel.text = searchResult.website
    phoneLabel.text = searchResult.phone

    

    if let url = NSURL(string: searchResult.smallIcon) {
      downloadTask = largeIconImageView.loadImageWithURL(url)
    }

    popupView.hidden = false
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    

  @IBAction func close() {
    dismissAnimationStyle = .Slide
    dismissViewControllerAnimated(true, completion: nil)
  }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowInfo"{
            let showInfo:BreweryViewController = segue.destinationViewController as! BreweryViewController
            showInfo.searchResult = self.searchResult!
            showInfo.tableSearch = self.search
        }
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
  
  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
      
    return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
  }

  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimationController()
  }

  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    switch dismissAnimationStyle {
    case .Slide:
      return SlideOutAnimationController()
    case .Fade:
      return FadeOutAnimationController()
    }
  }
}

extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    return (touch.view === view)
  }
}

