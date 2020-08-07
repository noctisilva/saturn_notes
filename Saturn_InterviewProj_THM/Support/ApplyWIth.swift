//
//  ApplyWIth.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/9/20.
//  Copyright © 2020 Interview. All rights reserved.
//
// Idea from Kotlin

import Foundation

public protocol ApplyProtocol { }

extension NSObject: ApplyProtocol { }

public extension ApplyProtocol {
    @discardableResult func apply(_ closure: (Self) throws -> Void) rethrows -> Self {
        try closure(self)
        return self
    }
}
