//
//  SocketHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/21/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import Security
import RxSwift

protocol SocketHandlerCallback {
    func didConnected()
    func didLostConnection()
    func didReceiveData(data: Data)
    func didConnectFailed()
    func updateRx(size: Int64)
    func updateTx(size: Int64)
}

class SocketHandler: NSObject, GCDAsyncSocketDelegate, NetDelegate {
    private let TAG = "SOCKET_HANDLER"
    private let queue = DispatchQueue(label: "OctoBeat.clinic.bluetooth.queue", attributes: .concurrent)
    private var mSocket: GCDAsyncSocket?
    private var secCertificate: SecCertificate?
    private var callback: SocketHandlerCallback?
    private var dispoTimeout: Disposable?
    
    var tcpConnections = [TCPConnection]()
    var serverCA = [UInt8: String]()
    var datas = SynchronizedArray<Data>()
    private var dataLength: Int = 0
    
    var isOpened = false
    
    
    init(callback: SocketHandlerCallback?) {
        super.init()
        NetworkManager.sharedInstance.registerNetDelegate(self)
        self.callback = callback
        dataLength = 0
    }
    
    func netStatus(on: Bool) {
        if(!on) {
            self.close()
        }
    }
    
    func isNetworkAvailable() -> Bool {
        return NetworkManager.sharedInstance.isNetAvailable()
    }
    
    public func takeDataLength() -> Int {
        return synchronized(self) { () -> Int in
            LogUtil.myLogInfo(clazz: TAG, methodName: "TAKE TCP DATA: ", message: "Length:\(dataLength)")
            return self.dataLength
        }
    }
    
    public func putDataLength(length: Int) {
        synchronized(self) {
            LogUtil.myLogInfo(clazz: TAG, methodName: "PUT TCP DATA: ", message: "Length:\(length)")
            self.dataLength = length
        }
    }
    
    public func startConection(ip: String, port: UInt16, certificate: String, timeout: Double) -> Void {
        self.secCertificate = self.formatCert(cert: certificate)
        self.mSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue(label: "OctoBeat.clinic.bluetooth.queue", attributes: .concurrent))
        do {
            self.startConnectionTimeout(timeout: timeout - 1)
            try self.mSocket?.connect(toHost: ip, onPort: port, withTimeout: timeout)
        } catch let error {
            self.callback?.didConnectFailed()
            LogUtil.myLogInfo(clazz: self.TAG, methodName: "startConection: ", message: "CONNECT FAILED \(error)")
        }
    }
    
    @objc func startConnectionTimeout(timeout: Double) {
        LogUtil.myLogInfo(clazz: self.TAG, methodName: "startConnectionTimeout: ", message: "START CONNECTION TCP TIMEOUT")
        dispoTimeout =
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).subscribe { (i) in
                if(Double(i.element!) == timeout){
                    LogUtil.myLogInfo(clazz: self.TAG, methodName: "startConnectionTimeout: ", message: "TIMEOUT CONNECTION TCP - CONNECT FAILED")
                    self.callback?.didConnectFailed()
                    self.dispoTimeout?.dispose()
                }
        }
    }
    
    public func close() {
        LogUtil.cloudLog(message: "SOCKET STATE: CLOSE")
        LogUtil.myLogInfo(clazz: TAG, methodName: "CLOSE: ", message: "TCP IS CLOSED")
        isOpened = false
        dataLength = 0
        datas.removeAll()
        dispoTimeout?.dispose()
        mSocket?.disconnect()
    }
    
    public func forcedClose() {
        LogUtil.myLogInfo(clazz: TAG, methodName: "CLOSE: ", message: "TCP IS FORCECLOSED")
        callback = nil
        close()
    }
    
    public func send(data: Data)->Bool {
        queue.sync {
            guard isOpened else {
                return false
            }
            if let socket = self.mSocket {
                socket.write(data, withTimeout: -1, tag: 0)
                callback?.updateTx(size: Int64(data.count))
                LogUtil.myLogInfo(clazz: TAG, methodName: "SEND TCP DATA: ", message: "\(data.count)")
                return true
            } else {
                return false
            }
        }
    }
    
    public func readData(socketHandler: SocketHandler?, length: Int) -> Data? {
        guard isOpened else {
            return nil
        }
        
        var takedData = Data()
        var count = 0
        
        while count < length {
            if let data = datas.first {
                takedData.append(data)
                count += data.count
            } else {
                break
            }
            
        }
        
        if(count < 0) {
            return nil
        } 
        
        if (takedData.count <= length) {
            return takedData
        } else {
            let remainderData = takedData.subArray(in: length...takedData.count)!
            self.datas.insert(remainderData, at: 0)
            return takedData.subArray(in: 0...length)
        }
    }
    
    
    func getTCPConnection(id: UInt8) -> TCPConnection? {
        for connection in tcpConnections {
            if(connection.id == id) {
                return connection
            }
        }
        
        return nil 
    }
    
    func addNewTCPConnection(connection: TCPConnection){
        if let c = getTCPConnection(id: connection.id){
            c.paste(connection: connection)
        } else {
            tcpConnections.append(connection)
        }
    }
    
    private func formatCert(cert: String) -> SecCertificate {
        let endCert = cert.replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
        let data = NSData(base64Encoded: endCert, options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let secCert = SecCertificateCreateWithData(kCFAllocatorDefault, data!)
        return secCert!
    }
    
    private func addAnchorToTrust(trust: SecTrust, certificate: SecCertificate) -> SecTrust {
        let array: NSMutableArray = NSMutableArray()
        
        array.add(certificate)
        
        SecTrustSetAnchorCertificates(trust, array)
        
        return trust
    }
}

