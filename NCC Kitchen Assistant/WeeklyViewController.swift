//
//  WeeklyViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 2/27/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit
import CoreData

class WeeklyViewController: UIViewController {

    var productList:[(name: String, clients: NSSet, sun:Int16, mon:Int16, tues: Int16, wed:Int16, thurs: Int16, fri:Int16, sat: Int16, tot: Int16)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchProductRequest =  NSFetchRequest<NSManagedObject>(entityName: "Product")
        
        var pt = [Product]()
        do {
            pt = (try managedContext?.fetch(fetchProductRequest))! as! [Product]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print("Products from Core Data")
        for p in pt {
            var quantities:(sun:Int16, mon:Int16, tues: Int16, wed:Int16, thurs: Int16, fri:Int16, sat: Int16, tot: Int16) = (sun:0, mon:0, tues: 0, wed:0, thurs: 0, fri:0, sat: 0, tot: 0)
            var hasClients = false
            for o in p.order! {
                hasClients = true
                let order = o as! Order
                quantities.mon = quantities.mon+order.monday
                quantities.tues = quantities.tues+order.tuesday
                quantities.wed = quantities.wed+order.wednesday
                quantities.thurs = quantities.thurs+order.thursday
                quantities.fri = quantities.fri+order.friday
                quantities.sat = quantities.sat+order.saturday
                quantities.sun = quantities.sun+order.sunday
                quantities.tot = quantities.mon + quantities.tues + quantities.wed + quantities.thurs + quantities.fri + quantities.sat + quantities.sun
            }
            if hasClients {
                productList.append((name: p.name!, clients: p.order!, sun:quantities.sun, mon:quantities.mon, tues: quantities.tues, wed:quantities.wed, thurs: quantities.thurs, fri:quantities.fri, sat: quantities.sat, tot: quantities.tot))
            }
        }
        productList.sort(by: {$0.name < $1.name})
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clientPopup" {
            let vc = segue.destination as! PopupClientController
            vc.popoverPresentationController?.sourceView = sender as! UIButton
            vc.delegate = self
        }
    }
}


extension WeeklyViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return productList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell", for: indexPath) as! weekCell
        
        let count = productList[indexPath.row].clients.count
        let suffix1 = (count > 1) ? "s" : ""
        let suffix2 = (count > 1) ? "" : "s"
        cell.productLabel.text = productList[indexPath.row].name
        cell.clientButton.setTitle("\(count) client\(suffix1) order\(suffix2) this", for: .normal)
        cell.dayLabels[0].text = String(productList[indexPath.row].sun)
        cell.dayLabels[1].text = String(productList[indexPath.row].mon)
        cell.dayLabels[2].text = String(productList[indexPath.row].tues)
        cell.dayLabels[3].text = String(productList[indexPath.row].wed)
        cell.dayLabels[4].text = String(productList[indexPath.row].thurs)
        cell.dayLabels[5].text = String(productList[indexPath.row].fri)
        cell.dayLabels[6].text = String(productList[indexPath.row].sat)
        cell.dayLabels[7].text = String(productList[indexPath.row].tot)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let selectedProduct = productList[indexPath.row]
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "productPage") as! ProductViewController
        self.navigationController?.show(controller, sender: nil)
        controller.recievedTitle = selectedProduct.name
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}


extension WeeklyViewController: PopupDelegate {
    func showClient(name: String) {
        print("Got to delegate")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "clientPage") as! ClientViewController
        self.navigationController?.show(controller, sender: nil)
        controller.recievedTitle = name
    }
    
    
    
}
