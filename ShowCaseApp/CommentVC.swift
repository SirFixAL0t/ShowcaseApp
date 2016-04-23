//
//  CommentVC.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/22/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit

class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var comments = [Comment]()
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as? CommentCell {
            cell.configureCell(comment)
            return cell
        }
        return CommentCell()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
