import Foundation
import Apollo

struct RepositoriesGraphQLClient: GraphQLClient {

  // MARK: - Public methods
  static func searchRepositories<Query: GraphQLQuery>(query: Query, _ completionHandler: @escaping GraphQLCompletionHandler<Query>) {
    GQLClient.runQuery(request: RepositoriesGraphQLRequest.searchRepositories(), query: query) { (result, error) in
      self.handle(result: result,
                  error: error,
                  completionHandler: completionHandler)
    }
  }
}
