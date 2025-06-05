//
//  RendererPreviewView.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 07/05/2025.
//

import SwiftUI
import AmazonIVSBroadcast

struct RendererPreviewView: View {
    @EnvironmentObject var stageRenderer: StageRenderer

    var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(stageRenderer.previews, id: \.self) { preview in
                    SmallPreviewView(preview: preview)
                }
            }
        }
        .opacity(stageRenderer.connectionState == .connected ? 1 : 0)
    }
}
