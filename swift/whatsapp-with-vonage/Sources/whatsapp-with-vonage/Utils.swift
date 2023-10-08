//
//  Utils.swift
//  
//
//  Created by Rajat verma on 08/10/23.
//

import Vapor
import Foundation
import SwiftJWT
import NIOFoundationCompat

struct VonageMessage: Content {
    let from: String
    let to: String
    let messageType: String
    let text: String
    let channel: String
}

struct ResponseBodyResult: Codable {
    let from: String?
    let text: String?
}

struct JwtPayload: Codable, Claims {
    let payload_hash: String
}

extension Data {
    public init(buffer: ByteBuffer, byteTransferStrategy: ByteBuffer.ByteTransferStrategy = .automatic) {
        var buffer = buffer
        self = buffer.readData(length: buffer.readableBytes, byteTransferStrategy: byteTransferStrategy)!
    }
}
