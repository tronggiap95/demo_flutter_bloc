//
//  EventHandler.swift
//  Runner
//
//  Created by Manh Tran on 25/09/2023.
//

import Foundation

class EventHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    
    func send(event: String, body: [String: Any]?) {
        eventSink?(["event": event, "body": body])
    }
    
    func send(event: String, body: [AnyHashable: Any]) {
        eventSink?(["event": event, "body": body])
    }
    
}
