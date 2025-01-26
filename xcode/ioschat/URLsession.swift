import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize WKWebView
        webView = WKWebView(frame: self.view.bounds)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        // Load HTML with the Voiceflow widget
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <script type="text/javascript">
              (function(d, t) {
                  var v = d.createElement(t), s = d.getElementsByTagName(t)[0];
                  v.onload = function() {
                    window.voiceflow.chat.load({
                      verify: { projectID: '6795463e52bfdd46f639074f' },
                      url: 'https://general-runtime.voiceflow.com',
                      versionID: 'production'
                    });
                  }
                  v.src = "https://cdn.voiceflow.com/widget-next/bundle.mjs"; v.type = "text/javascript"; s.parentNode.insertBefore(v, s);
              })(document, 'script');
            </script>
        </head>
        <body>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

