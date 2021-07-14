//
//  PetitionModel.swift
//  Petitions
//
//  Created by Atin Agnihotri on 14/07/21.
//

import Foundation

struct PetitionModel: Codable {
    let title: String
    let body: String
    let issues: [String]
    let signatureThreshold: Int
}
