import Foundation

func sendToVoiceflowAPI(message: String, completion: @escaping (String?) -> Void) {
    let userID = "cilo"  // Replace with the actual user ID
    guard let url = URL(string: "https://general-runtime.voiceflow.com/state/user/\(userID)/interact") else {
        print("Invalid URL")
        completion(nil)
        return
    }

    // Prepare the request body with the user input
    let jsonPayload: [String: Any] = [
        "type": "text",
        "payload": message  // User's input text
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer VF.DM.6795474c2be6dc21af31f2bf.ID1gLdaM9BsSZ4IK", forHTTPHeaderField: "Authorization")  // Replace with your API key

    // Convert the JSON payload to Data
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonPayload, options: [])
    } catch {
        print("Error serializing JSON: \(error)")
        completion(nil)
        return
    }

    // Make the network request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error making request: \(error)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }

        // Parse the response
        do {
            if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = responseDict["payload"] as? String {
                completion(message)  // Pass the response back
            } else {
                print("Failed to parse response")
                completion(nil)
            }
        } catch {
            print("Error parsing response: \(error)")
            completion(nil)
        }
    }.resume()
}


//import UIKit
//import WebKit
//
//class ViewController: UIViewController, WKNavigationDelegate {
//    var webView: WKWebView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Initialize WKWebView
//        webView = WKWebView(frame: self.view.bounds)
//        webView.navigationDelegate = self
//        self.view.addSubview(webView)
//        
//        // Load HTML with the Voiceflow widget
//        let htmlString = """
//        <!DOCTYPE html>
//        <html>
//        <head>
//            <script type="text/javascript">
//              (function(d, t) {
//                  var v = d.createElement(t), s = d.getElementsByTagName(t)[0];
//                  v.onload = function() {
//                    window.voiceflow.chat.load({
//                      verify: { projectID: '6795463e52bfdd46f639074f' },
//                      url: 'https://general-runtime.voiceflow.com',
//                      versionID: 'production'
//                    });
//                  }
//                  v.src = "https://cdn.voiceflow.com/widget-next/bundle.mjs"; v.type = "text/javascript"; s.parentNode.insertBefore(v, s);
//              })(document, 'script');
//            </script>
//        </head>
//        <body>
//        </body>
//        </html>
//        """
//        webView.loadHTMLString(htmlString, baseURL: nil)
//    }
//}

