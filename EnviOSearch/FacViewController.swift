//
//  FacViewController.swift
//  EnviOSearch
//
//  Created by HGS on 7/30/20.
//  Copyright © 2020 HGS. All rights reserved.
//

import UIKit

class FacViewController: UIViewController {
    var facID:String?
    @IBOutlet weak var facilityNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Connected")
        
        if let text = facID {
            facilityNameLabel.text = text
        }
    }
}
