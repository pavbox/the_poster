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
        guard let url = imageURL else {
            imageCell?.image = UIImage(named: "angry")
            return
        }

        imageCell.layer.cornerRadius = 4

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            DispatchQueue.main.async() { () -> Void in
                if url == self.imageURL {
                    self.imageCell?.image = UIImage(data: data)
                } else {
                    self.imageCell?.image = UIImage(named: "angry")
                }
            }
        }.resume()
    }
}

