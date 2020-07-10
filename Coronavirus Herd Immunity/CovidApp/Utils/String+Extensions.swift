//
//  String+Extensions.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 23/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
extension String {
    func addingDashes() -> String {
        var result = ""
        for (offset, character) in characters.enumerated() {
            if offset != 0 && offset % 2 == 0 {
                result.append("-")
            }
            result.append(character)
        }
        return result
    }
}
