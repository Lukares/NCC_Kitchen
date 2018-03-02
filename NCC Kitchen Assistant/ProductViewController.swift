//
//  ProductViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 2/8/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {

    var recievedTitle: String!
    
    let tempClients = ["Avoca", "Cafe Victoria", "Criswell"]
    
    
    
    @IBOutlet weak var productTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productTitleLabel.text = recievedTitle
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
        return tempClients.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath)
        cell.textLabel?.text = tempClients[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let selectedProduct = tempClients[indexPath.row]
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "clientPage") as! ClientViewController
//        self.definesPresentationContext = true
//        self.present(controller, animated: true, completion: nil)
        self.navigationController?.show(controller, sender: nil)
        controller.recievedTitle = selectedProduct
    }

    
    
    
    
    
}
