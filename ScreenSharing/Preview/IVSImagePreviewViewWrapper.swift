//
//  IVSImagePreviewViewWrapper.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 07/05/2025.
//

import SwiftUI
import AmazonIVSBroadcast

struct IVSImagePreviewViewWrapper: UIViewRepresentable {
    let previewView: IVSImagePreviewView?

    func makeUIView(context: Context) -> IVSImagePreviewView {
        guard let view = previewView else {
            fatalError("No actual IVSImagePreviewView passed to wrapper")
        }
        return view
    }

    func updateUIView(_ uiView: IVSImagePreviewView, context: Context) {}
}
