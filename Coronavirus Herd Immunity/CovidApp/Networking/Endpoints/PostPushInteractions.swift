//
//  PostPushInteractions.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

extension Endpoints {

    struct PostPushInteractions: PostRequest, BodyRequest {
        var path: String { return "/interaction/report" }
        let body: Body
    }
}

extension Endpoints.PostPushInteractions {
    
    struct Body: Codable {
        /// i for iOS
        let p: String
        /// version of the app
        let v : Int
        /// id of this device
        let i: Int
        let z: [Interaction]
    }
    
    struct Interaction: Codable {
        /// id of the interacted device
        let o: Int64
        /// unix time expressed in seconds
        let w: Int64
        /// time of interaction, default is 10
        let t: Int
        /// longitude
        let x: String?
        /// latitude
        let y: String?
        /// rssi value
        let r: Int64
        /// one of {‘i’, ‘n’, ‘f’} (immediate, near, far)
        let d: String
        /// distance in meters
        let s: String
    }
    
    struct Response: Codable {
        let nextTry: TimeInterval?
        let location: Bool?
        let excludeFar: Bool?
        let data: String?
        let distanceFilter: Double?
    }
}

extension APIManager {
    static func pushInteractions(_ interactions : [IBeaconDto], completion: @escaping (Result<Endpoints.PostPushInteractions.Response, Error>) -> Void) {
        
        let interactions = interactions.map { (interaction) -> Endpoints.PostPushInteractions.Interaction in
            
            var distance = "f"
            if interaction.distance == 1 {
                distance = "i"
            }
            if interaction.distance == 2 {
                distance = "n"
            }
            
            return Endpoints.PostPushInteractions.Interaction(o: interaction.identifier,
                                                              w: Int64(interaction.timestamp.timeIntervalSince1970),
                                                              t: Int(interaction.interval),
                                                              x: interaction.lon.isZero ? nil : Utils.roundToDecimals(interaction.lon, digits: 5),
                                                              y: interaction.lon.isZero ? nil : Utils.roundToDecimals(interaction.lat, digits: 5),
                                                              r: abs(interaction.rssi),
                                                              d: distance,
                                                              s: Utils.roundToDecimals(interaction.accuracy, digits: 1))
        }
        
        let request = Endpoints.PostPushInteractions(body: .init(p: "i",
                                                                 v: Constants.Setup.version,
                                                                 i: StorageManager.shared.getIdentifierDevice()!,
                                                                 z: interactions))
        
        executeResultRequest(request: request, completion: completion)
    }
}
