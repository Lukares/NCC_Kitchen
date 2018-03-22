import UIKit
import CoreData
import SwiftyJSON
import MSAL
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate, URLSessionDelegate {
    
    let kClientID = "a43b5ef7-6217-4310-911f-6eb26d15ca1c"
    let kAuthority = "https://login.microsoftonline.com/common/v2.0"
    
    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    let kScopes: [String] = ["https://graph.microsoft.com/user.read", "https://graph.microsoft.com/files.readwrite.all"]
    
    let kDocumentID = ""
    
    var accessToken = String()
    var refreshToken = String()
    var applicationContext = MSALPublicClientApplication.init()
    
    var docList:[(name: String, id: String)] = []
    
    @IBOutlet weak var docPicker: UIPickerView!
    @IBOutlet weak var loggingText: UITextView!
    @IBOutlet weak var signoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // Initialize a MSALPublicClientApplication with a given clientID and authority
            self.applicationContext = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
        } catch {
            self.loggingText.text = "Unable to create Application Context. Error: \(error)"
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if self.accessToken.isEmpty {
            signoutButton.isEnabled = false; 
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        
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
                        self.accessToken = (result?.accessToken)!
                        self.loggingText.text = "Refreshing token silently)"
                        self.loggingText.text = "Refreshed Access token is \(self.accessToken)"
                        self.signoutButton.isEnabled = true;
                        self.getContentWithToken(self.kGraphURI)
                        
                        self.makeRequest(self.kGraphURI + "/drive/root/search(q='.xls')?select=name,id,webUrl") { jsonResult in
//                            print("List of files \n\n"+result.debugDescription)
                            
                            for obj in jsonResult["value"] {
                                print("HELLO THERE\n\n\n\(obj.1["name"]) \(obj.1["id"])")
                                let name = obj.1["name"].string!
                                let id = obj.1["id"].string!
                                
                                self.docList.append((name, id))
                            }
                            
                            // do something with the returned Bool
                            DispatchQueue.main.async {
                                self.docPicker.reloadAllComponents()
                            }
                        }
                        
                    } else {
                        self.loggingText.text = "Could not acquire token silently: \(error ?? "No error information" as! Error)"
                        
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
                        self.accessToken = (result?.accessToken)!
                        self.loggingText.text = "Access token is \(self.accessToken)"
                        self.signoutButton.isEnabled = true;
                        self.getContentWithToken(self.kGraphURI)
                        
                    } else  {
                        self.loggingText.text = "Could not acquire token: \(error ?? "No error information" as! Error)"
                    }
                }
                
            }
            
        } catch {
            
            // This is the catch all error.
            
            self.loggingText.text = "Unable to acquire token. Got error: \(error)"
        }
        
    }
    
    func getContentWithToken(_ api_call: String) {
        
        let sessionConfig = URLSessionConfiguration.default
        
        // Specify the Graph API endpoint
        let url = URL(string: api_call)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        
        urlSession.dataTask(with: request) { data, response, error in
            let result = try? JSONSerialization.jsonObject(with: data!, options: [])
            if result != nil {
                
                print(result.debugDescription)
            }
            }.resume()
    }
    
    @IBAction func testButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchProductRequest =  NSFetchRequest<NSManagedObject>(entityName: "Product")
        let fetchClientRequest =  NSFetchRequest<NSManagedObject>(entityName: "Client")
        
        var pt = [NSManagedObject]()
        var ct = [NSManagedObject]()
        do {
            pt = (try managedContext?.fetch(fetchProductRequest))!
            ct = (try managedContext?.fetch(fetchClientRequest))!
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print("Products from Core Data")
        for p in pt {
            print(p.value(forKeyPath: "name") as! String)
        }
        print("Clients from Core Data")
        for c in ct {
            print(c.value(forKeyPath: "name") as! String)
        }
        
    }
    
    
    
    
    func makeRequest(_ urlString: String, completion: @escaping (JSON)->() ) {

        let sessionConfig = URLSessionConfiguration.default

        // Specify the Graph API endpoint
        let url = URL(string: urlString)

        var request = URLRequest(url: url!)

        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)

        var result = [String:Any]()
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
            self.loggingText.text = "Logged out"
            
        } catch let error {
            self.loggingText.text = "Received error signing user out: \(error)"
        }
    }
    
    
    @IBAction func selectDocument(_ sender: Any) {
        let id = docList[docPicker.selectedRow(inComponent: 0)].id
        print("Selected ID" + id)
        
        var productList:[String] = []
        var clientList:[String] = []
        
        makeRequest(kGraphURI + "drive/items/\(id)/workbook/worksheets", completion: { jsonResult in
            // do something with the returned json
            for obj in jsonResult["value"] {
                print("Worksheet named \(obj.1["name"])")
        
                //Get list of products from Weekly Orders by Product sheet
        /*        if obj.1["name"].string == "Weekly Orders by Product" {
                    self.makeRequest(self.kGraphURI + "drive/items/\(id)/workbook/worksheets('Weekly%20Orders%20by%20Product')/usedRange", completion: { worksheetData in
                        // do something with the returned json
                        
                        print("\n\nList of products:\n")
                        var i = 1
                        while worksheetData["formulas"][i][11].string!.count > 0 {
                            print(worksheetData["formulas"][i][11].string!)
                            i += 1
                        }
                        
                        DispatchQueue.main.async {
                            // update UI
                        }
                    })
                }
        */
                
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedContext = appDelegate?.persistentContainer.viewContext
                let prodEntity = NSEntityDescription.entity(forEntityName: "Product", in: managedContext!)!
                let clientEntity = NSEntityDescription.entity(forEntityName: "Client", in: managedContext!)!
                
                
                //Get list of clients & Products from Customer sheet
                if obj.1["name"].string == "Weekly Orders" {
                    self.makeRequest(self.kGraphURI + "drive/items/\(id)/workbook/worksheets('Weekly%20Orders')/usedRange", completion: { worksheetData in
                        // do something with the returned json
                        
//                        print("\n\nList of Clients:\n")
                        var i = 1
                        while worksheetData["formulas"][i][0].string!.count > 0 {
                            let prod = worksheetData["formulas"][i][0].string!
                            let client = worksheetData["formulas"][i][8].string!
                            if !productList.contains(prod) {
                                productList.append(prod)
                                let tempProd = NSManagedObject(entity: prodEntity, insertInto: managedContext)
                                tempProd.setValue(prod, forKeyPath: "name")
                            }
                            if !clientList.contains(client) {
                                clientList.append(client)
                                let tempClient = NSManagedObject(entity: clientEntity, insertInto: managedContext)
                                tempClient.setValue(client, forKeyPath: "name")
                            }
                            i += 1
                        }
                        
                        print("Product list:\n\(productList)\n")
                        print("Client list:\n\(clientList)\n")

                        do {
                            try managedContext?.save()
                            print("Saved to Core Data")
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                        DispatchQueue.main.async {
                            // update UI
                        }
                    })
                }
                
            }
            
            
            DispatchQueue.main.async {
                // update UI
            }
            
            
        })
        
    }
    
    
    
}


func saveToCoreData(products: [String] ) {
    
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

