import Foundation
import Apollo

/*
 To generate the GraphQL Schema
 cd "${SRCROOT}/Managers/Networking/GraphQL/"
 apollo schema:download --endpoint=https://api.github.com/graphql --header="Authorization: Bearer <token>"
 */

enum GQLClient {
  
  static func runQuery<Query: GraphQLQuery>(request: GraphQLRequest,
                                            query: Query,
                                            operationResultHandler: OperationResultHandler<Query>? = nil) {
    GraphQLManager.shared().fetch(query: query,
                                  cachePolicy: request.cachePolicy,
                                  queue: request.queue,
                                  resultHandler: operationResultHandler)
  }
}


class GraphQLManager {
  
  // MARK: - Properties
  private static var client: ApolloClient = {
    let configuration = URLSessionConfiguration.default
    let url = URL(string: githubGQL)!

    return ApolloClient(networkTransport: GraphQLAuthHTTPNetworkTransport(url: url, token: githubToken))
  }()
  
  
  // MARK: - Accessors
  class func shared() -> ApolloClient {
    return client
  }
}
