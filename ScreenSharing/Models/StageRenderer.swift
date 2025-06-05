//
//  StageRenderer.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 07/05/2025.
//

import Foundation
import AmazonIVSBroadcast

class StageRenderer: UIView, ObservableObject, IVSStageRenderer {

    // Used in the views
    @Published var previews: [IVSImagePreviewView] = []
    @Published var connectionState: IVSStageConnectionState = .disconnected

    private let decoder = JSONDecoder()
    private var imageDevices: [String: IVSImageDevice] = [:] {
        didSet {
            // Update previews when image devices change
            do {
                previews.removeAll()
                for imgDevice in imageDevices {
                    let preview = try imgDevice.value.previewView(with: .fit)
                    previews.append(preview)
                }
            } catch {
                print("❌ got error when trying to get preview view from IVSImageDevice: \(error)")
            }
        }
    }

    func stage(_ stage: IVSStage, didChange connectionState: IVSStageConnectionState, withError error: Error?) {
        self.connectionState = connectionState
        print("ℹ️ Stage connection state changed: \(connectionState.toString())")

        if connectionState == .disconnected {
            imageDevices.removeAll()
        }
    }

    func stage(_ stage: IVSStage, participant: IVSParticipantInfo, didAdd streams: [IVSStageStream]) {
        streams.lazy.forEach { stream in
            if let imageDevice = stream.device as? IVSImageDevice {
                print("ℹ️ participant \(participant.userId) did add video stream: \(imageDevice.descriptor().urn)")
                let id = "\(participant.userId)_\(imageDevice.descriptor().urn)"
                imageDevices[id] = imageDevice
            } else {
                print("ℹ️ participant \(participant.userId) did add audio stream: \(stream)")
            }
        }
    }

    func stage(_ stage: IVSStage, participant: IVSParticipantInfo, didRemove streams: [IVSStageStream]) {
        print("ℹ️ participant \(participant.userId) did remove \(streams.count) streams")
        streams.lazy.forEach { stream in
            if let imageDevice = stream.device as? IVSImageDevice {
                let id = "\(participant.userId)_\(imageDevice.descriptor().urn)"
                imageDevices.removeValue(forKey: id)
                print("ℹ️ \(id) stream removed")
            }
        }
    }
}

extension IVSStageConnectionState {
    func toString() -> String {
        switch self {
            case .connected:
                return "Connected"
            case .disconnected:
                return "Disconnected"
            case .connecting:
                return "Connecting"
            @unknown default:
                return "Unknown"
        }
    }
}
