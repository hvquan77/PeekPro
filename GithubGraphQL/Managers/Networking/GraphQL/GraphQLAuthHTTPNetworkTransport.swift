import Foundation
import Apollo

/// Based on HTTPNetworkTransport from Apollo to add Authentication (Bearer Token from JWT) header dynamically
public class GraphQLAuthHTTPNetworkTransport: NetworkTransport {
  
  enum GQLError: Error {
    case errorResponse(body: Data?, response: HTTPURLResponse)
    case invalidResponse(body: Data?, response: HTTPURLResponse)
  }
  
  let url: URL
  let token: String
  let session: URLSession
  let serializationFormat = JSONSerializationFormat.self
  
  public init(url: URL, token: String, configuration: URLSessionConfiguration = URLSessionConfiguration.default, sendOperationIdentifiers: Bool = false) {
    self.url = url
    self.token = token
    self.session = URLSession(configuration: configuration)
    self.sendOperationIdentifiers = sendOperationIdentifiers
  }
  
  public func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.post.rawValue
    
    request.setValue(MimeType.json, forHTTPHeaderField: HttpHeaders.contentType)
    
    // Auth header
    if self.token.count > 0 {
      request.setValue("Bearer \(self.token)", forHTTPHeaderField: HttpHeaders.authorization)
    }
    
    let body = requestBody(for: operation)
    request.httpBody = try! serializationFormat.serialize(value: body)
    
    let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
      if error != nil {
        completionHandler(nil, error)
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        NSLog("Response should be an HTTPURLResponse")
        return
      }
      
      if (httpResponse.statusCode != 200) {
        //We could check for 401 but the PKAPIManager is handling auth refresh.
        NSLog("GraphQL Request failed: \(httpResponse)")
        completionHandler(nil, GQLError.errorResponse(body: data, response: httpResponse))
        return
      }
      
      guard let data = data else {
        completionHandler(nil, GQLError.invalidResponse(body: nil, response: httpResponse))
        return
      }
      
      do {
        guard let body =  try self.serializationFormat.deserialize(data: data) as? JSONObject else {
          completionHandler(nil, GQLError.invalidResponse(body: data, response: httpResponse))
          return
        }
        let response = GraphQLResponse(operation: operation, body: body)
        completionHandler(response, nil)
      } catch {
        completionHandler(nil, error)
      }
    }
    
    task.resume()
    
    return task
  }
  
  private let sendOperationIdentifiers: Bool

  private func requestBody<Operation: GraphQLOperation>(for operation: Operation) -> GraphQLMap {
    if sendOperationIdentifiers {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }
      return [GraphQLParams.id: operationIdentifier,
              GraphQLParams.variables: operation.variables]
    }
    return [GraphQLParams.query: operation.queryDocument,
            GraphQLParams.variables: operation.variables]
  }
}
