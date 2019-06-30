import UIKit
import Apollo

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Initial query
    //Feel free to update the number of item requested according to your implementation
    let gqlQuery = SearchRepositoriesQuery.init(first: 5, query: "graphql", type: SearchType.repository)

    //Paginated search Query
    //let gqlQuery = SearchRepositoriesQuery.init(first: 5, after: "Y3Vyc29yOjQ=", query: "graphql", type: SearchType.repository)
    
    RepositoriesGraphQLClient.searchRepositories(query: gqlQuery) { (result) in
      switch result {
      case .success(let data):
        if let gqlResult = data {
          
          if let pageInfo = gqlResult.data?.search.pageInfo {
            print("pageInfo: \n")
            print("hasNextPage: \(pageInfo.hasNextPage)")
            print("hasPreviousPage: \(pageInfo.hasPreviousPage)")
            print("startCursor: \(String(describing: pageInfo.startCursor))")
            print("endCursor: \(String(describing: pageInfo.endCursor))")
            print("\n")
          }
          
          
          gqlResult.data?.search.edges?.forEach { edge in
            guard let repository = edge?.node?.asRepository?.fragments.repositoryDetails else { return }
            print("Name: \(repository.name)")
            print("Path: \(repository.url)")
            print("Owner: \(repository.owner.login)")
            print("avatar: \(repository.owner.avatarUrl)")
            print("Stars: \(repository.stargazers.totalCount)")
            print("\n")
          }
        }
      case .failure(let error):
        if let error = error {
          print(error)
        }
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}
