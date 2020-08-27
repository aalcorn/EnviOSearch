//
//  MapViewController.swift
//  EnviOSearch
//
//  Created by HGS on 7/16/20.
//  Copyright © 2020 HGS. All rights reserved.
//

//FACILITY URL: https://echo.epa.gov/detailed-facility-report?fid=110000368913
//FACILITY DATA URL: https://ofmpub.epa.gov/echo/dfr_rest_services.get_dfr?output=JSON&p_id=110000368913
//FACILITIES URL: https://ofmpub.epa.gov/echo/dfr_rest_services.get_facility_info?output=JSON&p_lat=37&p_long=-122&p_radius=10

import UIKit
import MapKit
import GoogleMobileAds
import AVFoundation

class MapViewController: UIViewController, GADInterstitialDelegate {
    
    @IBOutlet weak var mMap: MKMapView!
    @IBOutlet weak var moreInfoButton: UIButton!
    
    @IBOutlet weak var loadWheel: UIActivityIndicatorView!
    @IBOutlet weak var legendImage: UIImageView!
    @IBOutlet weak var legendLabel: UIButton!
    
    let markerSize = CGSize(width: 20, height: 20)
    
    var CAAClicked = true
    var CWAClicked = true
    var SDWAClicked = true
    var RCRAClicked = true
    var onlyNC = true
    var radius:Float = 0.5
    var lat:Double = 0
    var lon:Double = 0
    var facID:String?
    
    let newAnno = MKPointAnnotation()
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    
    var interstitial: GADInterstitial!
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        interstitial.load(request)
        
        mMap.delegate = self
        
        configureLocationServices()
        locationManager.startUpdatingLocation()
        
        //Zoom to user's current location based on search radius
        zoomToLocation(with: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        
        //Button appears and sends user to relevant facility page when clicked
        moreInfoButton.isHidden = true
        
        //Display user location
        mMap.showsUserLocation = true

        getJSON()
        
    }
    
    @IBAction func legendButtonClicked(_ sender: Any) {
        switch legendImage.isHidden {
        case true:
            legendImage.isHidden = false
        case false:
            legendImage.isHidden = true
        }
    }
    
    @IBAction func moreInfoClicked(_ sender: Any) {
        performSegue(withIdentifier: "facSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "facSegue" :
            let vc = segue.destination as! FacViewController
            vc.facID = facID
        case "backSegue" :
            let vc = segue.destination as! ViewController
            vc.appJustOpened = false
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
    
    private func zoomToLocation(with coordinate: CLLocationCoordinate2D) {
        let mileMeters:Float = 3000
        let zoomMeters = mileMeters * radius
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: CLLocationDistance(zoomMeters), longitudinalMeters: CLLocationDistance(zoomMeters))
        mMap.setRegion(zoomRegion, animated: true)
    }

    //Gets JSON data for facilities in the radius specified
    private func getJSON() {
        let myURL = "https://ofmpub.epa.gov/echo/echo_rest_services.get_facility_info?output=JSON&p_lat=\(lat)&p_long=\(lon)&p_radius=\(radius)"
        print(myURL)
        let urlString = myURL
        guard let url = URL(string: urlString
            ) else {
            print("ERROR")
                DispatchQueue.main.async {
                    self.showToast(message: "Connection Error!")
                }
                return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, _, _) in
            guard let data = data else {
                print("DATA ERROR")
                DispatchQueue.main.async {
                    self.showToast(message: "Connection Error!")
                }
                return
            }
            do {
                let resultSet = try JSONDecoder().decode(ResultSet.self, from: data)
                if let facilities = resultSet.Results.Facilities {
                    for facility in facilities {
                        let facLat = Double(facility.FacLat)
                        let facLon = Double(facility.FacLong)
                        let facNC = Int(facility.FacQtrsWithNC ?? "-1")
                        self.addFacilityToMap(CAA: facility.CAAComplianceStatus ?? "NA", CWA: facility.CWAComplianceStatus ?? "NA", SDWA: facility.SDWAComplianceStatus ?? "NA", RCRA: facility.RCRAComplianceStatus ?? "NA", id: facility.RegistryID, name: facility.FacName, latitude: facLat ?? 80, longitude: facLon ?? -80, NCQtrs: facNC ?? -1)
                    }
                    
                    DispatchQueue.main.async {
                        self.loadWheel.isHidden = true
                        self.showToast(message: "Finished")
                    }
                }
                else {
                    print("TOO MANY FACILITIES")
                    DispatchQueue.main.async {
                        self.loadWheel.isHidden = true
                        self.showToast(message: "Too many facilities! Lower radius")
                    }
                }
                
            } catch let Jerr {
                print(Jerr)
            }
        }
        task.resume()
        
    }

