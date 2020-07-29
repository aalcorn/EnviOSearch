//
//  JSONResult.swift
//  EnviOSearch
//
//  Created by HGS on 7/27/20.
//  Copyright © 2020 HGS. All rights reserved.
//

import Foundation

struct ResultSet: Decodable {
    let Results: Results
}

struct Results: Decodable {
    let QueryRows: String
    let Facilities: [Facility]?
}

struct Facility: Decodable {
    let CAAComplianceStatus: String?
    let CWAComplianceStatus: String?
    let RCRAComplianceStatus: String?
    let SDWAComplianceStatus: String?
    let RegistryID: String
    let FacName: String
    let FacLat: String
    let FacLong: String
    let FacQtrsWithNC: String?
    
}
