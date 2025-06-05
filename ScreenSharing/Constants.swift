//
//  Constants.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 08/05/2025.
//

import SwiftUI

enum Constants {
    // For screen sharing to work, this must match actual App Group container name
    // This is used to share user defaults between app and extension
    static let appGroupName = "group.com.ivs.broadcast"

    // Persistence keys for sharing data between app and extension
    static let kToken = "token"
    static let kReplayKitSessionHasBeenStarted = "replay_kit_session_has_been_started"
    static let kReplayKitSessionError = "replay_kit_session_error"
}
