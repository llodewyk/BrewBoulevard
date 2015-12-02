//
//  DetailViewController.swift
//  BrewBoulevard
//
//  Created by M.I. Hollemans on 07/10/14.
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

    
    /*var priceText: String
    if searchResult.price == 0 {
      priceText = NSLocalizedString("Free", comment: "Price: Free")
    } else if let text = formatter.stringFromNumber(searchResult.price) {
      priceText = text
    } else {
      priceText = ""
    }
    
    priceButton.setTitle(priceText, forState: .Normal) */

    if let url = NSURL(string: searchResult.largeIcon) {
      downloadTask = largeIconImageView.loadImageWithURL(url)
    }

    popupView.hidden = false
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

  @IBAction func close() {
    dismissAnimationStyle = .Slide
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  /*@IBAction func openInStore() {
    if let url = NSURL(string: searchResult.storeURL) {
      UIApplication.sharedApplication().openURL(url)
    }*/
  }
  
  /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowMenu" {
      let controller = segue.destinationViewController as! MenuViewController
      controller.delegate = self
    }
  }
}*/

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

extension DetailViewController: MenuViewControllerDelegate {
  func menuViewControllerSendSupportEmail(MenuViewController) {
    dismissViewControllerAnimated(true) {
      if MFMailComposeViewController.canSendMail() {
        let controller = MFMailComposeViewController()
        controller.setSubject(NSLocalizedString("Support Request", comment: "Email subject"))
        controller.setToRecipients(["your@email-address-here.com"])
        controller.mailComposeDelegate = self
        controller.modalPresentationStyle = .FormSheet
        self.presentViewController(controller, animated: true, completion: nil)
      }
    }
  }
}

extension DetailViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
