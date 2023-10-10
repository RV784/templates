import Vapor
import Foundation
import SwiftJWT

func main(req: Request) async throws -> Response {
    guard let vonageApiKey = ProcessInfo.processInfo.environment["VONAGE_API_KEY"],
          let vonageAccountSecret = ProcessInfo.processInfo.environment["VONAGE_ACCOUNT_SECRET"],
          let vonageSignatureSecret = ProcessInfo.processInfo.environment["VONAGE_SIGNATURE_SECRET"],
          let vonageWhatsAppNumber = ProcessInfo.processInfo.environment["VONAGE_WHATSAPP_NUMBER"] else {
        throw Abort(.internalServerError, reason: "Missing environment variables")
    }
    
    // GET METHOD TO RETURN HTML
    if req.method == .GET {
        let htmlData = try Data(contentsOf: URL(fileURLWithPath: "/templates/swift/whatsapp-with-vonage/Sources/whatsapp-with-vonage/Static/index.html"))
        let headers = HTTPHeaders([("Content-Type", "text/html; charset=utf-8")])
        return .init(
            status: .ok,
            headers: headers,
            body: .init(data: htmlData)
        )
    }
    
    // TOKEN AND JWT VERIFICATION
    let token = req.headers.first(name: "Authorization")?.split(separator: " ")[1]
    
    let jwtVerifier = JWTVerifier.hs256(key: Data(vonageSignatureSecret.utf8))
    let payload = try JWT<JwtPayload>(jwtString: "\(String(describing: token))", verifier: jwtVerifier)
    
    var requestBody: Data?
    if let byteBuffer = req.body.data {
        requestBody = Data(buffer: byteBuffer)
    } else {
        requestBody = Data()
    }
    
    // Calculate the SHA-256 hash of the request body
    let requestBodyHash = SHA256.hash(data: requestBody!).description
    
    // Compare the calculated hash with the one from the JWT payload
    if requestBodyHash != payload.claims.payload_hash {
        throw Abort(.unauthorized, reason: "Payload hash mismatch")
    }
    
    // CHECKING MESSAGE AND FROM KEY
    let resultBody = try req.content.decode(ResponseBodyResult.self)
    guard let from = resultBody.from,
          let text = resultBody.text else {
        throw Abort(.badRequest, reason: "Required fields 'from' and 'text' missing in the request body")
    }
    
    let basicAuthToken = "\(vonageApiKey):\(vonageAccountSecret)".data(using: .utf8)!.base64EncodedString()
    
    // SENDING RESPONSE
    let vonageMessage = VonageMessage(
        from: vonageWhatsAppNumber,
        to: from,
        messageType: "text",
        text: "Hi there! You sent me: \(text)",
        channel: "whatsapp"
    )
    
    let clientResponse = try await req.client.post("https://messages-sandbox.nexmo.com/v1/messages") { req in
        try req.content.encode(vonageMessage)
        req.headers.add(name: "Content-Type", value: "application/json")
        req.headers.add(name: "Authorization", value: "Basic \(basicAuthToken)")
    }
    
    return .init(status: .ok)
}
