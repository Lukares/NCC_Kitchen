//
//  ClientViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 2/8/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit
import CoreData

class ClientViewController: UIViewController {
    
    var recievedTitle: String!
    @IBOutlet weak var clientTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    var productList:[(name: String, sun:Int16, mon:Int16, tues: Int16, wed:Int16, thurs: Int16, fri:Int16, sat: Int16, tot: Int16)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientTitleLabel.text = recievedTitle
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let query:NSFetchRequest<Client> = Client.fetchRequest()
        
        let predicate = NSPredicate(format: "name == %@" , recievedTitle!)
        query.predicate = predicate
        var objects: [Client] = []
        
        do {
            objects = (try managedContext?.fetch(query))!
            addressLabel.text = objects[0].address!
        } catch {
            print("fetch error")
        }
        
        for o in objects[0].order! {
            let order = o as! Order
            let productName = order.productType!.name!
            
            productList.append((name: order.productType!.name!, sun:order.sunday, mon:order.monday, tues: order.tuesday, wed:order.wednesday, thurs: order.thursday, fri:order.friday, sat: order.saturday, tot: order.sunday + order.monday + order.tuesday + order.wednesday + order.thursday + order.friday + order.saturday))
        }
        
    }
    
    @IBAction func pressedBack(_ sender: Any) {
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "unwindFromClient", sender: nil)
    }
    
    
    @IBAction func unwindFromProduct(_ segue: UIStoryboardSegue) {
        
    }
    
}

extension ClientViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! clientProductCell
        cell.titleLabel.text = productList[indexPath.row].name
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !(indexPath.row%2 == 0) {
            cell.backgroundColor = UIColor(red: 154/255, green: 199/255, blue: 124/255, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let selectedProduct = productList[indexPath.row]
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "productPage") as! ProductViewController
        self.navigationController?.show(controller, sender: nil)
        controller.recievedTitle = selectedProduct.name
    }
    
    
}
