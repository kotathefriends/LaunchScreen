//
//  OnboardingView.swift
//  LaunchScreen
//
//  Created by KOTA TAKAHASHI on 2024/05/14.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("オンボーディング画面")
                .font(.title)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("戻る")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
