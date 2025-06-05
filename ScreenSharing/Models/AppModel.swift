//
//  AppModel.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 07/05/2025.
//

import SwiftUI
import AmazonIVSBroadcast
import ReplayKit

class AppModel: NSObject, ObservableObject {
    var stage: IVSStage?
    var stageRenderer: StageRenderer?

    @Published var didTapConnect: Bool = false
    @Published var fullscreenPreview: IVSImagePreviewView?

    var token: String = "" {
        didSet {
            userDefaults.set(token, forKey: Constants.kToken)
        }
    }
    @Published var errorMessage: String?

    let broadcastPicker = RPKitPickerView()
    let userDefaults = UserDefaults(suiteName: Constants.appGroupName) ?? UserDefaults.standard

    @Published private(set) var isScreensharingStarted: Bool = false
    @Published private(set) var replayKitStageError: String?

    private let decoder = JSONDecoder()

    override init() {
        // Cleanup if the app was suspended while screen sharing was still active
        userDefaults.setValue(false, forKey: Constants.kReplayKitSessionHasBeenStarted)
        token = userDefaults.string(forKey: Constants.kToken) ?? ""

        super.init()

        observeUserDefaultChanges()
    }

    deinit {
        userDefaults.removeObserver(self, forKeyPath: Constants.kReplayKitSessionHasBeenStarted)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        // Update app's state on isScreensharingStarted change
        self.isScreensharingStarted = self.userDefaults.bool(forKey: Constants.kReplayKitSessionHasBeenStarted)
        // Notify user on replay kit's stage error
        self.replayKitStageError = self.userDefaults.string(forKey: Constants.kReplayKitSessionError)
    }

    func observeUserDefaultChanges() {
        // Add user defaults observers
        userDefaults.addObserver(
            self,
            forKeyPath: Constants.kReplayKitSessionHasBeenStarted,
            options: [.initial],
            context: nil)
        userDefaults.addObserver(
            self,
            forKeyPath: Constants.kReplayKitSessionError,
            options: [.initial],
            context: nil)
    }

    func connectToStage() {
        errorMessage = nil

        guard !token.isEmpty else {
            print("❌ token not set!")
            errorMessage = "Token not set!"
            return
        }

        do {
            print("ℹ️ Connecting to watch stage...")
            stage = try IVSStage(token: token, strategy: self)
            try stage?.join()
            let renderer = StageRenderer()
            stage?.addRenderer(renderer)
            stageRenderer = renderer
            didTapConnect = true
        } catch {
            print("❌ Failed to join watch stage with token: \(token)")
            print("❌ Error: \(error)")
            errorMessage = "\(error.localizedDescription)"
        }
    }

    func leaveStage() {
        print("ℹ️ Leaving watch stage...")
        stage?.leave()
        stage = nil
    }

    func disconnect() {
        print("ℹ️ Disconnecting...")
        leaveStage()
        stageRenderer?.connectionState = .disconnected
        stageRenderer = nil
        token = ""
    }

    func toggleReplayKitPicker() {
        // Open native ReplayKit controls view
        broadcastPicker.toggleView()
    }
}

extension AppModel: IVSStageStrategy {
    func stage(_ stage: IVSStage, streamsToPublishForParticipant participant: IVSParticipantInfo) -> [IVSLocalStageStream] {
        return []
    }

    func stage(_ stage: IVSStage, shouldPublishParticipant participant: IVSParticipantInfo) -> Bool {
        return false
    }

    func stage(_ stage: IVSStage, shouldSubscribeToParticipant participant: IVSParticipantInfo) -> IVSStageSubscribeType {
        // No need to subscribe to any when screensharing is active
        return isScreensharingStarted ? .none : .audioVideo
    }
}
