//
//  ViewController.swift
//  EnviOSearch
//
//  Created by HGS on 7/15/20.
//  Copyright © 2020 HGS. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var milesLabel: UILabel!
    
    @IBOutlet weak var milesSlider: UISlider!
    
    @IBOutlet weak var CAASwitch: UISwitch!
    @IBOutlet weak var CWASwitch: UISwitch!
    @IBOutlet weak var SDWASwitch: UISwitch!
    @IBOutlet weak var RCRASwitch: UISwitch!
    @IBOutlet weak var onlyNCSwitch: UISwitch!
    
    var CAAClicked = true
    var CWAClicked = true
    var SDWAClicked = true
    var RCRAClicked = true
    var onlyNC = true
    
    var radius:Float = 0.5
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureLocationServices()
        locationManager.startUpdatingLocation()
        
        
    }

    @IBAction func milesSliderValueChanged(_ sender: Any) {
        radius = round(milesSlider.value * 10.0) / 10.0
        
        if radius == 1.0 {
            milesLabel.text = "1 Mile"
        }
        else {
            milesLabel.text = "\(radius) Miles"
        }
        
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        CAAClicked = CAASwitch.isOn
        CWAClicked = CWASwitch.isOn
        RCRAClicked = RCRASwitch.isOn
        SDWAClicked = SDWASwitch.isOn
        onlyNC = onlyNCSwitch.isOn
        
        performSegue(withIdentifier: "toMapSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toMapSegue" :
            let vc = segue.destination as! MapViewController
            vc.radius = self.radius
            vc.CAAClicked = self.CAAClicked
            vc.CWAClicked = self.CWAClicked
            vc.RCRAClicked = self.RCRAClicked
            vc.SDWAClicked = self.SDWAClicked
            vc.onlyNC = self.onlyNC
            vc.lat = currentLocation?.latitude ?? 25
            vc.lon = currentLocation?.longitude ?? 25
            
        default:
            break
        }
        
    }
    
    private func configureLocationServices() {
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .restricted {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.width/2-75, y: self.view.frame.height - 100, width: 150, height: 40))
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.text = message
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 4.0, delay: 1.0, options: .curveEaseInOut, animations: {
            toastLabel.alpha = 0.0
        }) { (isCompleted) in
            toastLabel.removeFromSuperview()
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {
            return
        }
        
        currentLocation = latestLocation.coordinate
    }
}