extension SocketHandler {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        //print("didConnectToHost")
        
        sock.startTLS([
            //kCFStreamSSLValidatesCertificateChain as String: kCFBooleanFalse,
            kCFStreamSSLIsServer as String: kCFBooleanFalse,
            GCDAsyncSocketManuallyEvaluateTrust: kCFBooleanTrue,
            GCDAsyncSocketSSLProtocolVersionMin: NSNumber(value: SSLProtocol.tlsProtocol12.rawValue),
            GCDAsyncSocketSSLProtocolVersionMax: NSNumber(value: SSLProtocol.tlsProtocol12.rawValue)
        ])
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        //print("socketDidDisconnect, error \(String(describing: err))")
        LogUtil.cloudLog(message: "SOCKET STATE: DISCONNECT")
        LogUtil.myLogInfo(clazz: TAG, methodName: "CONNECT TCP RESULT: ", message: "TCP LOST CONNECTION - \(err)")
        isOpened = false
        dataLength = 0
        callback?.didLostConnection()
    }
    
    func socketDidSecure(_ sock: GCDAsyncSocket) {
        //print("socketDidSecure")
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        //print("didConnectTo")
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        //  print("SEND TCP DATA:")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        LogUtil.myLogInfo(clazz: TAG, methodName: "RECEIVED TCP DATA: ", message: "Length:\(data.count) : \(data.toHexString())")
        callback?.updateRx(size: Int64(data.count))
        callback?.didReceiveData(data: data)
        datas.append(data)
        putDataLength(length: takeDataLength() + data.count)
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        //print("didReadPartialDataOfLength")
    }
    
    func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        //print("didWritePartialDataOfLength")
    }
    
    func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        //        let myTrust: SecTrust = addAnchorToTrust(trust: trust, certificate: self.secCertificate!)
        //        var result: SecTrustResultType = SecTrustResultType.unspecified
        //        let error: OSStatus = SecTrustEvaluate(myTrust, &result)
        
        //        if (result != SecTrustResultType.proceed && result != SecTrustResultType.unspecified) {
        //            callback?.didConnectFailed()
        //            LogUtil.myLogInfo(clazz: TAG, methodName: "startConection: ", message: "CONNECT FAILED DUE TO NOT TRUSTED")
        //            // print("Peer is not trusted")
        //        }
        //        else {
        // print("SocketHandler CONNECTED TCP WITH TRUSTED PEER")
        dispoTimeout?.dispose()
        callback?.didConnected()
        isOpened = true
        sock.readData(withTimeout: -1, tag: 0)
        completionHandler(true)
        //        }
    }
}

