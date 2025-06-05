//
//  ScreenSharingApp.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 07/05/2025.
//

import SwiftUI

@main
struct ScreenSharingApp: App {
    @StateObject var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
    }
}
