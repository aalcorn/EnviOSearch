//
//  MoreInfoViewController.swift
//  EnviOSearch
//
//  Created by HGS on 7/16/20.
//  Copyright © 2020 HGS. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MoreInfoViewController: UIViewController {

    @IBOutlet weak var CAALabel: UILabel!
    @IBOutlet weak var SDWAButton: UIButton!
    @IBOutlet weak var CAAButton: UIButton!
    @IBOutlet weak var RCRAButton: UIButton!
    @IBOutlet weak var CWAButton: UIButton!
    @IBOutlet weak var moreInfoAdview: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        CAALabelSettings()
        
        moreInfoAdview.delegate = self
        
        //moreInfoAdview.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        moreInfoAdview.adUnitID = "ca-app-pub-6391108766292407/9351614012"
        //moreInfoAd ID: "ca-app-pub-6391108766292407/9351614012"
        moreInfoAdview.rootViewController = self
        moreInfoAdview.load(GADRequest())
    }
    
    //Settings for CAALabel. Others are done using storyboard.
    func CAALabelSettings() {
        CAALabel.numberOfLines = 0
        CAALabel.contentMode = .scaleToFill
        CAALabel.text = "In 1970, the Clean Air Act (CAA) established a mechanism of protection of human health and the environment throughout the United States. The CAA is a federal law that regulates air emissions from mobile and stationary sources (EPA, 2017). This act gives the United States Environmental Protection Agency (US EPA) authorization to establish the National Ambient Air Quality Standards (NAAQS)."
        CAALabel.sizeToFit()
    }
    
    //Button OnClick Listeners
    @IBAction func CWAClicked(_ sender: Any) {
        let url = URL (string: "https://www.epa.gov/laws-regulations/summary-clean-water-act")!
        UIApplication.shared.open(url)
    }
    
    @IBAction func CAAClicked(_ sender: Any) {
        let url = URL (string: "https://www.epa.gov/laws-regulations/summary-clean-air-act")!
        UIApplication.shared.open(url)    }
    
    
    @IBAction func RCRAClicked(_ sender: Any) {
        let url = URL (string: "https://www.epa.gov/rcra/resource-conservation-and-recovery-act-rcra-overview#whatisrcra")!
        UIApplication.shared.open(url)    }
    
    @IBAction func SDWAClicked(_ sender: Any) {
        let url = URL (string: "https://www.epa.gov/sites/production/files/2015-04/documents/epa816f04030.pdf")!
        UIApplication.shared.open(url)    }
    
}

extension MoreInfoViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Got it")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}
