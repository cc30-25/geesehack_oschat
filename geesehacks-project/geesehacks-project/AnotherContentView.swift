//
//  AnotherContentView.swift
//  geesehacks-project
//
//  Created by Qingyuan Rick Li on 2025-01-26.
//

import SwiftUI

struct AnotherContentView: View {
    var body: some View {
        NavigationStack{
            // Logo
            VStack {
                Image(systemName: "mic")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Welcome to gooseAd")
            }
            .padding()
            
            // Button to proceed
            NavigationLink(destination: TalkToVoiceFlow()) {
                Text("Inspire!")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}
    
#Preview {
    ContentView()
}
