//
//  SettingsPopupViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 3/26/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingsPopupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, URLSessionDelegate {
    
    @IBOutlet weak var selector: UIPickerView!
    @IBOutlet weak var docButton: UIButton!
    @IBOutlet weak var customerButton: UIButton!
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var orderButton: UIButton!
    
    var selectorOptions:[String] = []
    var docOptions:[String] = []
    var worksheetOptions:[String] = []
    var docList:[(name: String, id: String)] = []
    var id = ""
    
    let defaults = UserDefaults.standard
    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((defaults.value(forKey: "docSource") is String) && (defaults.value(forKey: "docSource") is String)) {
            docButton.setTitle((defaults.value(forKey: "docSource") as! String), for: .normal)
            id = defaults.value(forKey: "docID") as! String
            getWorksheets()
        } else {
            docButton.setTitle("Choose Source...", for: .normal)
            setButtonState(enabled: false, exception: docButton)
        }
        
        
        if (defaults.value(forKey: "customerSource") is String) {
            customerButton.setTitle((defaults.value(forKey: "customerSource") as! String), for: .normal)
        } else {
            customerButton.setTitle("Choose Source...", for: .normal)
        }
        
        if (defaults.value(forKey: "productSource") is String) {
            productButton.setTitle((defaults.value(forKey: "productSource") as! String), for: .normal)
        } else {
            productButton.setTitle("Choose Source...", for: .normal)
        }
        
        if (defaults.value(forKey: "orderSource") is String) {
            orderButton.setTitle((defaults.value(forKey: "orderSource") as! String), for: .normal)
        } else {
            orderButton.setTitle("Choose Source...", for: .normal)
        }
        
        
        docButton.isEnabled = false
        makeRequest(self.kGraphURI + "/drive/root/search(q='.xls')?select=name,id,webUrl") { jsonResult in
            
            for obj in jsonResult["value"] {
                let name = obj.1["name"].string!
                let id = obj.1["id"].string!
                
                self.docList.append((name, id))
            }
            self.convertDocList()
            
            DispatchQueue.main.async {
                self.docButton.isEnabled = true
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func convertDocList() {
        docOptions = []
        for x in docList {
            docOptions.append(x.name)
        }
    }
    
    func setButtonState(enabled: Bool, exception: UIButton?) {
        let msg = enabled ? "enable":"disable"
        print("Will " + msg + " buttons.")
        docButton.isEnabled = enabled
        customerButton.isEnabled = enabled
        productButton.isEnabled = enabled
        orderButton.isEnabled = enabled
        if exception != nil { exception!.isEnabled = true }
    }
    
    
    @IBAction func selectSource(_ sender: UIButton) {
        if sender.titleLabel?.text == "SELECT" {
            let selected = selectorOptions[selector.selectedRow(inComponent: 0)]
            
            switch sender {
            case docButton:
                print("Selected doc button")
                defaults.set(selected, forKey: "docSource")
                id = docList[selector.selectedRow(inComponent: 0)].id
                defaults.set(id, forKey: "docID")
                getWorksheets()
            case customerButton:
                print("Selected doc button")
                defaults.set(selected, forKey: "customerSource")
                setButtonState(enabled: true, exception: nil)
            case productButton:
                print("Selected doc button")
                defaults.set(selected, forKey: "productSource")
                setButtonState(enabled: true, exception: nil)
            case orderButton:
                print("Selected doc button")
                defaults.set(selected, forKey: "orderSource")
                setButtonState(enabled: true, exception: nil)
            default:
                print("error")
            }
            sender.setTitle(selected, for: .normal)
            selectorOptions = []
            
        } else {
            switch sender {
            case docButton:
                selectorOptions = docOptions
            case customerButton:
                selectorOptions = worksheetOptions
            case productButton:
                selectorOptions = worksheetOptions
            case orderButton:
                selectorOptions = worksheetOptions
            default:
                selectorOptions = []
            }
            setButtonState(enabled: false, exception: sender)
            sender.setTitle("SELECT", for: .normal)
        }
        
        
        selector.reloadAllComponents()
        
    }
    
    
    
    func getWorksheets () {
        print("Get worksheets")
        setButtonState(enabled: false, exception: docButton)
        worksheetOptions = []
        makeRequest(kGraphURI + "drive/items/\(id)/workbook/worksheets", completion: { jsonResult in
            // do something with the returned json
            for obj in jsonResult["value"] {
                self.worksheetOptions.append(obj.1["name"].stringValue)
            }
            DispatchQueue.main.async {
                self.setButtonState(enabled: true, exception: nil)
            }
        })
        
    }
    
    
    func makeRequest(_ urlString: String, completion: @escaping (JSON)->() ) {
        print("Making request")
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
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectorOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectorOptions[row]
    }

}
