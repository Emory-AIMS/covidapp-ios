//
//  NetworkingError.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

indirect enum NetworkingError: Error {
    case notAuthorized
    case timeOut
    case serverError
    case generalError
    case couldntCreateUrl
    case tokenExpired
    case unknown
    case noResponseData
    case invalidInput(String)
    case networking(error: NetworkingError, additionalInfo: [String: Any])
}
