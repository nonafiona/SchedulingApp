//
//  CalendarCollectionViewController.swift
//  SchedulingApp
//
//  Created by Zeal on 4/21/16.
//  Copyright © 2016 Jake Zeal. All rights reserved.
//

import UIKit
import Parse

class CalendarCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var imageView = UIImageView()
    var calendarNames: [String] = []
    
    //MARK:- Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
    }
    
    override func viewWillAppear(animated: Bool) {
        //query parse for user-specific calendars
        self.calendarNames = []
        queryParse()
    }
    
    func queryParse() {
        let currentUser = PFUser.currentUser()
        let query = PFQuery(className:"Calendar")
        query.whereKey("usernames", equalTo: currentUser!["username"])
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil && objects != nil {
                for object in objects! {
                    
                    let calendarTitle = object["title"] as! String
                    self.calendarNames.append(calendarTitle)
                    print(self.calendarNames)
                    dispatch_async(dispatch_get_main_queue()){
                        self.collectionView.reloadData()
 
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    //MARK:- Preperations
    func prepareCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    //MARK:- UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.calendarNames.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = "Cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! CalendarCollectionViewCell
        
        self.imageView.frame = cell.frame
        cell.addSubview(self.imageView)
        self.imageView.image = UIImage.init(named:"calendar")
        
        return cell
    }


}
