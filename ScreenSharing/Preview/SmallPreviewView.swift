//
//  SmallPreviewView.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 13/05/2025.
//

import SwiftUI
import AmazonIVSBroadcast

struct SmallPreviewView: View {
    @EnvironmentObject var appModel: AppModel

    let preview: IVSImagePreviewView

    @State private var isPresent: Bool = true

    private var videoWidth: CGFloat {
        UIScreen.main.bounds.width - 40
    }

    private var videoHeight: CGFloat {
        videoWidth * (9/16)
    }

    var body: some View {
        VStack {
            if isPresent {
                IVSImagePreviewViewWrapper(previewView: preview)
                    .frame(width: videoWidth, height: videoHeight)
                    .cornerRadius(20)
                    .onTapGesture {
                        appModel.fullscreenPreview = preview
                    }
            }
        }
        .onChange(of: appModel.fullscreenPreview) { newValue in
            isPresent = newValue == nil
        }
    }
}
