//
//  MemeMeDetailViewController.swift
//  MemeMe
//
//  Created by Bruno Retolaza on 12.10.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

class MemeMeDetailViewController: UIViewController {
    
    @IBOutlet weak var memeView: UIImageView!
    var meme: Meme!
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        memeView.image = meme.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
