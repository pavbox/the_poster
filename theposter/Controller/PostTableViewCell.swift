//
//  PostTableViewCell.swift
//  theposter
//
//  Created by Admin on 15/09/2017.
//  Copyright © 2017 pavbox. All rights reserved.
//

import UIKit

/*
 * Class customize UI cell (adds image and title)
 */

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleCell: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var imageURL: URL? {
        didSet {
            imageCell?.image = nil
            updateUI()
        }
    }
    
    private func updateUI() {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async {
                let contentsOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.imageCell?.image = UIImage(data: imageData)
                        } else {
                            self.imageCell?.image = UIImage(named: "angry")
                        }
                    }
                }
            }
        }
    }
}

