//
//  MainTableViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 2/8/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    let mainOptions = ["Home", "Today", "Weekly View", "Clients", "Products", "Manage Orders"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.selectRow(at: IndexPath(row:0, section:0) , animated: false, scrollPosition: .top)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mainOptions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! mainCell
        let cellTitle = mainOptions[indexPath.row]
        cell.mainLabel.text = cellTitle
        var imageTitle = ""
        switch cellTitle {
        case "Home":
            imageTitle = "home.png"
        case "Today":
            imageTitle = "today.png"
        case "Weekly View":
            imageTitle = "week.png"
        case "Clients":
            imageTitle = "clients.png"
        case "Products":
            imageTitle = "pie.png"
        case "Manage Orders":
            imageTitle = "smile.png"
        default:
            imageTitle = "home.png"
        }
        
        cell.icon.image = UIImage(named: imageTitle)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = mainOptions[indexPath.row]
        if selected == "Clients" {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "clientListController") as UIViewController
            self.navigationController?.show(controller, sender: self)
        }
        else if selected == "Products" {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "productListController") as UIViewController
            self.navigationController?.show(controller, sender: self)
        }
        else if selected == "Home" {
            var controller = UIViewController()
            if let temp = controllerSet["homePage"] {
                controller = temp
            } else {
                controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homePage")
            }
            splitViewController?.showDetailViewController(controller, sender: nil)
        }
        else if selected == "Weekly View" {
            var controller = UIViewController()
            if let temp = controllerSet["weekRootNav"] as? UINavigationController {
                controller = temp
            } else {
                controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "weekRootNav") as! UINavigationController
                controllerSet["weekRootNav"] = controller
            }
            splitViewController?.showDetailViewController(controller, sender: nil)
        }
        else if selected == "Today" {
            var controller = UIViewController()
            if let temp = controllerSet["todayRootNav"] as? UINavigationController {
                controller = temp
            } else {
                controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "todayRootNav") as! UINavigationController
                controllerSet["todayRootNav"] = controller
            }
            splitViewController?.showDetailViewController(controller, sender: nil)
        }
        else if selected == "Manage Orders" {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "updateController")
            splitViewController?.showDetailViewController(controller, sender: nil)
        }
        
        
        
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
