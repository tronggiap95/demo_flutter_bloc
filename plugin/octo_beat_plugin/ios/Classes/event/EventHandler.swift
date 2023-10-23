//
//  EventHandler.swift
//  octo_beat_plugin
//
//  Created by TRAN QUANG DAI on 09/02/2023.
//

import Foundation
import Flutter

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
