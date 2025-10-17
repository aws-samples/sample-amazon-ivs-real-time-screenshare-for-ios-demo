//
//  SampleHandler.swift
//  ReplayKitBroadcaster
//
//  Created by Uldis Zingis on 08/05/2025.
//

import AmazonIVSBroadcast
import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {
    private var stage: IVSStage?
    private let userDefaults = UserDefaults(suiteName: Constants.appGroupName)

    private var shouldPublish: Bool = false

    private var token: String
    // Video
    private var customImageSource: IVSCustomImageSource
    private var videoStream: IVSLocalStageStream
    // Audio
    private var customAudioSource: IVSCustomAudioSource
    private var audioStream: IVSLocalStageStream
    // Microphone
    private var customMicSource: IVSCustomAudioSource
    private var micStream: IVSLocalStageStream

    private var videoSize: CGSize {
        let maxHeight: CGFloat = 720.0

        var width = UIScreen.main.bounds.width
        var height = UIScreen.main.bounds.height
        let aspectRatio = width / height

        if height > maxHeight {
            height = maxHeight
            width = height * aspectRatio
        }

        return CGSize(width: width, height: height)
    }

    override init() {
        // Prepare the video stream which gets published in the stage
        customImageSource = IVSDeviceDiscovery().createImageSource(withName: "screenshareVideo")
        videoStream = IVSLocalStageStream(device: customImageSource)

        // Prepare the audio stream which gets published in the stage
        customAudioSource = IVSDeviceDiscovery().createAudioSource(withName: "screenshareAudio")
        audioStream = IVSLocalStageStream(device: customAudioSource)

        // Prepare the audio stream which gets published in the stage
        customMicSource = IVSDeviceDiscovery().createAudioSource(withName: "screenshareMic")
        micStream = IVSLocalStageStream(device: customAudioSource)

        // Get the token from user defaults
        token = userDefaults?.string(forKey: Constants.kToken) ?? ""

        super.init()

        do {
            // Configuration for the stream
            let config = IVSLocalStageStreamConfiguration()
            try config.video.setTargetFramerate(30)
            try config.video.setSize(videoSize)
            config.video.degradationPreference = .balanced
            config.video.simulcast.enabled = true
            videoStream.setConfig(config)
        } catch {
            NSLog("❌ Could not configure the stream: \(error)")
        }
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        startStream()
    }

    override func broadcastFinished() {
        // User has requested to finish the broadcast
        print("ℹ️ 🖥️ Stopping stream and leaving stage...")
        let semaphore = DispatchSemaphore(value: 0)

        stopStreamAndLeave {
            print("✅ 🖥️ Stream stopped and stage left")
            semaphore.signal()
        }

        let timeoutResult = semaphore.wait(timeout: .now() + 5.0)
        if timeoutResult == .timedOut {
            print("⚠️ 🖥️ Stopping stream and leaving stage timed out")
        } else {
            print("✅ 🖥️ Exiting broadcastFinished successfully")
        }
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
            case .video:
                if let orientationAttachment = CMGetAttachment(sampleBuffer,
                                                                key: RPVideoSampleOrientationKey as CFString,
                                                                attachmentModeOut: nil) as? NSNumber
                {
                    // Set proper rotation for streamed image
                    let orientation = CGImagePropertyOrientation(rawValue: orientationAttachment.uint32Value)
                    switch orientation {
                        case .right:
                            customImageSource.setHandsetRotation(-(Float.pi / 2))
                        case .left:
                            customImageSource.setHandsetRotation((Float.pi / 2))
                        default:
                            customImageSource.setHandsetRotation(0)
                    }
                }
                customImageSource.onSampleBuffer(sampleBuffer)

            // Currently Stage supports only 1 source per media
            // so you have to choose audioApp or audioMic
            // until mixing audio sources together in Stages becomes available
            case .audioApp:
                customAudioSource.onSampleBuffer(sampleBuffer)
            case .audioMic:
                customMicSource.onSampleBuffer(sampleBuffer)

            @unknown default:
                NSLog("❌ 🖥️ Unknown RPSampleBufferType: \(sampleBufferType)")
        }
    }

    private func startStream() {
        print("ℹ️ 🖥️ Staring replay kit stream...")
        do {
            stage = try IVSStage(token: token, strategy: self)
            try stage?.join()
            stage?.addRenderer(self)

            // Notify app through user defaults that session started
            userDefaults?.setValue(true, forKey: Constants.kReplayKitSessionHasBeenStarted)
        } catch {
            NSLog("❌ 🖥️ Failed to join stage: \(error.localizedDescription)")
            userDefaults?.setValue(false, forKey: Constants.kReplayKitSessionHasBeenStarted)
        }
    }

    private func stopStreamAndLeave(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            print("ℹ️ 🖥️ stopping replay kit stream")

            // Update stage strategy
            self.shouldPublish = false
            self.stage?.refreshStrategy()

            // Notify app through user defaults that session ended
            self.userDefaults?.setValue(false, forKey: Constants.kReplayKitSessionHasBeenStarted)

            self.stage?.leave()
            self.stage = nil

            Thread.sleep(forTimeInterval: 1.5)

            completion()
        }
    }
}

extension SampleHandler: IVSStageStrategy {
    func stage(_ stage: IVSStage, streamsToPublishForParticipant participant: IVSParticipantInfo) -> [IVSLocalStageStream] {
        return [videoStream, audioStream, micStream]
    }

    func stage(_ stage: IVSStage, shouldPublishParticipant participant: IVSParticipantInfo) -> Bool {
        return true
    }

    func stage(_ stage: IVSStage, shouldSubscribeToParticipant participant: IVSParticipantInfo) -> IVSStageSubscribeType {
        return .none
    }
}

extension SampleHandler: IVSStageRenderer {
    func stage(_ stage: IVSStage, didChange connectionState: IVSStageConnectionState, withError error: (any Error)?) {
        print("ℹ️ 🖥️ Replay kit stage connection state changed: \(connectionState.rawValue)")

        if let error = error {
            print("❌ 🖥️ Replay kit stage connection error: \(error)")
            userDefaults?.setValue(error.localizedDescription, forKey: Constants.kReplayKitSessionError)
        }
    }
}
