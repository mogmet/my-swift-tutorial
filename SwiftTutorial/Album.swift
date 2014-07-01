//
//  Album.swift
//  SwiftTutorial
//
//  Created by mogmet on 2014/07/01.
//  Copyright (c) 2014年 mogmet. All rights reserved.
//

import UIKit

class Album: NSObject {
    var title: String?
    var price: String?
    var thumbnailImageURL: String?
    var largeImageURL: String?
    var itemURL: String?
    var artistURL: String?
    
    init(name: String!, price: String!, thumbnailImageURL: String!, largeImageURL: String!, itemURL: String!, artistURL: String!) {
        self.title = name
        self.price = price
        self.thumbnailImageURL = thumbnailImageURL
        self.largeImageURL = largeImageURL
        self.itemURL = itemURL
        self.artistURL = artistURL
    }

}
