//
//  TokenInputView.swift
//  ScreenSharing
//
//  Created by Uldis Zingis on 08/05/2025.
//

import SwiftUI

struct TokenInputView: View {
    @EnvironmentObject var appModel: AppModel

    @State var token: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let error = appModel.errorMessage {
                Text(error)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.opacity(0.2))
                    )
            }

            Text("Stage token:")
                .foregroundColor(.primary)
            TextEditor(text: $token)
                .autocorrectionDisabled()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.secondary)
                )

            Button {
                appModel.connectToStage()
            } label: {
                Text("Connect")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(.defaultLight)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.defaultDark.opacity(token.isEmpty ? 0.2 : 1))
                    )
            }
            .disabled(token.isEmpty)
        }
        .onAppear {
            appModel.token = token
        }
        .onChange(of: token) { _ in
            appModel.token = token
        }
        .padding()
    }
}
