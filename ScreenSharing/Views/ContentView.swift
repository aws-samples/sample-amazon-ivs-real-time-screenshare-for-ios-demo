//
//  ContentView.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 07/05/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        if appModel.didTapConnect, let stageRenderer = appModel.stageRenderer {
            StageView()
                .environmentObject(stageRenderer)
        } else {
            TokenInputView()
        }
    }
}

#Preview {
    let appModel = AppModel()
    ContentView()
        .environmentObject(appModel)
}
