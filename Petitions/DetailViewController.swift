//
//  DetailViewController.swift
//  Petitions
//
//  Created by Atin Agnihotri on 14/07/21.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    var webView: WKWebView!
    var petition: PetitionModel?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadPetitionDetails()
    }
    
    func loadPetitionDetails() {
        guard let petition = self.petition else { return }
        let htmlString = getHtmlString(petition.body, title: petition.title)
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func getHtmlString(_ petitionBody: String, title: String) -> String {
        """
        <html>
        <head>
        <meta name="viewport", content="width=device-width, initial-scale=1">
        <style> body { font-size: 150%; } </style>
        </head>
        <body>
        <h1>
        \(title)
        </h1>
        \(petitionBody)
        </body>
        </html>
        """
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
