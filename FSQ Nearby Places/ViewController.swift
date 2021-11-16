//
//  ViewController.swift
//  FSQ Nearby Places
//
//  Created by Lyubomir Lazarov on 11/2/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet var nearbyView: UIView!
    @IBOutlet var aboutView: UIView!
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            nearbyView.alpha = 1
            aboutView.alpha = 0
        } else {
            nearbyView.alpha = 0
            aboutView.alpha = 1
        }
    }
}

