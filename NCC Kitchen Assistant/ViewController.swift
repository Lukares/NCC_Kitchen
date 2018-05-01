import UIKit
import CoreData
import SwiftyJSON
import MSAL
import Alamofire

var controllerSet = [String: UIViewController]()
var accessToken = String()

class ViewController: UIViewController, UITextFieldDelegate, URLSessionDelegate {
    
    let kClientID = "a43b5ef7-6217-4310-911f-6eb26d15ca1c"
    let kAuthority = "https://login.microsoftonline.com/common/v2.0"
    
    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    let kScopes: [String] = ["https://graph.microsoft.com/user.read", "https://graph.microsoft.com/files.readwrite.all"]
    
    let kDocumentID = ""
    
    
    var refreshToken = String()
    var applicationContext = MSALPublicClientApplication.init()
    
    let defaults = UserDefaults.standard
    
    var docList:[(name: String, id: String)] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if controllerSet["homePage"] == nil {
            controllerSet["homePage"] = self
        }
        
        do {
            // Initialize a MSALPublicClientApplication with a given clientID and authority
            self.applicationContext = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
        } catch {
            print(error)
        }
        updateDateLabel()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if accessToken.isEmpty {
            signoutButton.isEnabled = false; 
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        
    }
    
    func updateDateLabel() {
        if let date = defaults.value(forKey: "lastUpdate") as? Date {
            dateLabel.text = "Last updated:\n"+date.toString(dateFormat: "HH:mma MM/dd/yy")
        } else {
            dateLabel.text = ""
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsPopup" {
            let vc = segue.destination as! SettingsPopupViewController
            let but = sender as! UIButton
            vc.popoverPresentationController?.sourceView = but
            vc.popoverPresentationController?.sourceRect = but.bounds
        }
    }
    
    
    // This button will invoke the call to the Microsoft Graph API. It uses the
    // built in Swift libraries to create a connection.
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        do {
            
            // We check to see if we have a current logged in user. If we don't, then we need to sign someone in.
            // We throw an interactionRequired so that we trigger the interactive signin.
            
            if  try self.applicationContext.users().isEmpty {
                throw NSError.init(domain: "MSALErrorDomain", code: MSALErrorCode.interactionRequired.rawValue, userInfo: nil)
            } else {
                
                // Acquire a token for an existing user silently
                
                try self.applicationContext.acquireTokenSilent(forScopes: self.kScopes, user: applicationContext.users().first) { (result, error) in
                    
                    if error == nil {
                        accessToken = (result?.accessToken)!
                        
                        DispatchQueue.main.async {
                            self.signoutButton.isEnabled = true;                            //Main thread ERROR
                            self.downloadButton.isEnabled = true;
                            self.settingsButton.isEnabled = true;
                        }
                        
                        self.makeRequest(self.kGraphURI + "/drive/root/search(q='.xls')?select=name,id,webUrl") { jsonResult in
                            
                            for obj in jsonResult["value"] {
                                print("HELLO THERE\n\n\n\(obj.1["name"]) \(obj.1["id"])")
                                let name = obj.1["name"].string!
                                let id = obj.1["id"].string!
                                
                                self.docList.append((name, id))
                            }
                            
                        }
                        
                    } else {
//                        self.loggingText.text = "Could not acquire token silently: \(error ?? "No error information" as! Error)"
                        
                    }
                }
            }
        }  catch let error as NSError {
            
            // interactionRequired means we need to ask the user to sign-in. This usually happens
            // when the user's Refresh Token is expired or if the user has changed their password
            // among other possible reasons.
            
            if error.code == MSALErrorCode.interactionRequired.rawValue {
                
                self.applicationContext.acquireToken(forScopes: self.kScopes) { (result, error) in
                    if error == nil {
                        accessToken = (result?.accessToken)!
//                        self.loggingText.text = "Access token is \(accessToken)"
                        self.signoutButton.isEnabled = true;
                        self.settingsButton.isEnabled = true;
                        self.downloadButton.isEnabled = true;
                        
                    } else  {
//                        self.loggingText.text = "Could not acquire token: \(error ?? "No error information" as! Error)"
                    }
                }
                
            }
            
        } catch {
            
            // This is the catch all error.
            
//            self.loggingText.text = "Unable to acquire token. Got error: \(error)"
        }
        
    }
    
    
    @IBAction func testButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchOrderRequest =  NSFetchRequest<NSManagedObject>(entityName: "Order")
        
        var ot = [NSManagedObject]()
        do {
            ot = (try managedContext?.fetch(fetchOrderRequest))!
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print("Orders from Core Data")
        for o in ot {
            let ord = o as! Order
            print("Order: Client = \(ord.orderingClient?.name); Product = \(ord.productType?.name)")
//            print(o.value(forKeyPath: "orderingClient") as! String)
        }
        
        
    }
    
    
    
    
    func makeRequest(_ urlString: String, completion: @escaping (JSON)->() ) {

        let sessionConfig = URLSessionConfiguration.default

        // Specify the Graph API endpoint
        let url = URL(string: urlString)

        var request = URLRequest(url: url!)

        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)

        urlSession.dataTask(with: request) { data, response, error in
            let json = try! JSON(data: data!)
            completion(json)
        }.resume()
    }
        
    
    
    @IBAction func signoutButton(_ sender: UIButton) {
        
        do {
            
            // Removes all tokens from the cache for this application for the provided user
            // first parameter:   The user to remove from the cache
            
            try self.applicationContext.remove(self.applicationContext.users().first)
            self.signoutButton.isEnabled = false;
            self.settingsButton.isEnabled = false;
            self.downloadButton.isEnabled = false;
            
        } catch let error {
            print("Received error signing user out: \(error)")
        }
    }
    
    
    @IBAction func selectDocument(_ sender: Any) {
        activityIndicator.startAnimating()
        
        var productList:[Product] = []
        var clientList:[Client] = []
        
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let id = defaults.value(forKey: "docID") as! String
        let customerPath = (defaults.value(forKey: "customerSource") as! String).replacingOccurrences(of: " ", with: "%20")
        let productPath = (defaults.value(forKey: "productSource") as! String).replacingOccurrences(of: " ", with: "%20")
        let orderPath = (defaults.value(forKey: "orderSource") as! String).replacingOccurrences(of: " ", with: "%20")
        
        //Collecting client data
        
        self.makeRequest(self.kGraphURI + "drive/items/\(id)/workbook/worksheets('\(customerPath)')/usedRange", completion: { worksheetData in
            // do something with the returned json
            
            print("\n\nList of products:\n")
            var i = 1
            while worksheetData["formulas"][i][0] != JSON.null && worksheetData["formulas"][i][0].string!.count > 0 {
                
                let tempClient = NSEntityDescription.insertNewObject(forEntityName: "Client", into: managedContext!) as! Client
                
                tempClient.name = worksheetData["formulas"][i][0].string!
                tempClient.address = worksheetData["formulas"][i][1].string! + " " + worksheetData["formulas"][i][2].string!
                clientList.append(tempClient)
                
                i += 1
            }
            
            
            //Get list of products from Product sheet
            self.makeRequest(self.kGraphURI + "drive/items/\(id)/workbook/worksheets('\(productPath)')/usedRange", completion: { worksheetData in
                // do something with the returned json
                
                var i = 1
                while  worksheetData["formulas"][i][0] != JSON.null && worksheetData["formulas"][i][0].string!.count > 0{
                    
                    let tempProd = NSEntityDescription.insertNewObject(forEntityName: "Product", into: managedContext!) as! Product
                    tempProd.name = worksheetData["formulas"][i][0].string!
                    if let price = worksheetData["formulas"][i][4].double {
                        tempProd.price = price
                    } else { tempProd.price = 0}
                    productList.append(tempProd)
                    
                    i += 1
                }
                
                
                
                //Get product details from Weekly orders
                self.makeRequest(self.kGraphURI + "drive/items/\(id)/workbook/worksheets('\(orderPath)')/usedRange", completion: { worksheetData in
                    // do something with the returned json
                    
                    var i = 1
                    while  worksheetData["formulas"][i][0] != JSON.null && worksheetData["formulas"][i][0].string!.count > 0{
                        
                        let prodName = worksheetData["formulas"][i][0].string!
                        let orderingClient = worksheetData["formulas"][i][8].string!
                        
                        print("Found order in excel: Product = \"\(prodName)\"; Client = \"\(orderingClient)\"")
                        
                        for thisProduct in productList {
                            print("Searching for existing product in ProductList: " + thisProduct.name!)
                            
                            if thisProduct.name == prodName {
                                print("Found matching product")
                                if let cat = worksheetData["formulas"][i][9].int16 {
                                    thisProduct.catagory = cat
                                } else {thisProduct.catagory = 0}
                                for thisClient in clientList {
                                    print("Searching for existing client in ClientList: " + thisClient.name!)
                                    if thisClient.name == orderingClient { // Found Client/Product pair
                                        print("Found matching client")
                                        let tempOrder = NSEntityDescription.insertNewObject(forEntityName: "Order", into: managedContext!) as! Order
                                        tempOrder.productType = thisProduct
                                        tempOrder.orderingClient = thisClient
                                        if let mon = worksheetData["formulas"][i][1].int16 {
                                            tempOrder.monday = mon
                                        } else { tempOrder.monday = 0 }
                                        
                                        if let tues = worksheetData["formulas"][i][2].int16 {
                                            tempOrder.tuesday = tues
                                        } else { tempOrder.tuesday = 0 }
                                        
                                        if let wed = worksheetData["formulas"][i][3].int16 {
                                            tempOrder.wednesday = wed
                                        } else { tempOrder.wednesday = 0 }
                                        
                                        if let thur = worksheetData["formulas"][i][4].int16 {
                                            tempOrder.thursday = thur
                                        } else { tempOrder.thursday = 0 }
                                        
                                        if let fri = worksheetData["formulas"][i][5].int16 {
                                            tempOrder.friday = fri
                                        } else { tempOrder.friday = 0 }
                                        
                                        if let sat = worksheetData["formulas"][i][6].int16 {
                                            tempOrder.saturday = sat
                                        } else { tempOrder.saturday = 0 }
                                        
                                        if let sun = worksheetData["formulas"][i][7].int16 {
                                            tempOrder.sunday = sun
                                        } else { tempOrder.sunday = 0 }
                                        
                                        break //Break out of client search loop
                                    }
                                }
                                break //Break out of product search loop
                            }
                            
                        }
                        
                        i += 1
                    }
                    
                    DispatchQueue.main.async {
                        // update UI
                        do { // Saved to Core Data
                            
                            let fetch1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
                            let request1 = NSBatchDeleteRequest(fetchRequest: fetch1)
                            let result1 = try managedContext?.execute(request1)
                            
                            let fetch2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Client")
                            let request2 = NSBatchDeleteRequest(fetchRequest: fetch2)
                            let result2 = try managedContext?.execute(request2)
                            
                            let fetch3 = NSFetchRequest<NSFetchRequestResult>(entityName: "Order")
                            let request3 = NSBatchDeleteRequest(fetchRequest: fetch3)
                            let result3 = try managedContext?.execute(request3)
                            
                            try managedContext?.save()
                            self.defaults.set(Date(), forKey: "lastUpdate")
                            self.activityIndicator.stopAnimating()
                            self.updateDateLabel()
                            NotificationCenter.default.post(name: Notification.Name("databaseRefreshed"), object: nil, userInfo: nil)
                            print("Saved to Core Data")
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                })
                
            })
            
        })
        
    }
}



extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return docList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return docList[row].name
    }
    
    
}

extension Date {
    
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
