//
//  PreviewViewController.swift
//  Estimate
//
//  Created by Thong Tran on 1/23/18.
//  Copyright © 2018 Thong Tran. All rights reserved.
//

import UIKit
import MessageUI

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var webPreview: UIWebView!
    var aProject = Project()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    var invoiceComposer: EstimateComposer!
    var HTMLContent: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createInvoiceAsHTML()
    }
    
    
    func createInvoiceAsHTML() {
        invoiceComposer = EstimateComposer()
        var totalAmount = 0.0
        for price in aProject.itemsList{
            totalAmount += price.itemPrice
        }
        
        let recipientInfo = (aProject.customerName) + "<br>" + aProject.customerAddress + "<br>"
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
        if let invoiceHTML = invoiceComposer.renderInvoice(invoiceNumber: aProject.projectId, invoiceDate: result, recipientInfo: recipientInfo, items: aProject.itemsList, totalAmount: String(totalAmount)) {
            webPreview.loadHTMLString(invoiceHTML, baseURL: NSURL(string: invoiceComposer.pathToInvoiceHTMLTemplate!)! as URL)
            HTMLContent = invoiceHTML
            
        }
    }
    
    @IBAction func exportPDF(_ sender: Any) {
        invoiceComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent)
        showOptionsAlert()
    }
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "PDF!", message: "Your PDF file is ready.\n\nWhat do you want to do now?", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionPreview = UIAlertAction(title: "Preview it", style: UIAlertActionStyle.default) { (action) in
            if let filename = self.invoiceComposer.pdfFilename, let url = URL(string: filename) {
                let request = URLRequest(url: url)
                self.webPreview.loadRequest(request)
            }
        }
        
        let actionEmail = UIAlertAction(title: "Send by Email", style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                self.sendEmail()
            }
        }
        
        let actionNothing = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        alertController.addAction(actionPreview)
        alertController.addAction(actionEmail)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}

extension PreviewViewController: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController:MFMailComposeViewController =  MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setSubject("Estimate PDF File")
            mailComposeViewController.addAttachmentData(NSData(contentsOfFile: invoiceComposer.pdfFilename)! as Data, mimeType: "application/pdf", fileName: "Estimate")
            present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
        
    }
    
}
