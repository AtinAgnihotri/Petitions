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
    let issues: [IssuesModel]
    let signatureThreshold: Int
    
    var allIssues: String {
        let seperator = ", "
        var allIssues = ""
        for each in issues {
            allIssues += each.name + seperator
        }
        allIssues = allIssues.replacingOccurrences(of: " &amp; ", with: seperator)
        allIssues = allIssues.trimmingCharacters(in: CharacterSet(charactersIn: seperator))
        return allIssues
    }
}
