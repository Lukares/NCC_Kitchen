//
//  WeeklyViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 2/27/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit

class WeeklyViewController: UIViewController {

    let tempProducts = ["Apple Pie", "Bacon Cheddar Scone", "Lemon Pie", "Banana Nutella Loaf"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        return tempProducts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell", for: indexPath) as! weekCell
        
        cell.productLabel.text = tempProducts[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let selectedProduct = tempProducts[indexPath.row]
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "productPage") as! ProductViewController
        self.navigationController?.show(controller, sender: nil)
        controller.recievedTitle = selectedProduct
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
