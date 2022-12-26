//
//  CalendarApp.swift
//  Calendar
//
//  Created by Albert Kong on 2022/12/25.
//

import SwiftUI

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        #if os(macOS)
            if #available(macOS 13.0, *) {
                return windowResizability(.contentSize)
            } else {
                return self
            }
        #else
            return self
        #endif
    }
}

@main
struct SecreteApp: App {
    var body: some Scene {
        WindowGroup{
            ContentView()
        }.windowResizabilityContentSize()
    }
}
