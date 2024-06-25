//
//  OnboardingView.swift
//  LaunchScreen
//
//  Created by KOTA TAKAHASHI on 2024/05/14.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("オンボーディング画面")
                    .font(.title)
                
                Button(action: {
                    withAnimation {
                        showOnboarding = false
                    }
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
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
