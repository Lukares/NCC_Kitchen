//
//  ProductViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 2/8/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController {

    @IBOutlet var dayLabels: [UILabel]!
    var recievedTitle: String!
    
    var clientList:[String] = []
    var quantities:(sun:Int16, mon:Int16, tues: Int16, wed:Int16, thurs: Int16, fri:Int16, sat: Int16, tot: Int16) = (sun:0, mon:0, tues: 0, wed:0, thurs: 0, fri:0, sat: 0, tot: 0)
    
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var catagoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productTitleLabel.text = recievedTitle
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let query:NSFetchRequest<Product> = Product.fetchRequest()
        
        let predicate = NSPredicate(format: "name == %@" , recievedTitle!)
        query.predicate = predicate
        var objects: [Product] = []

        do {
            objects = (try managedContext?.fetch(query))!
            catagoryLabel.text = "Catagory: " + String(objects[0].catagory)
            priceLabel.text = "Price: $" + String.localizedStringWithFormat("%.2f", objects[0].price)
            
        } catch {
            print("fetch error")
        }
        
        print("Number of orders = \(objects[0].order!.count)")
        
        //Get ordering clients
        
        for o in objects[0].order! {
            let order = o as! Order
            let clientName = order.orderingClient!.name!
            clientList.append(clientName)
            
            quantities.mon = quantities.mon+order.monday
            quantities.tues = quantities.tues+order.tuesday
            quantities.wed = quantities.wed+order.wednesday
            quantities.thurs = quantities.thurs+order.thursday
            quantities.fri = quantities.fri+order.friday
            quantities.sat = quantities.sat+order.saturday
            quantities.sun = quantities.sun+order.sunday
        }
        quantities.tot = quantities.mon + quantities.tues + quantities.wed + quantities.thurs + quantities.fri + quantities.sat + quantities.sun
        
        dayLabels[0].text = String(quantities.sun)
        dayLabels[1].text = String(quantities.mon)
        dayLabels[2].text = String(quantities.tues)
        dayLabels[3].text = String(quantities.wed)
        dayLabels[4].text = String(quantities.thurs)
        dayLabels[5].text = String(quantities.fri)
        dayLabels[6].text = String(quantities.sat)
        dayLabels[7].text = String(quantities.tot)
        
        print(clientList)
        print(quantities)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedBack(_ sender: Any) {
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "unwindFromProduct", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindFromClient(_ segue: UIStoryboardSegue) {
        
    }
    
    

}

extension ProductViewController: ProductSelectionDelegate {
    func productSelected(_ newProduct: String) {
        print("HEY I GOT IT" + newProduct)
    }
}


extension ProductViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return clientList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath)
        cell.textLabel?.text = clientList[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let selectedProduct = clientList[indexPath.row]
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "clientPage") as! ClientViewController
//        self.definesPresentationContext = true
//        self.present(controller, animated: true, completion: nil)
        self.navigationController?.show(controller, sender: nil)
        controller.recievedTitle = selectedProduct
    }

    
    
    
    
    
}
