//
//  FacViewController.swift
//  EnviOSearch
//
//  Created by HGS on 7/30/20.
//  Copyright © 2020 HGS. All rights reserved.
//
//https://ofmpub.epa.gov/echo/dfr_rest_services.get_dfr?output=JSON&p_id=110000368913

import UIKit
import GoogleMobileAds

class FacViewController: UIViewController {
    var facID:String?
    @IBOutlet weak var CAASwitch: UISwitch!
    @IBOutlet weak var CWASwitch: UISwitch!
    @IBOutlet weak var SDWASwitch: UISwitch!
    @IBOutlet weak var RCRASwitch: UISwitch!
    
    @IBOutlet weak var CAALabel: UILabel!
    @IBOutlet weak var CWALabel: UILabel!
    @IBOutlet weak var RCRALabel: UILabel!
    @IBOutlet weak var SDWALabel: UILabel!
    
    
    
    @IBOutlet weak var InspectionsLabel: UILabel!
    @IBOutlet weak var CurrentComplianceLabel: UILabel!
    @IBOutlet weak var LastInspectionLabel: UILabel!
    @IBOutlet weak var EPAPenaltiesLabel: UILabel!
    @IBOutlet weak var EPACasesLabel: UILabel!
    @IBOutlet weak var FormalActionPenaltyLabel: UILabel!
    @IBOutlet weak var FormalActionsLabel: UILabel!
    @IBOutlet weak var InformalActionsLabel: UILabel!
    @IBOutlet weak var QtrsWithSigNCLabel: UILabel!
    @IBOutlet weak var QtrsWithNCLabel: UILabel!
    
    @IBOutlet weak var FacilityNameLabel: UILabel!
    @IBOutlet weak var FacilityStreetCityLabel: UILabel!
    @IBOutlet weak var FacilityStateZip: UILabel!
    
    @IBOutlet weak var EPARegionLabel: UILabel!
    
    @IBOutlet weak var FacAdView: GADBannerView!
    
    var hasCAA = false
    var hasCWA = false
    var hasRCRA = false
    var hasSDWA = false
    
    var summaries: [Summaries]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        FacAdView.delegate = self
        
        //FacAdView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        FacAdView.adUnitID = "ca-app-pub-6391108766292407/4454510553"
        //facAd ID: "ca-app-pub-6391108766292407/4454510553"
        FacAdView.rootViewController = self
        FacAdView.load(GADRequest())
        
