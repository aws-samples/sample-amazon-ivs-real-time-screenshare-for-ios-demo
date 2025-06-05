//
//  ZoomableFullscreenPreviewView.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 13/05/2025.
//

import SwiftUI
import AmazonIVSBroadcast

struct ZoomableFullscreenPreviewView: View {
    let preview: IVSImagePreviewView

    private var videoWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    private var videoHeight: CGFloat {
        videoWidth * (9/16)
    }

    var body: some View {
        ZoomableContainer {
            IVSImagePreviewViewWrapper(previewView: preview)
                .frame(width: videoWidth, height: videoHeight)
        }
    }
}

struct ZoomableContainer<Content: View>: View {
    let content: Content

    @State private var scale: CGFloat = 1.0
    @State private var lastMagnificationValue: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastDragOffset: CGSize = .zero

    private let maxScale: CGFloat = 4.0
    private let minScale: CGFloat = 1.0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .scaleEffect(scale)
            .offset(offset)
            .gesture(combinedGestures)
            .onTapGesture(count: 2, perform: handleDoubleTap)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
    }

    var combinedGestures: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    let delta = value / lastMagnificationValue
                    var newScale = scale * delta
                    newScale = min(max(newScale, minScale), maxScale)
                    scale = newScale
                    lastMagnificationValue = value
                }
                .onEnded { _ in
                    lastMagnificationValue = 1.0
                },
            DragGesture()
                .onChanged { value in
                    offset = CGSize(
                        width: lastDragOffset.width + value.translation.width,
                        height: lastDragOffset.height + value.translation.height
                    )
                }
                .onEnded { _ in
                    lastDragOffset = offset
                }
        )
    }

    func handleDoubleTap() {
        withAnimation(.spring()) {
            if scale == 1.0 {
                scale = maxScale
            } else {
                scale = 1.0
                offset = .zero
                lastDragOffset = .zero
            }
        }
    }
}
