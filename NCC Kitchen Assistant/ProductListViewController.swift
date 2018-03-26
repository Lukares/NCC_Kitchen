//
//  ProductListViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 2/8/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//


import UIKit
import CoreData

protocol ProductSelectionDelegate: class {
    func productSelected(_ theProduct: String)
}

class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    
    var productList = [(String, Int)]()
    
    weak var delegate: ProductSelectionDelegate?
    @IBOutlet weak var sortingBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        //Fetch Core Data
        
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
//            print(p.value(forKeyPath: "name") as! String)
            productList.append((p.name!, (p.order?.count)!))
        }
        
        sortingBar.selectedItem = sortingBar.items?[0]
        productList.sort(by: {
            if $0.1 != $1.1 {
            return $0.1 > $1.1
            }
            else {
            return $0.0 < $1.0
            }
        })
        
        let icon = UIImage(named: "pie.png")
        let imageView = UIImageView(image:icon)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return productList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        cell.textLabel?.text = productList[indexPath.row].0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let selectedProduct = productList[indexPath.row]

        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "productRootNav") as! UINavigationController
        splitViewController?.showDetailViewController(controller, sender: nil)
        let child = controller.topViewController as! ProductViewController
        child.recievedTitle = selectedProduct.0
    }
    
    
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //Selected tab bar
        if tabBar.items![0] == item {
            productList.sort(by: {
                if $0.1 != $1.1 {
                    return $0.1 > $1.1
                }
                else {
                    return $0.0 < $1.0
                }
            })
        } else {
            productList.sort(by: {$0.0 < $1.0})
        }
        tableView.reloadData()
    }
    
    
    
}




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
