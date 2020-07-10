//
//  APIManager.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

public struct APIManager {
    
    // MARK: Computed Properties
    
    static let defaultJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    // MARK: Debug Functions
    
    private static func willSend(request: URLRequest) {
        #if DEBUG
        print(request.cURLRepresentation())
        if let body = request.httpBody {
            print("Request body: ")
            print(Parser.jsonObject(from: body) ?? "")
        }
        #endif
    }

    private static func didReceive(jsonData: Data) {
        #if DEBUG
        let response = Parser.jsonObject(from: jsonData)
        print(response as Any)
        #endif
    }
    
    // MARK: Request Functions

    static func executeDataRequest<T: URLRequestConvertible>(
        request: T,
        shouldCache: Bool = false,
        success: @escaping (Data) -> Void,
        failure: @escaping (Error) -> Void) {

        execute(request: request, shouldCache: shouldCache, success: { data in
            success(data)
        },
                failure: failure, authenticationAlreadyFailed: false)
    }

    static func executeResponseRequest<Response: Decodable, T: URLRequestConvertible>(
        request: T,
        jsonDecoder: JSONDecoder = defaultJSONDecoder,
        shouldCache: Bool = false,
        success: @escaping (Response) -> Void,
        failure: @escaping (Error) -> Void) {

        execute(request: request, shouldCache: shouldCache, success: { data in
            do {
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try jsonDecoder.decode(Response.self, from: data)
                success(decoded)
            } catch let error {
                failure(error)
            }
        }, failure: failure, authenticationAlreadyFailed: false)
    }

    static func executeResultRequest<Response: Decodable, T: URLRequestConvertible>(
        request: T,
        jsonDecoder: JSONDecoder = defaultJSONDecoder,
        shouldCache: Bool = false,
        completion: @escaping (Result<Response, Error>) -> Void) {

        execute(request: request, shouldCache: shouldCache, success: { data in
            do {
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try jsonDecoder.decode(Response.self, from: data)
                completion(.success(decoded))
            } catch let error {
                completion(.failure(error))
            }
        }, failure: { error in
            completion(.failure(error))
        })
    }
    
    // MARK: Core
    
    private static func execute<T: URLRequestConvertible>(
        request: T,
        shouldCache: Bool = false,
        success: @escaping (Data) -> Void,
        failure: @escaping (Error) -> Void,
        authenticationAlreadyFailed: Bool = false) {

        let onSuccess: (Data) -> Void = { jsonData in
            didReceive(jsonData: jsonData)
            success(jsonData)
        }

        do {
            var urlRequest = try request.createUrlRequest()
            urlRequest.timeoutInterval = 30
            willSend(request: urlRequest)

            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                // TODO: Remove main dispatch for background requests, or use another function to perform background requests
                DispatchQueue.main.async {
                    guard let response = response as? HTTPURLResponse else {
                        return failure(checkConnectionError(error))
                    }

                    guard let jsonData = data else {
                        return failure(NetworkingError.noResponseData)
                    }

                    switch response.statusCode {
                    case 200...300:
                        onSuccess(jsonData)
                    case 401, 402:
                        // TODO: Find out if we need to parse the error message
                        failure(NetworkingError.generalError)
                    default:
                        // TODO: Find out if we need to parse the error message
                        failure(NetworkingError.generalError)
                    }
                }
            }
            task.resume()

        } catch let error {
            failure(error)
            return
        }
    }

    private static func checkConnectionError(_ error: Error?) -> Error {
        guard let error = error else { return NetworkingError.unknown }

        switch (error as NSError).code {
        case NSURLErrorTimedOut, NSURLErrorNotConnectedToInternet:
            return NetworkingError.timeOut
        default:
            return NetworkingError.unknown
        }
    }
}
