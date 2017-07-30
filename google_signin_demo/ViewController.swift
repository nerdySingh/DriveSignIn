//
//  ViewController.swift
//  google_signin_demo
//
//  Created by Tanveer Anand on 22/07/17.
//  Copyright © 2017 Tanveer Anand. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn
import GoogleAPIClientForREST
class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{

    
    private let scopes = [kGTLRAuthScopeDriveReadonly]
    var text = "";

    private let service = GTLRDriveService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var error : NSError?
        GGLContext.sharedInstance().configureWithError(&error)
        if error != nil
        {
            print(error)
            return
        }
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        let signInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        signInButton.center = view.center
        view.addSubview(signInButton)
        
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!)
    {
        
        if let error = error
        {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            
            self.service.authorizer = nil
        }
        else
        {
            print(user.profile.email)
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            
            listFiles()
        }
        
    }
    
    
    func listFolder()
    {
        
    }
        
    // List up to 10 files in Drive
    func listFiles() {
        let query = GTLRDriveQuery_FilesList.query()
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the response and display output
    func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRDrive_FileList,
                                 error : NSError?)
    {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
     
    
       
        
        if let files = result.files, !files.isEmpty {
            
            for file in files {
                
                let mime = file.mimeType!
                if mime == "application/vnd.google-apps.folder"
                {
                    text += "\(file.name!) (\(file.identifier!))\n"
                    output.text = text
                }
            }
        } else {
            text += "No files found."
            output.text = text
        }
        //output.text = text
        if ((result.nextPageToken) != nil)
        {
            print("more pages")
            let nextquery = GTLRDriveQuery_FilesList.query()
            nextquery.pageToken = result.nextPageToken
            service.executeQuery(nextquery, delegate: self, didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
            
        }
        else
        {
            print("no more folders..")
        }

    }
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
