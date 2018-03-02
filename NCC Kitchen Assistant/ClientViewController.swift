//
//  ClientViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 2/8/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit

class ClientViewController: UIViewController {
    
    var recievedTitle: String!
    @IBOutlet weak var clientTitleLabel: UILabel!
    let tempProducts = ["Apple Pie", "Bacon Cheddar Scone", "Lemon Pie", "Banana Nutella Loaf"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientTitleLabel.text = recievedTitle
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
        return tempProducts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! clientProductCell
        cell.titleLabel.text = tempProducts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let selectedProduct = tempProducts[indexPath.row]
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "productPage") as! ProductViewController
        self.navigationController?.show(controller, sender: nil)
        controller.recievedTitle = selectedProduct
    }
    
    
}
