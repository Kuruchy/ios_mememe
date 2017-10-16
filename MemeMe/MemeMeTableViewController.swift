//
//  MemeMeTableViewController.swift
//  MemeMe
//
//  Created by Bruno Retolaza on 12.10.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

// MARK: Table View Controller
class MemeMeTableViewController: UIViewController, UITableViewDataSource {

    var memes: [Meme]!
    @IBOutlet var memeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        memeTableView.dataSource = self
        memeTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        memeTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeMeTableViewCell") as! MemeMeTableViewCell
        
        let meme = memes[indexPath.row]
        
        // Set the name and image of the cell with the meme atributes
        cell.setupCellWith(meme)
        
        return cell
    }
}

// MARK: Table View Delegate
extension MemeMeTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeMeDetailViewController") as! MemeMeDetailViewController
        detailController.meme = memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}
