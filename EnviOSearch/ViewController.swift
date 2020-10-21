//
//  ViewController.swift
//  EnviOSearch
//
//  Created by HGS on 7/15/20.
//  Copyright © 2020 HGS. All rights reserved.
//
// App ID: "ca-app-pub-6391108766292407~8118816606"
// 

import UIKit
import MapKit
import GoogleMobileAds
import AVFoundation
import AdSupport
import CoreLocation

class ViewController: UIViewController, GADInterstitialDelegate, UITextFieldDelegate {
    
    @IBOutlet var blurView: UIVisualEffectView!
    
    @IBOutlet var addressView: UIView!
    
    @IBOutlet var popupView: UIView!
    
    @IBOutlet weak var addressTextView: UITextField!
    
    @IBOutlet weak var milesLabel: UILabel!
    
    @IBOutlet weak var milesSlider: UISlider!
    
    @IBOutlet weak var CAASwitch: UISwitch!
    @IBOutlet weak var CWASwitch: UISwitch!
    @IBOutlet weak var SDWASwitch: UISwitch!
    @IBOutlet weak var RCRASwitch: UISwitch!
    @IBOutlet weak var onlyNCSwitch: UISwitch!
    
    @IBOutlet weak var adView: GADBannerView!
    
    var CAAClicked = true
    var CWAClicked = true
    var SDWAClicked = true
    var RCRAClicked = true
    var onlyNC = true
    
    var radius:Float = 0.5
    
    var latitude = 0.0
    var longitude = 0.0
    
    var searchType = "userLocation"
    
    var interstitial: GADInterstitial!
   
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    
    var appJustOpened = true
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        blurView.bounds = self.view.bounds
        popupView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.4)
        addressView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.4)
        addressView.layer.cornerRadius = 10
        
        addressTextView.delegate = self
        
        //interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910") This is the test
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-6391108766292407/5032244997")
        //mapAd ID: "ca-app-pub-6391108766292407/5032244997"
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        
        configureLocationServices()
        locationManager.startUpdatingLocation()
        adView.delegate = self
        
        //adView.adUnitID = "ca-app-pub-3940256099942544/2934735716" this is the test
        adView.adUnitID = "ca-app-pub-6391108766292407/5443308538"
        //homeBanner ID: "ca-app-pub-6391108766292407/5443308538"
        adView.rootViewController = self
        adView.load(GADRequest())
        
        
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            print("Not first launch")
            //Do nothing
        }
        else {
            print("First launch")
            //Set to true
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            //Present screen explaining source of information
            animateIn(desiredView: blurView)
            animateIn(desiredView: popupView)
            
        }
        
        if appJustOpened {
            //Play intro sound
            print("Just opened")
            playSound(soundName: "Intro")
        }
        else {
            print("NOT Just opened!")
            
        }
        
        
    }
    
    func animateIn(desiredView: UIView) {
        let backgroundView = self.view!
        
        backgroundView.addSubview(desiredView)
        
        desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        desiredView.alpha = 0
        desiredView.center = backgroundView.center
        
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1        })
    }
    
    func animateOut(desiredView: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            desiredView.alpha = 0
        }, completion : { _ in
            desiredView.removeFromSuperview()
        })
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
    
    func doMapSegue() {
        CAAClicked = CAASwitch.isOn
        CWAClicked = CWASwitch.isOn
        RCRAClicked = RCRASwitch.isOn
        SDWAClicked = SDWASwitch.isOn
        onlyNC = onlyNCSwitch.isOn
        
        performSegue(withIdentifier: "toMapSegue", sender: self)
    }
    
    @IBAction func addressButtonPressed(_ sender: Any) {
        
        self.animateIn(desiredView: self.blurView)
        self.animateIn(desiredView: self.addressView)
            
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.animateOut(desiredView: self.addressView)
        self.animateOut(desiredView: self.blurView)
    }
    
    @IBAction func confButtonPressed(_ sender: Any) {
        if let address = addressTextView.text {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) {
                placemarks, error in
                let placemark = placemarks?.first
                let lat = placemark?.location?.coordinate.latitude
                let lon = placemark?.location?.coordinate.longitude
                
                self.latitude = lat ?? 0
                self.longitude = lon ?? 0
                print("Lat: \(lat), Lon: \(lon)")
                self.searchType = "address"
                if self.interstitial.isReady {
                    self.interstitial.present(fromRootViewController: self)
                    //doMapSegue() //Remove this line if you uncomment line above
                }
                else {
                    self.doMapSegue()
                }
            }
        }
        
        
        
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        latitude = currentLocation?.latitude ?? 25
        longitude = currentLocation?.longitude ?? 25
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            //doMapSegue() //Remove this line if you uncomment line above
        }
        else {
            doMapSegue()
        }
        
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
            vc.lat = self.latitude
            vc.lon = self.longitude
            vc.searchType = self.searchType
            
        case "customMapSegue" :
            let vc = segue.destination as! MapViewController
            vc.radius = self.radius
            vc.CAAClicked = self.CAAClicked
            vc.CWAClicked = self.CWAClicked
            vc.RCRAClicked = self.RCRAClicked
            vc.SDWAClicked = self.SDWAClicked
            vc.onlyNC = self.onlyNC
            vc.lat = currentLocation?.latitude ?? 25
            vc.lon = currentLocation?.longitude ?? 25
            vc.searchType = "customLocation"
            
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
    
    @IBAction func okayClicked(_ sender: Any) {
        animateOut(desiredView: blurView)
        animateOut(desiredView: popupView)
    }
    
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("Will Dismiss Screen")
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("SCREEN DISMISSED")
        doMapSegue()
    }
    
    func playSound(soundName: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")
        
        guard url != nil else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer?.play()
        }
        catch {
            print("Error")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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

extension ViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Got it")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}
