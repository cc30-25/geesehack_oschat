//
//  TalkToVoiceFlow.swift
//  geesehacks-project
//
//  Created by Qingyuan Rick Li on 2025-01-26.
//

import SwiftUI
import Speech
import Foundation

struct TalkToVoiceFlow: View {
    @State private var VoiceFlowKey: String = "VF.DM.6795474c2be6dc21af31f2bf.ID1gLdaM9BsSZ4IK"
    @State private var VoiceFlowText: String = "I COME FROM VOICE FLOW"
    @State private var RecognizedText: String = ""
    @State private var UserText: String = ""
    
    @State private var Recording: Bool = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                // Read from voice flow
                Text(VoiceFlowText)
                    .font(.largeTitle)
                    .padding()
                
                // Recognized text (audio input)
                Text("We're hearing: \(RecognizedText)")
                    .padding()
                    .foregroundColor(.gray)
                
                // Button to record
                // LATER
                
                // Typed text (text input)
                TextField("Response here...", text: $UserText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Button to send
                Button(action: {
                    Task{
                        // actions go here
                        //VoiceFlowText = "bruh"
                        
                        // send the user input to the api
                        
                        // update voiceflow text based on output
                        VoiceFlowText = await SendAndReceive(GivenInput: UserText)
                        
                        // Reset user text
                        UserText = ""
                    }
                }){
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                }
            }
            
            // Button and continue
        }
    }
    
    // Talking to voiceflow
    func SendAndReceive(GivenInput: String) async -> String {
        // Make url
        let url = URL(string: "https://general-runtime.voiceflow.com/state/user/2/interact")!
        
        // Initialize request
        var apiRequest = URLRequest(url: url)
        apiRequest.httpMethod = "POST"
        apiRequest.addValue(VoiceFlowKey, forHTTPHeaderField: "Authorization")
        apiRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //apiRequest.addValue("development", forHTTPHeaderField: "versionID")
        
        //print(apiRequest)
        
        // Create JSON
        let json: [String: Any] = [
            "type": "text",
            "payload": GivenInput
        ]
        apiRequest.httpBody = try! JSONSerialization.data(withJSONObject: json)
        
        // Request
        let (data, _) = try! await URLSession.shared.data(for: apiRequest)
        
        print("Raw Response: \(String(data: data, encoding: .utf8))")
        
        // Parse the response
        let apiResponse = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        let trace = apiResponse["trace"] as! [[String: Any]]
        let payload = trace.first!["payload"] as! [String: Any] // .last or .first
        let message = payload["message"] as! String
        
        return message
    }
}


