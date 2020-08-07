//
//  DispatchQueue+Extensions.swift.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/10/20.
//  Copyright © 2020 Interview. All rights reserved.
//
//  Found this template in the past from stackoverflow: https://stackoverflow.com/questions/24056205/how-to-use-background-thread-in-swift
//  Added my own modfications to it for other projects. For the sake of this take home, we only need these two.

import Foundation

typealias Dispatch = DispatchQueue

extension Dispatch {

    static func background(_ task: @escaping () -> ()) {
        Dispatch.global(qos: .background).async {
            task()
        }
    }

    static func main(_ task: @escaping () -> ()) {
        Dispatch.main.async {
            task()
        }
    }
}
