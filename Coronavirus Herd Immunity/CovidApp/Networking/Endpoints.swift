//
//  Endpoints.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

public struct Endpoints {
//    static let defaultHost = "https://api.coronaviruscheck.org"
    static let defaultHost = "http://ec2-52-53-189-28.us-west-1.compute.amazonaws.com"
}

extension URLRequestConvertible {

    var host: String {
        return Endpoints.defaultHost
    }

    var defaultHeaderValues: [String: String]? {
        return ["Content-Type": "application/json",
                "Accept": "application/json"]
    }
    
    var headerValues: [String: String]? {
        if let token = SessionHelper.shared.retrieveToken() {
            return ["Authorization": "Bearer \(token)",
            "Content-Type": "application/json"]
        }
        return nil
    }
}
