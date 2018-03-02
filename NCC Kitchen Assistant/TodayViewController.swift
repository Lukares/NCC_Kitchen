//
//  TodayViewController.swift
//  NCC Kitchen Assistant
//
//  Created by Daniel Fletcher on 3/2/18.
//  Copyright © 2018 Naturally Curly Cook. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    var dayOfWeek = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayOfWeek = getDayStr(day: Date())
        dateLabel.text = "Today is " + dayOfWeek + "!"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getDayStr(day: Date) -> String {
        let weekday = Calendar.current.component(.weekday, from: day)
        
        switch weekday {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return "error"
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
