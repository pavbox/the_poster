//
//  PostCollection.swift
//  theposter
//
//  Created by Admin on 17/09/2017.
//  Copyright © 2017 pavbox. All rights reserved.
//

import UIKit

class PostCollection: NSObject {
    
    private var postCollection: [Post] = []

    
    public func append(id: String?, title: String?, text: String?, hashtag: String?, imageName: String?) {
        let newPost = Post(id: id, title: title, text: text, hashtag: hashtag, imageName: imageName)
        postCollection.append(newPost)
    }
    
    
    public func appendShortForm(id: String?, title: String?, imageName: String?) {
        let newPost = Post(id: id, title: title, imageName: imageName)
        postCollection.append(newPost)
    }
    
    
    public func getPostCellByCount(count: Int) -> (String, String) {
        for post in postCollection {
            if post.counter == count {
                return (post.title!, post.imageName!)
            }
        }
        return ("none", "none")
    }
    
    
    public func getCount() -> Int {
        return postCollection.count;
    }

    
    override init() {
        super.init()
    }
    
}
