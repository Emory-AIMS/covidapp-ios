//
//  Parser.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 14/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation


public class Parser: NSObject {
    public static func jsonObject(from data: Data?) -> AnyObject? {
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                return json as AnyObject?
            } catch {
                print("Error serializing JSON: \(error)")
            }
        }
        return nil
    }
}