    //Uses the facility's compliance status and type to decide which icon to use, then adds a marker to the map
    private func addFacilityToMap(CAA: String, CWA: String, SDWA: String, RCRA: String, id: String, name: String, latitude: Double, longitude: Double, NCQtrs: Int) {
        var subtitle = ""
        
        //A catagory: CAA, W catagory: CWA, S catagory: SDWA, R catagory: RCRA
        if NCQtrs != -1 {
            if NCQtrs >= 7 {
                if CWA != "NA" && CWA != "Not Applicable" && CWAClicked {
                    subtitle = "High Priority Non-Compliance W \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if CAA != "NA" && CAA != "Not Applicable" && CAAClicked {
                    subtitle = "High Priority Non-Compliance A \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if RCRA != "NA" && RCRA != "Not Applicable" && RCRAClicked {
                    subtitle = "High Priority Non-Compliance R \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if SDWA != "NA" && SDWA != "Not Applicable" && SDWAClicked {
                    subtitle = "High Priority Non-Compliance S \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
            }
            else if NCQtrs > 0 {
                if CWA != "NA" && CWA != "Not Applicable" && CWAClicked {
                    subtitle = "Mid Priority Non-Compliance W \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if CAA != "NA" && CAA != "Not Applicable" && CAAClicked {
                    subtitle = "Mid Priority Non-Compliance A \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if RCRA != "NA" && RCRA != "Not Applicable" && RCRAClicked {
                    subtitle = "Mid Priority Non-Compliance R \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if SDWA != "NA" && SDWA != "Not Applicable" && SDWAClicked {
                    subtitle = "Mid Priority Non-Compliance S \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
            }
            else if NCQtrs == 0 && !onlyNC {
                if CWA != "NA" && CWA != "Not Applicable" && CWAClicked {
                    subtitle = "No recent Non-Compliance W \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if CAA != "NA" && CAA != "Not Applicable" && CAAClicked {
                    subtitle = "No recent Non-Compliance A \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if RCRA != "NA" && RCRA != "Not Applicable" && RCRAClicked {
                    subtitle = "No recent Non-Compliance R \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if SDWA != "NA" && SDWA != "Not Applicable" && SDWAClicked {
                    subtitle = "No recent Non-Compliance S \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                
            }
            
        }
        
        
    }
    
    func addMarker(title: String, subtitle: String, latitude: Double, longitude: Double) {
        print(title)
        DispatchQueue.main.async {
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.subtitle = subtitle
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mMap.addAnnotation(annotation)
        }
        
    }
    
    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.width/2-125, y: self.view.frame.height-100, width: 250, height: 40))
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

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {
            return
        }
        
        currentLocation = latestLocation.coordinate
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        //Set Icons based on descriptions
        let theString:String = (annotation.subtitle ?? "") ?? ""
        var subtitleArray = theString.split(separator: " ")
        
        if subtitleArray.count == 0 {
            subtitleArray.insert(" ", at: 0)
        }
        
        if subtitleArray[0] == "High" {
            switch subtitleArray[3] {
            case "A":
                annotationView?.image = UIImage(named: "CAA Red")?.scaleImage(toSize: markerSize)
            case "W":
                annotationView?.image = UIImage(named: "CWA Red")?.scaleImage(toSize: markerSize)
            case "R" :
                annotationView?.image = UIImage(named: "RCRA Red")?.scaleImage(toSize: markerSize)
            case "S":
                annotationView?.image = UIImage(named: "SDWA Red")?.scaleImage(toSize: markerSize)
            default:
                print("None Found")
            }
        }
        else if subtitleArray[0] == "Mid" {
            switch subtitleArray[3] {
            case "A":
                annotationView?.image = UIImage(named: "CAA Yellow")?.scaleImage(toSize: markerSize)
            case "W":
                annotationView?.image = UIImage(named: "CWA Yellow")?.scaleImage(toSize: markerSize)
            case "R" :
                annotationView?.image = UIImage(named: "RCRA Yellow")?.scaleImage(toSize: markerSize)
            case "S":
                annotationView?.image = UIImage(named: "SDWA Yellow")?.scaleImage(toSize: markerSize)
            default:
                print("None Found")
            }
        }
        else if subtitleArray[0] == "No" {
            switch subtitleArray[3] {
            case "A":
                annotationView?.image = UIImage(named: "CAA Green")?.scaleImage(toSize: markerSize)
            case "W":
                annotationView?.image = UIImage(named: "CWA Green")?.scaleImage(toSize: markerSize)
            case "R" :
                annotationView?.image = UIImage(named: "RCRA Green")?.scaleImage(toSize: markerSize)
            case "S":
                annotationView?.image = UIImage(named: "SDWA Green")?.scaleImage(toSize: markerSize)
            default:
                print("None Found")
            }
        }
        else {
            return nil
        }
        
        annotationView?.canShowCallout = true
        
        return annotationView
    }
    
    //When annotation is selected, play corresponding sound and show the more info button
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation Selected: \(String(describing: view.annotation?.title))")
        
        let theString:String = (view.annotation?.subtitle ?? "") ?? ""
        var subtitleArray = theString.split(separator: " ")
        if subtitleArray.count == 0 {
            subtitleArray.insert(" ", at: 0)
        }
        
        if subtitleArray[0] == "High" || subtitleArray[0] == "Mid" || subtitleArray[0] == "No" && subtitleArray[0] != " " {
            facID = String(subtitleArray[4])
            print(facID ?? "None")
            moreInfoButton.isHidden = false
            switch subtitleArray[3] {
            case "A":
                playSound(soundName: "CAA")
            case "W":
                playSound(soundName: "CWA")
            case "R" :
                playSound(soundName: "RCRA")
            case "S":
                playSound(soundName: "SDWA")
            default:
                print("None Found")
            }
        }
        else {
            facID = nil
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Unselected")
        moreInfoButton.isHidden = true
        facID = nil
    }
}

extension UIImage {
    //Make the image a certain size.
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
}
