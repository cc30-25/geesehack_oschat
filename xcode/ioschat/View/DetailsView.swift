//
//  DetailsView.swift
//  ioschat
//
//  Created by cilo chou on 2025-01-25.
//

import SwiftUI

struct DetailsView: View {
    var userInput: String
    @State private var additionalDetails: [String: String] = [:]

    // Example questions for demonstration
    let questions = ["What is your budget?", "Who is the target audience?"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Details for: \(userInput)")
                .font(.title2)
                .padding()

            ForEach(questions, id: \.self) { question in
                TextField(question, text: Binding(
                    get: { additionalDetails[question] ?? "" },
                    set: { additionalDetails[question] = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            NavigationLink(destination: ResultsView(details: additionalDetails)) {
                Text("Generate Results")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }
}
