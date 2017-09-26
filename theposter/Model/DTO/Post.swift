//
//  Post.swift
//  theposter
//
//  Created by Admin on 25/09/2017.
//  Copyright © 2017 pavbox. All rights reserved.
//

import UIKit

// only external storage (not local)
class Post: NSObject {
    var id: String?
    var title: String?
    var text: String?
    var hashtag: String?
    var imageName: String?
    var counter: Int = 0
    
    init(id: String?, title: String?, text: String?, hashtag: String?, imageName: String?) {
        self.id = id
        self.title = title
        self.text = text
        self.hashtag = hashtag
        self.imageName = imageName
        
        self.counter += 1
    }
    
    init(id: String?, title: String?, imageName: String?) {
        self.id = id
        self.title = title
        self.imageName = imageName
        
        self.counter += 1
    }
}
