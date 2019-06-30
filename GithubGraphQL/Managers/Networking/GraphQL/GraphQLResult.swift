import Foundation
import Apollo

public enum Result<Operation: GraphQLOperation> {
  case success(GraphQLResult<Operation.Data>?)
  case failure(Error?)
}
