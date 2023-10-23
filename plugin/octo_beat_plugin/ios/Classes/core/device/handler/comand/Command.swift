
//
//  Command.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

@objc
 protocol Command {
    func getData() -> Data?
    func setSecure(isSecure: Bool, aes: AESManager?) -> Command
    func buildPacket(payloadData: Data) -> Command
    @objc optional func build(params: CommandParams) -> Command
}
