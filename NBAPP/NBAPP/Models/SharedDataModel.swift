//
//  SharedDataModel.swift
//  NBAPP
//
//  Created by Raymond Kim on 4/10/24.
//

import Foundation

/*
 This class keep track of the selected team data so it can be accessed across multiple tab views
 Using the singleton design pattern by creating only one instance for global access
 */
class SharedDataModel {
    static let shared = SharedDataModel()
    var teamName: String?
    var teamId: String?
    private init() {}
}
