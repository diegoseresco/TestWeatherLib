//
//  Wibd.swift
//  garrigues
//
//  Created by Diego Salcedo on 10/09/22.
//  Copyright © 2022 Seresco. All rights reserved.
//

import Foundation

struct Wind: Codable {
    let direction: String
    let period: String?
    let velocity: Int

    enum CodingKeys: String, CodingKey {
       case direction = "direccion"
       case period = "periodo"
       case velocity = "velocidad"
     }
}

extension Wind {
    var directionName: String {
        switch self.direction {
        case "O":
            return "Oeste"
        case "E":
            return "Este"
        case "S":
            return "Sur"
        case "N":
            return "Norte"
        case "SE":
            return "Sudeste"
        case "SO":
            return "Sudoeste"
        case "NE":
            return "Noreste"
        case "NO":
            return "Noroeste"
        case "C":
            return "Centro"
        default:
            return "Centro"
        }
    }
}