        //Get facility's info
        getFacJSON()
        
    }
    
    //When a switch is clicked, disable all other switches and call updateLabels
    
    @IBAction func CAAPressed(_ sender: Any) {
        CAASwitch.isOn = true
        CWASwitch.isOn = false
        RCRASwitch.isOn = false
        SDWASwitch.isOn = false
        
        //Populate page with CAA Data
        
        updateLabels(statute: "CAA")
    }
    @IBAction func CWAPressed(_ sender: Any) {
        CAASwitch.isOn = false
        CWASwitch.isOn = true
        RCRASwitch.isOn = false
        SDWASwitch.isOn = false
        
        //Populate page with CWA Data
        updateLabels(statute: "CWA")
    }
    @IBAction func SDWAPressed(_ sender: Any) {
        CAASwitch.isOn = false
        CWASwitch.isOn = false
        RCRASwitch.isOn = false
        SDWASwitch.isOn = true
        
        //Populate page with SDWA Data
        updateLabels(statute: "SDWA")
    }
    @IBAction func RCRAPressed(_ sender: Any) {
        CAASwitch.isOn = false
        CWASwitch.isOn = false
        RCRASwitch.isOn = true
        SDWASwitch.isOn = false
        
        //Populate page with RCRA Data
        updateLabels(statute: "RCRA")
    }
    
    //Send user to EPA page about current facility
    @IBAction func MoreInfoClicked(_ sender: Any) {
        let url = URL (string: "https://echo.epa.gov/detailed-facility-report?fid=\(facID ?? "0")")!
        UIApplication.shared.open(url)
    }
    
    @IBAction func ReportClicked(_ sender: Any) {
        let url = URL (string: "https://echo.epa.gov/report-environmental-violations")!
        UIApplication.shared.open(url)
    }
    
    //Get info for facility summary and store it in summaries array
    private func getFacJSON() {
        let myURL = "https://ofmpub.epa.gov/echo/dfr_rest_services.get_dfr?output=JSON&p_id=\(facID ?? "0")"
        print(myURL)
        let urlString = myURL
        guard let url = URL(string: urlString
            ) else {
            print("ERROR")
                return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, _, _) in
            guard let data = data else {
                print("DATA ERROR")
                return
            }
            do {
                print("Test")
                let resultSet = try JSONDecoder().decode(ResultSet.self, from: data)
                print(resultSet)
                self.summaries = resultSet.Results.EnforcementComplianceSummaries?.Summaries
                
                let facilityStreet = resultSet.Results.Permits?[0].FacilityStreet
                let facilityCity = resultSet.Results.Permits?[0].FacilityCity
                
                let facilityState = resultSet.Results.Permits?[0].FacilityState
                let facilityZip = resultSet.Results.Permits?[0].FacilityZip
                
                //Set EPA Region contact information
                DispatchQueue.main.async {
                    switch facilityState {
                        case "CT", "ME", "MA", "NH", "RI", "VT":
                            self.EPARegionLabel.text = "EPA Region 1: Boston - (617) 918-1010"
                        case "NJ", "NY", "Puerto Rico":
                            self.EPARegionLabel.text = "EPA Region 2: New York City - (212) 637-5000"
                        case "DE", "DC", "MD", "PA", "VA", "WV":
                            self.EPARegionLabel.text = "EPA Region 3: Philadelphia - (215) 814-5000"
                        case "AL", "FL", "GA", "KY", "MS", "NC", "SC", "TN":
                            self.EPARegionLabel.text = "EPA Region 4: Atlanta - (404) 562-9900"
                        case "IL", "IN", "MI", "MN", "OH", "WI":
                            self.EPARegionLabel.text = "EPA Region 5: Chicago - (312) 886-3000"
                        case "AR", "LA", "NM", "OK", "TX":
                            self.EPARegionLabel.text = "EPA Region 6: Dallas - (214) 665-2200"
                        case "IA", "KS", "MO", "NE":
                            self.EPARegionLabel.text = "EPA Region 7: Kansas City - (913) 551-7003"
                        case "CO", "MT", "ND", "SD", "UT", "WY":
                            self.EPARegionLabel.text = "EPA Region 8: Denver - (303) 312-6312"
                        case "AZ", "CA", "HI", "NV":
                            self.EPARegionLabel.text = "EPA Region 9: San Francisco - (415) 947-8700"
                        case "AK", "ID", "OR", "WA":
                            self.EPARegionLabel.text = "EPA Region 10: Seattle - (206) 553-1200"
                        default:
                            self.EPARegionLabel.text = "EPA Region: Not found"
                    }
                
                    //Set information about facility location
                    self.FacilityNameLabel.text = resultSet.Results.Permits?[0].FacilityName
                    self.FacilityStreetCityLabel.text = "\(facilityStreet ?? "") \(facilityCity ?? "")"
                    self.FacilityStateZip.text = "\(facilityState ?? "") \(facilityZip ?? "")"
                }
                
                self.disableUnusedStatutes()
                
                print("Before status")
                //print(facilityData?[0].CurrentStatus ?? "No Value")
            } catch let Jerr {
                print(Jerr)
            }
        }
        task.resume()
    }
    
    func disableUnusedStatutes() {
        if let mySums = summaries {
            for summary in mySums{
                switch summary.Statute {
                case "CAA":
                    hasCAA = true
                case "CWA":
                    hasCWA = true
                case "RCRA":
                    hasRCRA = true
                case "SDWA":
                    hasSDWA = true
                default:
                    print("Do nothing")
                }
            }
            
            if !hasCAA {
                print("Disable CAA")
                DispatchQueue.main.async {
                    self.CAALabel.textColor = UIColor.gray
                    self.CAASwitch.isEnabled = false
                }
            }
            if !hasCWA {
                print("Disable CWA")
                DispatchQueue.main.async {
                    self.CWALabel.textColor = UIColor.gray
                    self.CWASwitch.isEnabled = false
                }
                
            }
            if !hasRCRA {
                print("Disable RCRA")
                DispatchQueue.main.async {
                    self.RCRALabel.textColor = UIColor.gray
                    self.RCRASwitch.isEnabled = false
                }
                
            }
            if !hasSDWA {
                print("Disable SDWA")
                DispatchQueue.main.async {
                    self.SDWALabel.textColor = UIColor.gray
                    self.SDWASwitch.isEnabled = false
                }
                
            }
            
        }
    }
    
    //finds which index of summaries the statute corresponds to
    func findStatuteIndex(statute: String) -> Int? {
        var count = 0
        if let mySums = summaries {
            for summary in mySums {
                if summary.Statute == statute {
                    return count
                }
                count += 1
            }
        }
        
        return nil
    }
    
    //updates information about facility relating to selected statute
    func updateLabels(statute: String) {
        
        if let i = findStatuteIndex(statute: statute) {
            print(summaries?[i].Statute ?? "No value")
            InspectionsLabel.text = summaries?[i].Inspections ?? "-"
            LastInspectionLabel.text = summaries?[i].LastInspection ?? "-"
            CurrentComplianceLabel.text = summaries?[i].CurrentStatus ?? "-"
            QtrsWithNCLabel.text = summaries?[i].QtrsInNC ?? "-"
            QtrsWithSigNCLabel.text = summaries?[i].QtrsInSNC ?? "-"
            InformalActionsLabel.text = summaries?[i].InformalActions ?? "-"
            FormalActionsLabel.text = summaries?[i].FormalActions ?? "-"
            EPACasesLabel.text = summaries?[i].Cases ?? "-"
            FormalActionPenaltyLabel.text = summaries?[i].TotalPenalties ?? "-"
            EPAPenaltiesLabel.text = summaries?[i].TotalCasePenalties ?? "-"
            
            let QtrsInNC: Int = Int(summaries?[i].QtrsInNC ?? "0") ?? 0
            let QtrsInSNC: Int = Int(summaries?[i].QtrsInSNC ?? "0") ?? 0
            
            switch QtrsInNC {
            case 1...7:
                QtrsWithNCLabel.textColor = UIColor.orange
            case 7...12:
                QtrsWithNCLabel.textColor = UIColor.red
            default:
                QtrsWithNCLabel.textColor = UIColor.black
            }
            
            switch QtrsInSNC {
            case 1...7:
                QtrsWithSigNCLabel.textColor = UIColor.orange
            case 7...12:
                QtrsWithSigNCLabel.textColor = UIColor.red
            default:
                QtrsWithSigNCLabel.textColor = UIColor.black
            }
            
        }
        else {
            //Set all to -
            print("No value")
            InspectionsLabel.text = "-"
            LastInspectionLabel.text = "-"
            CurrentComplianceLabel.text = "-"
            QtrsWithNCLabel.text = "-"
            QtrsWithSigNCLabel.text = "-"
            InformalActionsLabel.text = "-"
            FormalActionsLabel.text = "-"
            EPACasesLabel.text = "-"
            FormalActionPenaltyLabel.text = "-"
            EPAPenaltiesLabel.text = "-"
            
        }
        
        
    }
    
}

extension FacViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Got it")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}
