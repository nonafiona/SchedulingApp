//
//  CalendarTableViewController.swift
//  SchedulingApp
//
//  Created by Jeffrey Ip on 2016-04-21.
//  Copyright © 2016 Jake Zeal. All rights reserved.
//

import UIKit
import Parse

class CalendarTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- Properties
    var newDate = NSDate()
    var hours: [NSDate] = []
    var events = [String: PFObject]()
    var selectedDate: String!
    var calendarObject: PFObject?
    
    //MARK:- Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hours.append(newDate)
        prepareCurrentDateString()
        prepareHoursArray()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        prepareSubviews()
        queryParse()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    //MARK:- Preparations
    func prepareSubviews() {
        let backgroundImage = UIImage(named: "Calendar-1")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        imageView.contentMode = .ScaleAspectFit
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        imageView.addSubview(blurView)
        
        self.events.removeAll()
    }
    
    func prepareCurrentDateString() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        self.selectedDate = formatter.stringFromDate(newDate)
        print(self.selectedDate)
    }
    
    func prepareHoursArray() {
        let interval: Double = 3600
        for hour in 1..<24 {
            let nextHour = newDate.dateByAddingTimeInterval(interval*Double(hour))
            self.hours.append(nextHour)
        }
    }
    
    func prepareHourString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        let hour = formatter.stringFromDate(date)
        return hour
    }
    
    //MARK:- UITableViewDataSource
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        let dateHeader = formatter.stringFromDate(newDate)
        
        let label = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        
        label.text = dateHeader
        label.textAlignment = .Center
        label.font = label.font.fontWithSize(25)
        label.textColor = UIColor(red: 202.0/255.0, green: 15.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        
        return label
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hours.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CalendarTableViewCell
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(abbreviation: "EST")
        formatter.dateFormat = "hh:mm a"
        cell.hourLabel.text = formatter.stringFromDate(hours[indexPath.row])
        
        let hourString = prepareHourString(hours[indexPath.row])
        
        if let someEvent = self.events[hourString]{
            cell.eventDetails.text = someEvent["details"] as? String
            cell.eventName.text = someEvent["name"] as? String
            
        }
        
        return cell
    }
    
    //MARK:- UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(abbreviation: "EST")
        formatter.dateFormat = "hh:mm a z"
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = .clearColor()
    }
    
    //MARK:- Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetailsVC" {
            let calendarDetailsVC = segue.destinationViewController as! CalendarDetailsViewController
            
            if let selectedHour = sender as? CalendarTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedHour)!
                let hourString = prepareHourString(hours[indexPath.row])
                let event = self.events[hourString]
                calendarDetailsVC.eventObject = event
                
                let hour = hours[indexPath.row]
                calendarDetailsVC.hourDetails = hour
            }
            calendarDetailsVC.passSelectedDate = self.selectedDate
            calendarDetailsVC.calendarObject = self.calendarObject
        }
    }
}

private extension CalendarTableViewController {
    func queryParse() {
        let relation = calendarObject!.relationForKey("events")
        let query = relation.query()
        
        if let selectedDate = self.selectedDate {
            query.whereKey("dateString", equalTo: selectedDate)
            
        }
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil && objects != nil {
                for object in objects! {
                    if let someHour = object["hourString"]{
                        let hourString = someHour as! String
                        self.events[hourString] = object
                        self.tableView.reloadData()
                    }
                }
            } else {
                print(error?.localizedDescription)
            }
        }
    }
}
