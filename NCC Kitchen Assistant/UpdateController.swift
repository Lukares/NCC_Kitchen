//
//  UpdateController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 4/19/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit
import SwiftyJSON

class UpdateController: UIViewController, URLSessionDelegate {

    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToUpdate(segue: UIStoryboardSegue) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let but = sender as! UIButton
        if segue.identifier == "addEntityPopup" {
            let vc = segue.destination as! AddEntityController
            let but = sender as! UIButton
            vc.popoverPresentationController?.sourceView = but
            vc.popoverPresentationController?.sourceRect = but.bounds
            if (but.titleLabel?.text?.contains("Client"))! {
                vc.isClient = true
            } else if (but.titleLabel?.text?.contains("Product"))! {
                vc.isClient = false
            }
            
        }
    }
    
}
