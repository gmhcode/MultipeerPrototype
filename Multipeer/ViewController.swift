//
//  ViewController.swift
//  Multipeer
//
//  Created by Greg Hughes on 4/22/19.
//  Copyright © 2019 Greg Hughes. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    var peerID: MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!

    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var connectionButton: UIBarButtonItem!
    
    
    var reMsg: String!
    var sendMsg:String!
    var hosting:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        
        mcSession.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.removeKeyboard(_:)))
        view.addGestureRecognizer(tap)
        
        sendButton.isEnabled = false
        chatTextView.isEditable  = false
        hosting = false
        
        

        

    }
    
    
    @objc func removeKeyboard(_ sender: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if inputTextField.text != "" {
            
            sendMsg = "\n\(peerID.displayName): \(inputTextField.text!)\n"
            
            let message = sendMsg.data(using: String.Encoding.utf8, allowLossyConversion: false)
            
            do {
             try self.mcSession.send(message!, toPeers: self.mcSession.connectedPeers, with: .reliable)
            }catch{
                print("❌ There was an error in \(#function) \(error) : \(error.localizedDescription)")
            }
            
            chatTextView.text = chatTextView.text + "\nMe: \(inputTextField.text)\n"
            inputTextField.text = ""
            
            
            
        }
        else {
            let emptyAlert = UIAlertController(title: "You have not entered any text", message: nil, preferredStyle: .alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(emptyAlert, animated: true)
        }
    }
    
    
    
    @IBAction func connectionButtonTapped(_ sender: Any) {
        
        
        
        if mcSession.connectedPeers.count == 0 && !hosting{
            
            let connectActionSheet = UIAlertController(title: "Our chat", message: "Do you want to Host or join a chat?", preferredStyle: .alert)
            
            connectActionSheet.addAction(UIAlertAction(title: "Host chat", style: .default, handler: { (action:UIAlertAction) in
                self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "doesnt-matter", discoveryInfo: nil, session: self.mcSession)
                
                self.mcAdvertiserAssistant.start()
                self.hosting = true
            }))
            
            connectActionSheet.addAction(UIAlertAction(title: "join chat", style: .default, handler: { (action:UIAlertAction) in
                let mcBrowser = MCBrowserViewController(serviceType: "doesnt-matter", session: self.mcSession)
                mcBrowser.delegate = self
                self.present(mcBrowser,animated: true)
            }))
            
            connectActionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self.present(connectActionSheet, animated: true)
        }
            
            
            
        else if mcSession.connectedPeers.count == 0 && hosting {
            
            let waitActionSheet = UIAlertController(title: "waiting...", message: "waiting for others to join the chat", preferredStyle: .alert)
            
            waitActionSheet.addAction(UIAlertAction(title: "disconnect", style: .destructive, handler: { (action) in
                self.mcSession.disconnect()
                self.hosting = false
            }))
            
            waitActionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self.present(waitActionSheet, animated: true)
            
        }
            
            
            
        else {
            let disconnectActionSheet = UIAlertController(title: "are you sure you want to disconnect", message: nil, preferredStyle: .alert)
            disconnectActionSheet.addAction(UIAlertAction(title: "Disconnect", style: .destructive, handler: { (action:UIAlertAction) in
                self.mcSession.disconnect()
            }))
            disconnectActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(disconnectActionSheet, animated: true)
        }
    }
}

extension ViewController: MCSessionDelegate, MCBrowserViewControllerDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
        case MCSessionState.connecting :
            print("ConnectING: \(peerID.displayName)")
        case MCSessionState.notConnected :
            print("Not Connected: \(peerID.displayName)")
        default:
            print("Default: \(peerID.displayName)")
        }
        
        if mcSession.connectedPeers.count == 0 {
            sendButton.isEnabled = false
        }
        else {
             sendButton.isEnabled = true
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.reMsg = String(data: data as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as String
            self.chatTextView.text = self.chatTextView.text + self.reMsg
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
}
