//
//  RecentListDataSource.swift
//  MullvadVPN
//
//  Created by Mojgan on 2025-11-18.
//  Copyright © 2025 Mullvad VPN AB. All rights reserved.
//

import Foundation
import MullvadLogging
import MullvadSettings
import MullvadTypes

class RecentListDataSource: LocationDataSourceProtocol {
    private(set) var nodes = [LocationNode]()
    private let logger = Logger(label: "RecentListDataSource")

    func reload(
        allLocationNodes: [LocationNode], customListNodes: [CustomListLocationNode], recents: [UserSelectedRelays]
    ) {
        self.nodes = recents.map({
            customListNode(in: customListNodes, for: $0) ?? relayNode(in: allLocationNodes, for: $0)
        }).compactMap({ $0 })
    }

    private func customListNode(in customListNodes: [CustomListLocationNode], for selectedRelays: UserSelectedRelays)
        -> LocationNode?
    {
        // Look for a matching custom list node.
        if let customListSelection = selectedRelays.customListSelection {
            return customListNodes.first { node in
                node.asCustomListNode?.customList.id == customListSelection.listId
            }
        }
        return nil
    }

    private func relayNode(in allLocationNodes: [LocationNode], for selectedRelays: UserSelectedRelays) -> LocationNode?
    {
        // Look for a matching node.
        if let location = selectedRelays.locations.first
        {
            let rootNode = RootLocationNode(children: allLocationNodes)
            let descendantNodeFor: ([String]) -> LocationNode? = { codes in
                switch location {
                case let .country(countryCode):
                    rootNode.descendantNodeFor(codes: codes + [countryCode])
                case let .city(countryCode, cityCode):
                    rootNode.descendantNodeFor(codes: codes + [countryCode, cityCode])
                case let .hostname(_, _, hostCode):
                    rootNode.descendantNodeFor(codes: codes + [hostCode])
                }
            }
            return descendantNodeFor([])
        }
        return nil
    }
}
