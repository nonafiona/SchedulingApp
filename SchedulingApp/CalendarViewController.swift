//
//  CalendarViewController.swift
//  SchedulingApp
//
//  Created by Jake, JP, Jeff on 4/21/16.
//  Copyright © 2016 Jake Zeal. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate,UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- Properties
    var didOpenCalendar: Bool!
    var selectedDate = NSDate()
    var dateString: String?
    
    var membersArray:[String] = []
    var calendarDaysDict = [String:Int]()
    
    
    //MARK:- Outlets
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var membersTableView: UITableView!
    
    //MARK:- View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMembersTableView()
        prepareCalendar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        refreshCalendar()
    }
    
    //MARK:- Preparations
    func prepareMembersTableView() {
        membersTableView.delegate = self
        membersTableView.dataSource = self
    }
    
    func prepareCalendar() {
        self.title = DataManager.sharedInstance.calendarObject!["title"] as? String
        self.didOpenCalendar = true
        calendar.scrollDirection = .Horizontal
        calendar.appearance.caseOptions = [.HeaderUsesUpperCase,.WeekdayUsesUpperCase]
        calendar.selectDate(NSDate())
    }
    
    func refreshCalendar() {
        self.membersArray = DataManager.sharedInstance.calendarObject!["usernames"] as! [String]
        self.calendarDaysDict.removeAll()
        queryCalendars()
    }
    
    //MARK:- Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCalendarTableView" {
            let nextVC = segue.destinationViewController as! CalendarTableViewController
            nextVC.newDate = selectedDate
            nextVC.calendarObject = DataManager.sharedInstance.calendarObject
        }
    }
    
    //MARK:- UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String? {
        return "Group members"
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.membersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(IdentifierConstants.cellIdentifier, forIndexPath: indexPath)
        
        let members = self.membersArray[indexPath.row]
        cell.textLabel?.text = members

        return cell
    }
    
    //MARK:- Helpers
    func minimumDateForCalendar(calendar: FSCalendar) -> NSDate {
        return calendar.dateWithYear(2016, month: 1, day: 1)
    }
    
    func maximumDateForCalendar(calendar: FSCalendar) -> NSDate {
        return calendar.dateWithYear(2017, month: 12, day: 31)
    }
    
    func calendar(calendar: FSCalendar, numberOfEventsForDate date: NSDate) -> Int {
        let dateString = formatDateString(date)
        if let eventCount = self.calendarDaysDict[dateString] {
            if eventCount > 3 {
                return 3
            } else {
                return eventCount
            }
        }
        return 0
    }
    
    func formatDateString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let dateString: String = formatter.stringFromDate(date)
        return dateString
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        if (didOpenCalendar == false) {
            self.selectedDate = date
            performSegueWithIdentifier("showCalendarTableView", sender: nil)
        } else if (didOpenCalendar == true) {
            didOpenCalendar = false
        }
    }
}

private extension CalendarViewController {
    func queryCalendars() {
        DataManager.sharedInstance.queryCalendars() { (objects, error) in
            
            if error == nil && objects != nil {
                for object in objects! {
                    if let eventDateString = object["dateString"] as? String {
                        if let eventCount = self.calendarDaysDict[eventDateString] {
                            self.calendarDaysDict[eventDateString] = eventCount + 1
                        } else {
                            self.calendarDaysDict[eventDateString] = 1
                        }
                    }
                }
                self.calendar.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
}
