//
//  ViewController.swift
//  WebViewWithFCM
//
//  Created by ahmed abdelhameed on 2/21/20.
//  Copyright © 2020 ahmed abdelhameed. All rights reserved.
//Fb, instagram, Twitter, snapchat, tiktok, linkdin,

import UIKit
import WebKit
import SVProgressHUD
import SwiftSoup
import AVKit


class ViewController: UIViewController , WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    var videoLoadCount = 0
    var urlBefore: String = ""
    var urlAfter: String = ""

    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    var preView: PreView = PreView()
    /*
     Handler method for JavaScript calls.
     Receive JavaScript message with downloaded document
     */
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("did receive message \(message.name)")
        
//      let body = message.body as! String
        
        if (message.name == "openDocument") {//||  body.contains("download"){
            handleDocument(messageBody: message.body as! String)
        } else if (message.name == "jsError") {
            debugPrint(message.body as! String)
        }
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        let urlStr = url!.absoluteString as? String
        if (!urlAfter.isEmpty) {
            urlBefore = urlAfter
        }
        urlAfter = urlStr!;
        
        if  urlStr != nil{
            if urlStr!.contains("download") {
                decisionHandler(.cancel)
                
                self.view.makeToast("Downloading, Please wait...", duration: 2.0, position: .bottom)
                executeDocumentDownloadScript(forAbsoluteUrl: url!.absoluteString)
                
            }else if urlStr!.contains("instagram.com") {
                let url = URL.init(string: urlStr!)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                
                decisionHandler(.cancel)
            }else if urlStr!.contains("snapchat.com") {
//                let username = "USERNAME"
//                let appURL = URL(string: "snapchat://add/\(username)")!
                
                let application = UIApplication.shared
//                let appURL = URL(string: "snapchat://app")!
                let appURL = URL(string: urlStr!)!
                
                if application.canOpenURL(appURL){
                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                }else{
                    let url = URL.init(string: urlStr!)
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
                
                decisionHandler(.cancel)
            }else if urlStr!.contains("linkedin.com") {
                let url = URL.init(string: urlStr!)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                
                decisionHandler(.cancel)
            }else if urlStr!.contains("youtube.com") {
                let url = URL.init(string: urlStr!)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                
                decisionHandler(.cancel)
            }else if urlStr!.contains("facebook.com") {
                let url = URL.init(string: urlStr!)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                
                decisionHandler(.cancel)
            }else if urlStr!.contains("twitter.com") {
                let url = URL.init(string: urlStr!)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                
                decisionHandler(.cancel)
            }else if urlStr!.contains("tiktok.com") {
                let url = URL.init(string: urlStr!)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                
                decisionHandler(.cancel)
            }
            else {
                print(videoLoadCount)
                if (videoLoadCount > 1 && videoLoadCount % 2 == 1) {
                    decisionHandler(.cancel)
                    videoLoadCount = 1
                } else {
                    decisionHandler(.allow)
                }
//                decisionHandler(.allow)
            }
        }else{
            decisionHandler(.allow)
        }
    }
    
    /*
     Open downloaded document in QuickLook preview
     */
    private func handleDocument(messageBody: String) {
        // messageBody is in the format ;data:;base64,
        
        // split on the first ";", to reveal the filename
        let filenameSplits = messageBody.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
        
        _ = String(filenameSplits[0])
        
        // split the remaining part on the first ",", to reveal the base64 data
        let dataSplits = filenameSplits[1].split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
        
        let data = Data(base64Encoded: String(dataSplits[1]))
        
        if (data == nil) {
            debugPrint("Could not construct data from base64")
            return
        }
        
        saveFiles(data: data!)
                
        // and display it in QL
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success", message: "File downloaded successfully in your gallery", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(dismiss)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveFiles(data: Data) {
        let timestamp = String(Date().ticks)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(timestamp).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        debugPrint("File URL \(fileURL)")
        
        let image = UIImage(data: data)
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    /*
     Intercept the download of documents in webView, trigger the download in JavaScript and pass the binary file to JavaScript handler in Swift code
     */
    private func executeDocumentDownloadScript(forAbsoluteUrl absoluteUrl : String) {
        // TODO: Add more supported mime-types for missing content-disposition headers
        webView.evaluateJavaScript("""
            (async function download() {
            const url = '\(absoluteUrl)';
            try {
            // we use a second try block here to have more detailed error information
            // because of the nature of JS the outer try-catch doesn't know anything where the error happended
            let res;
            try {
            res = await fetch(url, {
            credentials: 'include'
            });
            } catch (err) {
            window.webkit.messageHandlers.jsError.postMessage(`fetch threw, error: ${err}, url: ${url}`);
            return;
            }
            if (!res.ok) {
            window.webkit.messageHandlers.jsError.postMessage(`Response status was not ok, status: ${res.status}, url: ${url}`);
            return;
            }
            const contentDisp = res.headers.get('content-disposition');
            if (contentDisp) {
            const match = contentDisp.match(/(^;|)\\s*filename=\\s*(\"([^\"]*)\"|([^;\\s]*))\\s*(;|$)/i);
            if (match) {
            filename = match[3] || match[4];
            } else {
            // TODO: we could here guess the filename from the mime-type (e.g. unnamed.pdf for pdfs, or unnamed.tiff for tiffs)
            window.webkit.messageHandlers.jsError.postMessage(`content-disposition header could not be matched against regex, content-disposition: ${contentDisp} url: ${url}`);
            }
            } else {
            window.webkit.messageHandlers.jsError.postMessage(`content-disposition header missing, url: ${url}`);
            return;
            }
            if (!filename) {
            const contentType = res.headers.get('content-type');
            if (contentType) {
            if (contentType.indexOf('application/json') === 0) {
            filename = 'unnamed.pdf';
            } else if (contentType.indexOf('image/tiff') === 0) {
            filename = 'unnamed.tiff';
            }
            }
            }
            if (!filename) {
            window.webkit.messageHandlers.jsError.postMessage(`Could not determine filename from content-disposition nor content-type, content-dispositon: ${contentDispositon}, content-type: ${contentType}, url: ${url}`);
            }
            let data;
            try {
            data = await res.blob();
            } catch (err) {
            window.webkit.messageHandlers.jsError.postMessage(`res.blob() threw, error: ${err}, url: ${url}`);
            return;
            }
            const fr = new FileReader();
            fr.onload = () => {
            window.webkit.messageHandlers.openDocument.postMessage(`${filename};${fr.result}`)
            };
            fr.addEventListener('error', (err) => {
            window.webkit.messageHandlers.jsError.postMessage(`FileReader threw, error: ${err}`)
            })
            fr.readAsDataURL(data);
            } catch (err) {
            // TODO: better log the error, currently only TypeError: Type error
            window.webkit.messageHandlers.jsError.postMessage(`JSError while downloading document, url: ${url}, err: ${err}`)
            }
            })();
            // null is needed here as this eval returns the last statement and we can't return a promise
            null;
        """) { (result, err) in
            if (err != nil) {
                debugPrint("JS ERR: \(String(describing: err))")
            }
        }
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var webView: WKWebView!
//    let backButton = UIBarButtonItem(title: "back", style: .plain, target: self, action:#selector(goBackBtnPressed) )
//    let forwardButon = UIBarButtonItem(title: "forward", style: .plain, target: self, action: #selector(goForwardBtnPressed))
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()

        // init this view controller to receive JavaScript callbacks
        webConfiguration.userContentController.add(self, name: "openDocument")
        webConfiguration.userContentController.add(self, name: "jsError")
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = .audio
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        view = webView
        
        setupNavBar()
    }
        
    @objc func windowDidBecomeVisibleNotification(notif: Notification) {
        if let isWindow = notif.object as? UIWindow {
            if (isWindow !== self.view.window) {
                print("New window did open, check what is the currect URL")
                print(urlBefore + "-----" + urlAfter)
                videoLoadCount = videoLoadCount + 1
            }
        }
    }
    
    @objc func handleNotificationAction(_ notification : Notification){
        guard let result = notification.object as? String else {
            return
        }
        webView.load("https://postat.com" + result)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        //change status bar color
        if #available(iOS 13.0, *) {
           let app = UIApplication.shared
           let statusBarHeight: CGFloat = app.statusBarFrame.size.height

           let statusbarView = UIView()
           statusbarView.backgroundColor = UIColor(displayP3Red: 20/255, green: 146/255, blue: 145/255, alpha: 1.0)
           view.addSubview(statusbarView)

           statusbarView.translatesAutoresizingMaskIntoConstraints = false
           statusbarView.heightAnchor
             .constraint(equalToConstant: statusBarHeight).isActive = true
           statusbarView.widthAnchor
             .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
           statusbarView.topAnchor
             .constraint(equalTo: view.topAnchor).isActive = true
           statusbarView.centerXAnchor
             .constraint(equalTo: view.centerXAnchor).isActive = true

        } else {
              let statusBar = UIApplication.shared.value(forKeyPath:
           "statusBarWindow.statusBar") as? UIView
              statusBar?.backgroundColor = UIColor(displayP3Red: 20/255, green: 146/255, blue: 145/255, alpha: 1.0)
        }
    }
    
    @objc func refreshControlClicked() {
        webView.load("https://postat.com/")
        refreshControl.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.refreshControl.bounds = CGRect.init(x: 0.0, y: 50.0, width: refreshControl.bounds.size.width, height: refreshControl.bounds.size.height)
        
        refreshControl.addTarget(self, action:#selector(refreshControlClicked), for: UIControl.Event.valueChanged)
        self.webView.scrollView.addSubview(self.refreshControl)
            
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationAction), name: NSNotification.Name(rawValue: "NotificationAction"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeVisibleNotification(notif:)), name: NSNotification.Name("UIWindowDidBecomeVisibleNotification"), object: nil)
        
        preView = Bundle.main.loadNibNamed("PreView", owner: self, options: nil)?.first as! PreView
        preView.frame = self.view.frame
        view.addSubview(preView)
        
        webView.load("https://postat.com/")
    }
    
    func setupNavBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 20/255, green: 146/255, blue: 145/255, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Start loading")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
            preView.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (res, error) in
            do {
                if res != nil{
                    
                    let doc: Document = try! SwiftSoup.parse(res as! String)
                    guard let link: Element = try! doc.select("img").first() else{
                        return
                    }
                    
                    let _: String = try! doc.body()!.text(); // "An example link"
                    let linkHref: String = try! link.attr("alt"); // "http://example.com/"
                    let _: String = try! link.text(); // "example""
                    
                    print("swiftyyy \(linkHref)")
                    
                    let def = UserDefaults.standard
                    let token =  def.value(forKey: "token") as? String ?? ""
                    
                    API.sendTokenToServer(token: token, userName: linkHref) { (error, result) in
                        
                        if error != nil {
                            print("there is an error occured \(error?.localizedDescription ?? "")")
                        }else{
                            print("done \(result ?? "")")
                        }
                        
                    }
                }
                
            } catch Exception.Error( _, let message) {
                print(message)
            } catch {
                print("error")
            }
            
        }
        
    }
}

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
            
        }
    }
}



