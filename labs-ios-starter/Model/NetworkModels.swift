//
//  NetworkModels.swift
//  labs-ios-starter
//
//  Created by Jarren Campos on 2/15/21.
//  Copyright © 2021 Spencer Curtis. All rights reserved.
//

import Foundation

struct Walkability: Codable {
    let walk_score: Int
    let walk_message: String
    let transit_score: Int?
    let bike_score: Int
}

struct ForRent: Codable {
    let address: Address
    let community: Community
}

struct Community: Codable {
    let price_max: Int
}

struct ForSale: Codable {
    let address: Address
    let price: Double
}

struct Address: Codable {
    let line: String
    let lat: Double
    let lon: Double
}