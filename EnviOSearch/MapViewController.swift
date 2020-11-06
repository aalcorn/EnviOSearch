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

class MapViewController: UIViewController {
    
    @IBOutlet weak var mMap: MKMapView!
    @IBOutlet weak var moreInfoButton: UIButton!
    
    @IBOutlet weak var enviroScoreLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var loadWheel: UIActivityIndicatorView!
    @IBOutlet weak var legendImage: UIImageView!
    @IBOutlet weak var legendLabel: UIButton!
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    
    
    let markerSize = CGSize(width: 20, height: 20)
    
    var CAAClicked = true
    var CWAClicked = true
    var SDWAClicked = true
    var RCRAClicked = true
    var onlyNC = true
    var ableToSearch = false
    var radius:Float = 0.5
    var lat:Double = 0
    var lon:Double = 0
    var facID:String?
    
    var searchType = "userLocation"
    
    var newLocationAnno = MKPointAnnotation()
    
    let newAnno = MKPointAnnotation()
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mMap.delegate = self
        
        configureLocationServices()
        locationManager.startUpdatingLocation()
        
        //Zoom to user's current location based on search radius
        
        
        //Button appears and sends user to relevant facility page when clicked
        moreInfoButton.isEnabled = false
        
        if searchType == "customLocation" {
            loadWheel.isHidden = true
            mMap.showsUserLocation = false
            newLocationAnno.title = "Custom Location"
            newLocationAnno.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            newLocationAnno.subtitle = "Move me to your custom location!"
            mMap.addAnnotation(newLocationAnno)
            
            locationButton.setTitle("Select Location", for: .normal)
            showToast(message: "Move marker to new location")
            
            locationButton.setTitle("Select Location", for: .normal)
            showToast(message: "Move marker to new location")
            ableToSearch = true
            
            enviroScoreLabel.text = " "
        }
        else if searchType == "userLocation" {
            mMap.showsUserLocation = true
            zoomToLocation(with: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            disableButton()
            getJSON()
        }
        else {
            mMap.showsUserLocation = false
            newLocationAnno.title = "Custom Location"
            newLocationAnno.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            newLocationAnno.subtitle = "Custom Location"
            mMap.addAnnotation(newLocationAnno)
            zoomToLocation(with: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            
            locationButton.setTitle("Choose New Location", for: .normal)
            disableButton()
            
            getJSON()
        }

        
        
    }
    
    @IBAction func legendButtonClicked(_ sender: Any) {
        switch legendImage.isHidden {
        case true:
            legendImage.isHidden = false
            legendLabel.setTitle("Hide Legend", for: .normal)
        case false:
            legendImage.isHidden = true
            legendLabel.setTitle("Show Legend", for: .normal)
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
    
    
    @IBAction func locationButtonClicked(_ sender: Any) {
        
        if !ableToSearch {
            enviroScoreLabel.text = " "
            
            self.star1.image = UIImage(systemName: "star")
            self.star2.image = UIImage(systemName: "star")
            self.star3.image = UIImage(systemName: "star")
            self.star4.image = UIImage(systemName: "star")
            self.star5.image = UIImage(systemName: "star")
            
            mMap.removeAnnotations(mMap.annotations)
            mMap.showsUserLocation = false
            newLocationAnno.title = "Custom Location"
            newLocationAnno.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            newLocationAnno.subtitle = "Move me to your custom location!"
            mMap.addAnnotation(newLocationAnno)
            
            locationButton.setTitle("Select Location", for: .normal)
            showToast(message: "Move marker to new location")
            
            locationButton.setTitle("Select Location", for: .normal)
            showToast(message: "Move marker to new location")
            ableToSearch = true
        
        }
        
        else {
            enviroScoreLabel.text = "Pending area ranking"
            
            let newCoord = newLocationAnno.coordinate
            lat = newCoord.latitude
            lon = newCoord.longitude
            
            mMap.removeAnnotations(mMap.annotations)
            
            mMap.showsUserLocation = false
            newLocationAnno.title = "Custom Location"
            newLocationAnno.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            newLocationAnno.subtitle = "Custom Location"
            mMap.addAnnotation(newLocationAnno)
            
            locationButton.setTitle("Choose New Location", for: .normal)
            disableButton()
            
            
            getJSON()
            loadWheel.isHidden = false
            
            
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
        disableButton()
        zoomToLocation(with: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        var totalNC:Float = 0
        let myURL = "https://ofmpub.epa.gov/echo/echo_rest_services.get_facility_info?output=JSON&p_lat=\(lat)&p_long=\(lon)&p_radius=\(radius)"
        print(myURL)
        let urlString = myURL
        guard let url = URL(string: urlString
            ) else {
            print("ERROR")
                DispatchQueue.main.async {
                    self.loadWheel.isHidden = true
                    self.showToast(message: "Connection Error!")
                    self.enableButton()
                    self.ableToSearch = false
                }
                return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, _, _) in
            guard let data = data else {
                print("DATA ERROR")
                DispatchQueue.main.async {
                    self.loadWheel.isHidden = true
                    self.showToast(message: "Connection Error!")
                    self.enableButton()
                    self.ableToSearch = false
                }
                return
            }
            do {
                let resultSet = try JSONDecoder().decode(ResultSet.self, from: data)
                if let facilities = resultSet.Results.Facilities {
                    let numFac = Double(resultSet.Results.QueryRows ?? "0")
                    for facility in facilities {
                        let facLat = Double(facility.FacLat)
                        let facLon = Double(facility.FacLong)
                        let facNC = Int(facility.FacQtrsWithNC ?? "-1")
                        totalNC += Float(Int(facility.FacQtrsWithNC ?? "0") ?? 0)
                        self.addFacilityToMap(CAA: facility.CAAComplianceStatus ?? "NA", CWA: facility.CWAComplianceStatus ?? "NA", SDWA: facility.SDWAComplianceStatus ?? "NA", RCRA: facility.RCRAComplianceStatus ?? "NA", id: facility.RegistryID, name: facility.FacName, latitude: facLat ?? 80, longitude: facLon ?? -80, NCQtrs: facNC ?? -1)
                    }
                    //print("The average is: " + String(totalNC/numFac!))
                    print(totalNC)
                    print(numFac!)
                    let pi:Float = 3.14
                    let baseline:Float = 12.57
                    
                    let enviroScore = totalNC/(((pi)*(self.radius*self.radius))/baseline)
                    
                    print(enviroScore)
                    
                    DispatchQueue.main.async {
                        switch enviroScore {
                        case 0..<10:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.fill")
                            self.star2.image = UIImage(systemName: "star.fill")
                            self.star3.image = UIImage(systemName: "star.fill")
                            self.star4.image = UIImage(systemName: "star.fill")
                            self.star5.image = UIImage(systemName: "star.fill")
                        case 10..<20:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.fill")
                            self.star2.image = UIImage(systemName: "star.fill")
                            self.star3.image = UIImage(systemName: "star.fill")
                            self.star4.image = UIImage(systemName: "star.fill")
                            self.star5.image = UIImage(systemName: "star.lefthalf.fill")
                        case 20..<35:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.fill")
                            self.star2.image = UIImage(systemName: "star.fill")
                            self.star3.image = UIImage(systemName: "star.fill")
                            self.star4.image = UIImage(systemName: "star.fill")
                            self.star5.image = UIImage(systemName: "star")
                        case 35..<70:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.fill")
                            self.star2.image = UIImage(systemName: "star.fill")
                            self.star3.image = UIImage(systemName: "star.fill")
                            self.star4.image = UIImage(systemName: "star.lefthalf.fill")
                            self.star5.image = UIImage(systemName: "star")
                        case 70..<120:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.fill")
                            self.star2.image = UIImage(systemName: "star.fill")
                            self.star3.image = UIImage(systemName: "star.fill")
                            self.star4.image = UIImage(systemName: "star")
                            self.star5.image = UIImage(systemName: "star")
                        case 120..<160:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.fill")
                            self.star2.image = UIImage(systemName: "star.fill")
                            self.star3.image = UIImage(systemName: "star.lefthalf.fill")
                            self.star4.image = UIImage(systemName: "star")
                            self.star5.image = UIImage(systemName: "star")
                        case 160..<200:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.fill")
                            self.star2.image = UIImage(systemName: "star.fill")
                            self.star3.image = UIImage(systemName: "star")
                            self.star4.image = UIImage(systemName: "star")
                            self.star5.image = UIImage(systemName: "star")
                        case 200..<240:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.fill")
                            self.star2.image = UIImage(systemName: "star.lefthalf.fill")
                            self.star3.image = UIImage(systemName: "star")
                            self.star4.image = UIImage(systemName: "star")
                            self.star5.image = UIImage(systemName: "star")
                        case 240..<300:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.fill")
                            self.star2.image = UIImage(systemName: "star")
                            self.star3.image = UIImage(systemName: "star")
                            self.star4.image = UIImage(systemName: "star")
                            self.star5.image = UIImage(systemName: "star")
                        default:
                            self.enviroScoreLabel.text = "Enviroscore:"
                            self.star1.image = UIImage(systemName: "star.lefthalf.fill")
                            self.star2.image = UIImage(systemName: "star")
                            self.star3.image = UIImage(systemName: "star")
                            self.star4.image = UIImage(systemName: "star")
                            self.star5.image = UIImage(systemName: "star")
                        }
                        
                        self.loadWheel.isHidden = true
                        self.showToast(message: "Finished")
                        self.enableButton()
                        self.ableToSearch = false
                    }
                }
                else {
                    print("TOO MANY FACILITIES")
                    DispatchQueue.main.async {
                        self.loadWheel.isHidden = true
                        self.showToast(message: "Too many facilities! Lower radius")
                        self.enableButton()
                        self.ableToSearch = false
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
                    subtitle = "High Priority CWA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if CAA != "NA" && CAA != "Not Applicable" && CAAClicked {
                    subtitle = "High Priority CAA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if RCRA != "NA" && RCRA != "Not Applicable" && RCRAClicked {
                    subtitle = "High Priority RCRA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if SDWA != "NA" && SDWA != "Not Applicable" && SDWAClicked {
                    subtitle = "High Priority SDWA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
            }
            else if NCQtrs > 0 {
                if CWA != "NA" && CWA != "Not Applicable" && CWAClicked {
                    subtitle = "Mid Priority CWA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if CAA != "NA" && CAA != "Not Applicable" && CAAClicked {
                    subtitle = "Mid Priority CAA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if RCRA != "NA" && RCRA != "Not Applicable" && RCRAClicked {
                    subtitle = "Mid Priority RCRA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if SDWA != "NA" && SDWA != "Not Applicable" && SDWAClicked {
                    subtitle = "Mid Priority RCRA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
            }
            else if NCQtrs == 0 && !onlyNC {
                if CWA != "NA" && CWA != "Not Applicable" && CWAClicked {
                    subtitle = "No recent CWA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if CAA != "NA" && CAA != "Not Applicable" && CAAClicked {
                    subtitle = "No recent CAA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if RCRA != "NA" && RCRA != "Not Applicable" && RCRAClicked {
                    subtitle = "No recent RCRA Non-Compliance ID: \(id)"
                    addMarker(title: name, subtitle: subtitle, latitude: latitude, longitude: longitude)
                }
                else if SDWA != "NA" && SDWA != "Not Applicable" && SDWAClicked {
                    subtitle = "No recent SDWA Non-Compliance ID: \(id)"
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
    
    func enableButton() {
        locationButton.isEnabled = true
        locationButton.alpha = 1.0
    }
    
    func disableButton() {
        locationButton.isEnabled = false
        locationButton.alpha = 0.6
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
            switch subtitleArray[2] {
            case "CAA":
                annotationView?.image = UIImage(named: "CAA Red")?.scaleImage(toSize: markerSize)
            case "CWA":
                annotationView?.image = UIImage(named: "CWA Red")?.scaleImage(toSize: markerSize)
            case "RCRA" :
                annotationView?.image = UIImage(named: "RCRA Red")?.scaleImage(toSize: markerSize)
            case "SDWA":
                annotationView?.image = UIImage(named: "SDWA Red")?.scaleImage(toSize: markerSize)
            default:
                print("None Found")
            }
        }
        else if subtitleArray[0] == "Mid" {
            switch subtitleArray[2] {
            case "CAA":
                annotationView?.image = UIImage(named: "CAA Yellow")?.scaleImage(toSize: markerSize)
            case "CWA":
                annotationView?.image = UIImage(named: "CWA Yellow")?.scaleImage(toSize: markerSize)
            case "RCRA" :
                annotationView?.image = UIImage(named: "RCRA Yellow")?.scaleImage(toSize: markerSize)
            case "SDWA":
                annotationView?.image = UIImage(named: "SDWA Yellow")?.scaleImage(toSize: markerSize)
            default:
                print("None Found")
            }
        }
        else if subtitleArray[0] == "No" {
            switch subtitleArray[2] {
            case "CAA":
                annotationView?.image = UIImage(named: "CAA Green")?.scaleImage(toSize: markerSize)
            case "CWA":
                annotationView?.image = UIImage(named: "CWA Green")?.scaleImage(toSize: markerSize)
            case "RCRA" :
                annotationView?.image = UIImage(named: "RCRA Green")?.scaleImage(toSize: markerSize)
            case "SDWA":
                annotationView?.image = UIImage(named: "SDWA Green")?.scaleImage(toSize: markerSize)
            default:
                print("None Found")
            }
        }
        else if subtitleArray[0] == "Move" {
            annotationView?.image = UIImage(named: "EnviroLogo")?.scaleImage(toSize: markerSize)
            annotationView?.isDraggable = true
        }
        else if subtitleArray[0] == "Custom" {
            annotationView?.image = UIImage(named: "EnviroLogo")?.scaleImage(toSize: markerSize)
            annotationView?.isDraggable = false
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
            facID = String(subtitleArray[5])
            print(facID ?? "None")
            moreInfoButton.isEnabled = true
            switch subtitleArray[2] {
            case "CAA":
                playSound(soundName: "CAA")
            case "CWA":
                playSound(soundName: "CWA")
            case "RCRA" :
                playSound(soundName: "RCRA")
            case "SDWA":
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
        moreInfoButton.isEnabled = false
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
