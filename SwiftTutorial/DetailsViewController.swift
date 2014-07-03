//
//  DetailsViewController.swift
//  SwiftTutorial
//
//  Created by mogmet on 2014/07/02.
//  Copyright (c) 2014年 mogmet. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet var albumCover: UIImageView
    @IBOutlet var titleLabel: UILabel
    var album: Album?
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = self.album?.title
        albumCover.image = UIImage(data: NSData(contentsOfURL: NSURL(string: self.album?.largeImageURL)))
    }
}