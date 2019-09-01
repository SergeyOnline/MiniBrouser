//
//  ViewController.swift
//  MiniBrouser
//
//  Created by Сергей on 23/07/2019.
//  Copyright © 2019 Sergey Gryaznov. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, UIScrollViewDelegate, WKNavigationDelegate, UITextFieldDelegate, FavoriteViewControllerDelegate {
 
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var undoItem: UIBarButtonItem!
    @IBOutlet weak var redoItem: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var adressLabel: UILabel!
    let searchSystem = "searchSystem"
    var homePage = "https://www.google.com"
    
    var webView: WKWebView!
    var lastOffsetY: CGFloat = 0
    
    
    
    override func loadView() {
        super.loadView()
        let webConfigurations = WKWebViewConfiguration()
        webView = WKWebView(frame: myView.bounds, configuration: webConfigurations)
        myView.addSubview(webView)
        myView.addSubview(toolBar)
        myView.addSubview(textFieldView)
        textFieldView.addSubview(textField)
        myView.addSubview(adressLabel)
        refreshHomePage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        let myURL = URL(string: homePage)
        let myRequest = URLRequest(url: myURL!)
        webView.contentMode = .scaleAspectFill
        webView.load(myRequest)
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        undoItem.isEnabled = false
        redoItem.isEnabled = false
        adressLabel.contentMode = .scaleAspectFill
        adressLabel.autoresizingMask = [.flexibleWidth]
        textFieldView.isHidden = true
     
        //myView.autoresizingMask = [.flexibleHeight, .flexibleTopMargin,]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: app)
        refreshHomePage()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BackToViewController" {
            let navController = segue.destination as! UINavigationController
            for controller in navController.viewControllers {
                if controller.isKind(of: FavoriteViewController.self) {
                    let tableController = controller as! FavoriteViewController
                    tableController.delegate = self
                }
            }
        }
        self.textFieldView.isHidden = true
    }
    
    //MARK: - Methods
    
    @objc func applicationWillEnterForeground(notification:Notification){
        let defaults = UserDefaults.standard
        defaults.synchronize()
        refreshHomePage()
    }

    func newRequest(request: URLRequest) {
        webView.load(request)
    }
    
    func refreshHomePage() {
        let defaults = UserDefaults.standard
        homePage = defaults.string(forKey: searchSystem)!
    }

    
    //MARK: - Actions
    
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        var sharedItems:[URL] = []
        sharedItems.append(webView.url!)
        let activityVC = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
        
    }
    
    @IBAction func navigateToolBarButtonAction(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            if webView.canGoBack {
                webView.stopLoading()
                webView.goBack()
            }
        case 1:
            if webView.canGoForward {
                webView.stopLoading()
                webView.goForward()
            }
        default:
            break
        }
    }
    
    @IBAction func refreshButtonAction(_ sender: UIBarButtonItem) {
        webView.reloadFromOrigin()
    }
    
    //MARK: - Text Field Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !textField.text!.isEmpty {
            let prefixString = "https://www."
            textField.text = prefixString + textField.text!
            let url = URL(string: textField.text ?? homePage)
            let request = URLRequest(url: url!)
            webView.load(request)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        let url = URL(string: textField.text ?? homePage)
        let request = URLRequest(url: url!)
        webView.load(request)
        textFieldView.isHidden = true
        adressLabel.isHidden = false
        
        return true
    }
    
    //MARK: - Scroll View Delegate

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let hide = scrollView.contentOffset.y > self.lastOffsetY
        //self.navigationController?.setNavigationBarHidden(hide, animated: true)
        toolBar.isHidden = hide
        textFieldView.isHidden = hide
        adressLabel.isHidden = !hide
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if textFieldView.isHidden == false {
            textFieldView.isHidden = true
        }
        return true
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
       
    }
    
    //MARK: - WK Navigation Delegate
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        adressLabel.text = webView.url?.absoluteString
        textField.text = webView.url?.absoluteString
        if webView.canGoBack {
            self.undoItem.isEnabled = true
        } else {
            self.undoItem.isEnabled = false
        }
        if webView.canGoForward {
            self.redoItem.isEnabled = true
        } else {
            self.redoItem.isEnabled = false
        }
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let stringError = error.localizedDescription
        let htmlString = """
        <html>
        <body>
        <br>
        <br>
        <br>
        <H1 style=\"font-size: 100; text-align: center; \">Page not found</H1>
        <hr align="center" width="800" size="2" color="#ff0000" />
        <br />
        <p style=\"font-size: 30; text-align: center; \">Reason: \(stringError)</p>
        <p style="text-align: center; font-size: 50;">
        <form action="\(homePage)"; align="center">
        <button style=\"center; horizontal-align: center; text-align: center; font-size: 30;\">HOME PAGE</button>
        </form>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}


