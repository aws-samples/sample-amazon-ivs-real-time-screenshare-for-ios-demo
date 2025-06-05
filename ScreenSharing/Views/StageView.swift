//
//  StageView.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 08/05/2025.
//

import SwiftUI

struct StageView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var stageRenderer: StageRenderer

    @State var isWatching: Bool = true
    @State private var isFullscreenPreviewPresented: Bool = false

    var body: some View {
        VStack(spacing: 36) {
            HStack {
                Button {
                    appModel.disconnect()
                    appModel.didTapConnect = false
                } label: {
                    Text("← Leave stage")
                        .foregroundColor(appModel.isScreensharingStarted ? .gray : .defaultDark)
                }
                .foregroundColor(.primary)
                .disabled(appModel.isScreensharingStarted)
                Spacer()
            }

            HStack {
                Text("Connection state:")
                    .foregroundColor(.primary)
                Spacer()
                if appModel.isScreensharingStarted {
                    Text("CONNECTED")
                        .foregroundColor(.secondary)
                } else {
                    Text(stageRenderer.connectionState.toString().uppercased())
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 0) {
                Button {
                    isWatching = true
                } label: {
                    Text("Watch")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundColor(isWatching ? .defaultLight : .defaultDark)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isWatching ? Color.defaultDark : Color.defaultLight)
                        )
                }
                .disabled(appModel.isScreensharingStarted)

                Button {
                    isWatching = false
                } label: {
                    Text("Screenshare")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundColor(isWatching ? .defaultDark : .defaultLight)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isWatching ? Color.defaultLight : Color.defaultDark)
                        )
                }
            }
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.defaultDark)
            )

            if isWatching {
                RendererPreviewView()
            } else {
                ScreensharingView()
            }
        }
        .frame(alignment: .top)
        .padding()
        .onChange(of: appModel.isScreensharingStarted) { newValue in
            if newValue {
                appModel.leaveStage()
                isWatching = false
            } else {
                appModel.connectToStage()
            }
        }
        .sheet(isPresented: $isFullscreenPreviewPresented, onDismiss: {
            appModel.fullscreenPreview = nil
        }, content: {
            if let fullscreenPreview = appModel.fullscreenPreview {
                ZoomableFullscreenPreviewView(preview: fullscreenPreview)
            }
        })
        .onChange(of: appModel.fullscreenPreview) { newValue in
            isFullscreenPreviewPresented = newValue != nil
        }
    }
}
