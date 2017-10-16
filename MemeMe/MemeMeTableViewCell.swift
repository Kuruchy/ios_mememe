//
//  MemeMeTableViewCell.swift
//  MemeMe
//
//  Created by User1 on 16.10.17.
//  Copyright © 2017 Kuruchy. All rights reserved.
//

import UIKit

// MARK: Table View Cell
class MemeMeTableViewCell: UITableViewCell {
    
    func setupCellWith(_ meme: Meme) {
        // Set the name and image
        self.imageView?.image = meme.memedImage
        self.textLabel?.text = meme.topText! + " ... " + meme.bottomText!
    }
}


