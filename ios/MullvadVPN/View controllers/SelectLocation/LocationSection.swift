//
//  LocationSection.swift
//  MullvadVPN
//
//  Created by Mojgan on 2024-02-05.
//  Copyright © 2025 Mullvad VPN AB. All rights reserved.
//

import Foundation

enum LocationSection: String, Hashable, CaseIterable, CellIdentifierProtocol, Sendable {
    case recents
    case customLists
    case allLocations

    var header: String {
        switch self {
        case .recents:
            NSLocalizedString("Recents", comment: "")
        case .customLists:
            NSLocalizedString("Custom lists", comment: "")
        case .allLocations:
            NSLocalizedString("All locations", comment: "")
        }
    }

    var footer: String {
        switch self {
        case .recents:
            NSLocalizedString("No recent selection history.", comment: "")
        case .customLists:
            NSLocalizedString("To create a custom list, tap on \"...\" ", comment: "")
        case .allLocations:
            NSLocalizedString("No matching relays found, check your filter settings.", comment: "")
        }
    }

    var cellClass: AnyClass {
        LocationCell.self
    }
}
