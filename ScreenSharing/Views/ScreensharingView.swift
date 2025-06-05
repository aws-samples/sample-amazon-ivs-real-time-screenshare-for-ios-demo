//
//  ScreensharingView.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 13/05/2025.
//

import SwiftUI

struct ScreensharingView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                HStack {
                    Text("Sharing screen to stage:")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(String(appModel.isScreensharingStarted).uppercased())
                        .foregroundColor(.secondary)
                }

                Button {
                    appModel.toggleReplayKitPicker()
                } label: {
                    Text("Toggle screensharing")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(.defaultLight)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.defaultDark)
                        )
                }

                if let error = appModel.replayKitStageError {
                    Text("Error in replay kit stage session: \(error)")
                        .foregroundColor(.red)
                }
            }
        }
    }
}
