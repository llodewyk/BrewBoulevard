//
//  SearchResultCell.swift
//  BrewBoulevard
//
//  Created by Laura Lodewyk on 12/01/15.
//  Copyright (c) 2015 Laura Lodewyk. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var adressLabel: UILabel!
  @IBOutlet weak var smallIconImageView: UIImageView!
  
  var downloadTask: NSURLSessionDownloadTask?

  override func awakeFromNib() {
    super.awakeFromNib()
    
    let selectedView = UIView(frame: CGRect.zeroRect)
    selectedView.backgroundColor = UIColor(red: 118/255, green: 10/255, blue: 10/255, alpha: 0.5)
    selectedBackgroundView = selectedView
  }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  func configureForSearchResult(searchResult: SearchResult) {
    nameLabel.text = searchResult.name
    adressLabel.text = searchResult.address
    smallIconImageView.image = UIImage(named: "Placeholder")
    
    if let url = NSURL(string: searchResult.smallIcon) {
      downloadTask = smallIconImageView.loadImageWithURL(url)
    }
  }
    
    func configureForBrewResult(searchResult: BrewResult) {
        nameLabel.text = searchResult.name
        adressLabel.text = searchResult.style
        smallIconImageView.image = UIImage(named: "Placeholder")
        
        if let url = NSURL(string: searchResult.smallIcon) {
            downloadTask = smallIconImageView.loadImageWithURL(url)
        }
    }
    
  override func prepareForReuse() {
    super.prepareForReuse()
    
    downloadTask?.cancel()
    downloadTask = nil
    
    nameLabel.text = nil
    adressLabel.text = nil
    smallIconImageView.image = nil
  }
}
