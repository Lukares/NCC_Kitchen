//
//  AddEntityController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 4/19/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

class AddEntityController: UIViewController, URLSessionDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var textBoxes: [UITextField]!
    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    var clientSource = ""
    var productSource = ""
    var workbook = ""
    var isClient:Bool?
    let clientPlaceholders = ["Name", "Address", "City"]
    let productPlaceholders = ["Name", "Catagory", "Market Price"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = isClient! ? "Client Info" : "Product Info"
        let placeholders = isClient! ? clientPlaceholders : productPlaceholders
        
        for i in 0..<3 {
            textBoxes[i].placeholder = placeholders[i]
        }
        
        let defaults = UserDefaults.standard
        workbook = defaults.value(forKey: "docID") as! String
        clientSource = defaults.value(forKey: "customerSource") as! String
        productSource = defaults.value(forKey: "productSource") as! String
        // Do any additional setup after loading the view.
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveToExcel(_ sender: Any) {
        
        if isClient! {
            saveClient()
        } else {
            saveProduct()
        }
        
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    SAVE CLIENT TO EXCEL
     * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    func saveClient() {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchClientRequest =  NSFetchRequest<NSManagedObject>(entityName: "Client")
        var position:Int? = nil
        do {
            let count = try managedContext?.count(for: fetchClientRequest)
            position = count! + 2
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        if position != nil {
            
            let tempClient = NSEntityDescription.insertNewObject(forEntityName: "Client", into: managedContext!) as! Client
            let name = textBoxes[0].text!
            let street = textBoxes[1].text!
            let city = textBoxes[2].text!
            tempClient.name = name
            tempClient.address = street + " " + city
            
            let jsonRequest = [
                "values": [[name, street, city]]
            ]
            let jsonObject = JSON(jsonRequest)
            
            makeRequest(self.kGraphURI + "drive/items/\(workbook)/workbook/worksheets('\(clientSource)')/range(address='A\(String(position!)):C\(String(position!))')", jsonBody: jsonObject) { jsonResult in
                print(jsonResult.debugDescription)
                
                DispatchQueue.main.async {
                    // update UI
                    do { // Saved to Core Data
                        self.performSegue(withIdentifier: "dismissEntityPopup", sender: self)
                        try managedContext?.save()
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        }
    }
    
    
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    SAVE PRODUCT TO EXCEL
    * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    func saveProduct() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchClientRequest =  NSFetchRequest<NSManagedObject>(entityName: "Product")
        var position:Int? = nil
        do {
            let count = try managedContext?.count(for: fetchClientRequest)
            position = count! + 2
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        if position != nil {
            
            let tempProduct = NSEntityDescription.insertNewObject(forEntityName: "Product", into: managedContext!) as! Product
            let name = textBoxes[0].text!
            let catagory = textBoxes[1].text!
            let price = textBoxes[2].text!
            tempProduct.name = name
            tempProduct.catagory = Int16(catagory)!
            tempProduct.price = Double(price)!
            
            let jsonRequest = [
                "values": [[name, catagory, "", "", "", price]]
            ]
            let jsonObject = JSON(jsonRequest)
            
            makeRequest(self.kGraphURI + "drive/items/\(workbook)/workbook/worksheets('\(productSource)')/range(address='A\(String(position!)):F\(String(position!))')", jsonBody: jsonObject) { jsonResult in
                print(jsonResult.debugDescription)
                
                DispatchQueue.main.async {
                    // update UI
                    do { // Saved to Core Data
                        
                        try managedContext?.save()
                        self.performSegue(withIdentifier: "dismissEntityPopup", sender: self)
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        }
    }
    
    
    @IBAction func dismissPopup(_ sender: Any) {
    }
    
    
    func makeRequest(_ urlString: String, jsonBody: JSON, completion: @escaping (JSON)->() ) {
        print("Making request")
        let sessionConfig = URLSessionConfiguration.default
        
        // Specify the Graph API endpoint
        let url = URL(string: urlString)
        print(urlString)
        var request = URLRequest(url: url!)
        
        let jsonObject = jsonBody
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        request.httpMethod = "PATCH"
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        
        urlSession.dataTask(with: request) { data, response, error in
            let json = try! JSON(data: data!)
            completion(json)
            }.resume()
    }
}
