//
//  SReachability.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/19/20.
//  Copyright © 2020 Interview. All rights reserved.
//


import Foundation
import Reachability

final class SReachability {
    private let reachability = try! Reachability()
    private var reachabilityStatus: Reachability.Connection = .unavailable
    
    static let shared = SReachability()
    
    var isNetworkAvailable: Bool {
        return reachabilityStatus != .unavailable
    }
    
    func startMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)

        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }

    func stopMonitoring() {
        reachability.stopNotifier()

        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    
    @objc private func reachabilityChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
        reachabilityStatus = reachability.connection
        print("reachabilityStatus: \(reachabilityStatus)")
    }
}