extension Date {
    
    init?(jsonDate: String) {
       // let prefix = "/Date("
      //  let suffix = ")/"
        let scanner = Scanner(string: jsonDate)
        
        // Check prefix:
       // guard scanner.scanString(prefix, into: nil)  else { return nil }
        
        // Read milliseconds part:
        var milliseconds : Int64 = 0
        guard scanner.scanInt64(&milliseconds) else { return nil }
        // Milliseconds to seconds:
        var timeStamp = TimeInterval(milliseconds)/1000.0
        
        // Read optional timezone part:
        var timeZoneOffset : Int = 0
       
        if scanner.scanInt(&timeZoneOffset) {
            let hours = timeZoneOffset / 100
            let minutes = timeZoneOffset % 100
            // Adjust timestamp according to timezone:
            timeStamp += TimeInterval(3600 * hours + 60 * minutes)
        }
        
        // Check suffix:
    //    guard scanner.scanString(suffix, into: nil) else { return nil }
        
        // Success! Create NSDate and return.
        self.init(timeIntervalSince1970: timeStamp)
    }
    
    func daysFromToday() -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day!
    }
    
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

extension AVPlayerViewController {

    func goFullScreen() {
        let selectorName: String = {
            if #available(iOS 11.3, *) {
                return "_transitionToFullScreenAnimated:interactive:completionHandler:"
            } else if #available(iOS 11, *) {
                return "_transitionToFullScreenAnimated:completionHandler:"
            } else {
                return "_transitionToFullScreenViewControllerAnimated:completionHandler:"
            }
        }()
        let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)

        if self.responds(to: selectorToForceFullScreenMode) {
            self.perform(selectorToForceFullScreenMode, with: true, with: nil)
        }
    }

    func quitFullScreen() {
        let selectorName: String = {
            if #available(iOS 11, *) {
                return "_transitionFromFullScreenAnimated:completionHandler:"
            } else {
                return "_transitionFromFullScreenViewControllerAnimated:completionHandler:"
            }
        }()
        let selectorToForceQuitFullScreenMode = NSSelectorFromString(selectorName)

        if self.responds(to: selectorToForceQuitFullScreenMode) {
            self.perform(selectorToForceQuitFullScreenMode, with: true, with: nil)
        }
    }
    
}
