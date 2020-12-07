//
//  JSONResult.swift
//  EnviOSearch
//
//  Created by HGS on 7/27/20.
//  Copyright © 2020 HGS. All rights reserved.
//

import Foundation

// FOR MAPS
struct ResultSet: Decodable {
    let Results: Results
}

//Two gets both have a "Results" with different parameters. Made some parameters optional to allow use of this struct for both calls.
struct Results: Decodable {
    let QueryRows: String?
    let Facilities: [Facility]?
    let EnforcementComplianceSummaries: EnforcementComplianceSummaries?
    let Permits: [Permits]?
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

// FOR FACILITY

struct EnforcementComplianceSummaries: Decodable {
    let Summaries: [Summaries]
}

struct Summaries: Decodable {
    let Statute: String
    let Inspections: String?
    let LastInspection: String?
    let CurrentStatus: String?
    let QtrsInNC: String?
    let QtrsInSNC: String?
    let InformalActions: String?
    let FormalActions: String?
    let Cases: String?
    let TotalPenalties: String?
    let TotalCasePenalties: String?
}

struct Permits: Decodable {
    let FacilityName: String
    let FacilityStreet: String
    let FacilityCity: String
    let FacilityState: String
    let FacilityZip: String
}

//Clean-up sites
struct CleanUpResultSet: Decodable {
    let data: [data]
}

//struct data: Decodable {
//    let info: [info]
//}

struct data: Decodable {
    let id: String
    let epaId: String
    let name: String
    let address: String
    let city: String
    let state: String
    let zip: String
    let congressDistrict: String
    let countyName: String
    let lat: String
    let long: String
}
