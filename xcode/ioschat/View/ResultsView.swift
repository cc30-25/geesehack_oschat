//
//  ResultsView.swift
//  ioschat
//
//  Created by cilo chou on 2025-01-25.
//

import SwiftUI

struct ResultsView: View {
    var details: [String: String] // Input details passed from the DetailsView

    @State private var generatedResult: String = "Generating results..."

    var body: some View {
        VStack(spacing: 20) {
            Text("Your Results")
                .font(.title)
                .padding()

            ScrollView {
                Text(generatedResult)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button("Regenerate") {
                generateResult()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .onAppear {
            generateResult()
        }
    }

    private func generateResult() {
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            generatedResult = "Results based on: \(details)"
        }
    }
}
