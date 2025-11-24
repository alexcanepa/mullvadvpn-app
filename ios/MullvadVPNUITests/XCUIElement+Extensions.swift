//
//  XCUIElement+Extensions.swift
//  MullvadVPNUITests
//
//  Created by Niklas Berglund on 2024-03-25.
//  Copyright © 2025 Mullvad VPN AB. All rights reserved.
//

import XCTest

extension XCUIElement {
    func scrollDownToElement(element: XCUIElement, maxScrolls: UInt = 5) {
        var count = 0
        while !element.isVisible && count < maxScrolls {
            swipeUp(velocity: .slow)
            count += 1
        }
    }

    func scrollUpToElement(element: XCUIElement, maxScrolls: UInt = 5) {
        var count = 0
        while !element.isVisible && count < maxScrolls {
            swipeDown(velocity: .slow)
            count += 1
        }
    }

    var isVisible: Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }

    /// Waits for element to exist and returns true if it does so within the specified time frame.
    /// - Parameters:
    ///     - timeout: Waiting time. Defaults to `Timeout.default`.
    ///     - description: String describing the reason for waiting.
    func existsAfterWait(
        timeout: Timeout = .default,
        description: String? = nil
    ) -> Bool {
        wait(
            for: .exists,
            timeout: timeout,
            failOnUnmetCondition: false,
            description: description
        ).exists
    }

    /// Waits for element to not exist and returns true if it doesn't within the specified time frame.
    /// - Parameters:
    ///     - timeout: Waiting time. Defaults to `Timeout.default`.
    ///     - description: String describing the reason for waiting.
    func notExistsAfterWait(
        timeout: Timeout = .default,
        description: String? = nil
    ) -> Bool {
        !wait(
            for: .notExists,
            timeout: timeout,
            failOnUnmetCondition: false,
            description: description
        ).exists
    }

    /// Waits for element to meet a certain condition within the specified time frame.
    /// - Parameters:
    ///     - condition: The condition to wait for. Defaults to `Condition.exists`.
    ///     - timeout: Waiting time. Defaults to `Timeout.default`.
    ///     - failOnUnmetCondition: If true, fails the test if the condition is not met.
    ///     - description: String describing the reason for waiting.
    /// - Note: It's preferred to use `existsAfterWait()`, `notExistsAfterWait()` or `tapWhenHittable()`
    /// to handle those respective specific scenarios.
    @discardableResult
    func wait(
        for condition: Condition = .exists,
        timeout: Timeout = .default,
        failOnUnmetCondition: Bool = true,
        description: String? = nil
    ) -> Self {
        let condition: (path: KeyPath<XCUIElement, Bool>, shouldExist: Bool) =
            switch condition {
            case .exists:
                (\.exists, true)
            case .notExists:
                (\.exists, false)
            case .hittable:
                (\.isHittable, true)
            }

        let exists = wait(for: condition.path, toEqual: condition.shouldExist, timeout: timeout.rawValue)

        if !exists && failOnUnmetCondition {
            XCTFail(description ?? "Element failed to meet condition '\(condition)'")
        }

        return self
    }

    /// Waits for element to be hittable and, if successful, taps it.
    /// - Parameters:
    ///     - timeout: Waiting time. Defaults to `Timeout.default`.
    ///     - failOnUnmetCondition: If true, fails the test if the condition is not met.
    ///     - description: String describing the reason for waiting.
    @discardableResult
    func tapWhenHittable(
        timeout: Timeout = .default,
        failOnUnmetCondition: Bool = true,
        description: String? = nil
    ) -> Self {
        if wait(
            for: .hittable,
            timeout: timeout,
            failOnUnmetCondition: failOnUnmetCondition,
            description: description
        ).isHittable {
            tap()
        } else if failOnUnmetCondition {
            XCTFail(description ?? "Failed to tap element after timeout")
        }

        return self
    }
}

// Borrowed and adapted from https://eng.wealthfront.com/2025/03/17/how-we-sped-up-ios-end-to-end-tests-by-over-50-with-40-lines-of-code/.
extension XCUIElement {
    enum Condition {
        case exists
        case notExists
        case hittable
    }

    enum Timeout: TimeInterval {
        case short = 1
        case `default` = 5
        case long = 15
        case veryLong = 20
        case extremelyLong = 180
    }

    @available(*, deprecated, message: "Use wait(for:timeout:failOnUnmetCondition:description)")
    func waitForExistence(timeout: TimeInterval) -> Bool {
        existsAfterWait(timeout: Timeout(rawValue: timeout) ?? .default)
    }

    @available(*, deprecated, message: "Use wait(for:timeout:failOnUnmetCondition:description)")
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        notExistsAfterWait(timeout: Timeout(rawValue: timeout) ?? .default)
    }
}
