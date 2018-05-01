//
//  TodayViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 3/2/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit
import CoreData

class TodayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var theTableView: UITableView!
    @IBOutlet weak var daySelector: UITabBar!
    @IBOutlet weak var resetButton: UIButton!
    var dayOfWeek = ""
    var days:[String] = []
    var badDays:[String] = [String]()
    var allOrders = [Order]()
    var todayOrders = [Order]()
    var completedDict:[String:[String:Bool]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getData), name: Notification.Name("databaseRefreshed"), object: nil)
        
        
        // Initialize dayOfWeek to current day
        days = getDayStr(day: Date())
        dayOfWeek = days[0]
        badDays = Array(days[1...3])
        for dayTab in daySelector.items! {
            if dayTab.title?.caseInsensitiveCompare(dayOfWeek) == .orderedSame {
                daySelector.selectedItem = dayTab
            }
        }
        
        getData()
        
    }
    
    @objc func getData() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchProductRequest =  NSFetchRequest<NSManagedObject>(entityName: "Order")
        
        do {
            allOrders = (try managedContext?.fetch(fetchProductRequest))! as! [Order]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "completedTasks") is [String:[String:Bool]] {
            completedDict = defaults.value(forKey: "completedTasks") as! [String:[String:Bool]]
            for i in 1...3 {
                completedDict[days[i]] = [:]
            }
        } else {
            completedDict = ["sunday":[:], "monday":[:], "tuesday":[:], "wednesday":[:], "thursday":[:], "friday":[:], "saturday":[:]]
        }
        
        getDayOrders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UI FUNCTIONS
    
    @IBAction func toggledSwitch(_ sender: UISwitch) {
        let order = todayOrders[sender.tag]
        let orderName = order.productType!.name! + order.orderingClient!.name!
        completedDict[dayOfWeek]![orderName]! = sender.isOn
        let defaults = UserDefaults.standard
        defaults.set(completedDict, forKey: "completedTasks")
    }
    
    
    
    @IBAction func resetCompletion(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "Are you sure?", message: "This will clear your completion progress for this day.", preferredStyle: .actionSheet)
        let cancel = UIAlertAction.init(title: "RESET", style: .destructive, handler: { (UIAlertAction) in
            //Clear the switches
            let defaults = UserDefaults.standard
            self.completedDict[self.dayOfWeek] = [:]
            defaults.set(self.completedDict, forKey: "completedTasks")
            self.theTableView.reloadData()
        })
        let nvm = UIAlertAction.init(title: "Nevermind", style: .default, handler: nil)
        alert.addAction(nvm)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        self.present(alert, animated: false, completion: nil)
    }
    
    
    
    
    // DAY FUNCTIONS
    
    func getDayOrders() {
        todayOrders = allOrders
        for o in todayOrders { //remove orders with a 0 for the day
            if o.value(forKey: dayOfWeek) as! Int16 == 0 {
                todayOrders.remove(at: todayOrders.index(of: o)!)
            }
        }
        
        todayOrders.sort(by: {
            if $0.productType!.catagory != $1.productType!.catagory {
                return $0.productType!.catagory < $1.productType!.catagory
            }
            else if $0.productType!.name! != $1.productType!.name! {
                return $0.productType!.name! < $1.productType!.name!
            }
            else {          //
                return $0.value(forKey: dayOfWeek) as! Int16 > $1.value(forKey: dayOfWeek) as! Int16
            }
        })
        
        theTableView.reloadData()
    }
    
    
    func getDayStr(day: Date) -> [String] {
        let weekday = Calendar.current.component(.weekday, from: day)
        
        var days:[String] = [numToDay(n: weekday)]
        
        for i in 3...6 {
            var offset = weekday-i
            if offset<1 {
                offset += 7
            }
            days.append(numToDay(n: offset))
        }
        
        return days
        
    }
    
    func numToDay(n: Int) -> String {
        switch n {
        case 1:
            return "sunday"
        case 2:
            return "monday"
        case 3:
            return "tuesday"
        case 4:
            return "wednesday"
        case 5:
            return "thursday"
        case 6:
            return "friday"
        case 7:
            return "saturday"
        default:
            return "error"
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyCell", for: indexPath) as! dailyCell
        let order = todayOrders[indexPath.row]
        
        if badDays.contains(dayOfWeek) {
            cell.completedSwitch.isHidden = true
            cell.completedLabel.isHidden = true
        } else {
            cell.completedSwitch.isHidden = false
            cell.completedLabel.isHidden = false
            let orderName = order.productType!.name! + order.orderingClient!.name!
            var completed:Bool = false
            //Check for exsting value
            if completedDict[dayOfWeek]![orderName] != nil {
                completed = completedDict[dayOfWeek]![orderName]!
            }else { //If no existing value, create one set to false
                completedDict[dayOfWeek]![orderName] = false
            }
            cell.completedSwitch.isOn = completed
            cell.completedSwitch.tag = indexPath.row
        }
        
        
        cell.productLabel.text = order.productType?.name
        cell.clientLabel.text = order.orderingClient?.name
        cell.quantityField.text = String(order.value(forKey: dayOfWeek) as! Int16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !(indexPath.row%2 == 0) {
            cell.backgroundColor = UIColor(red: 154/255, green: 199/255, blue: 124/255, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        dayOfWeek = (item.title?.lowercased())!
        resetButton.isHidden = badDays.contains(dayOfWeek) //If the selected day shouldn't show completion switches
        
        getDayOrders()
    }

}
