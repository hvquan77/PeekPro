# The Peek iOS Coding Challenge


<img src="https://cdn.worldvectorlogo.com/logos/graphql.svg" width="200" height="200" /><img src="https://d2z5w7rcu7bmie.cloudfront.net/assets/images/logo.png" width="200" height="200" />



## Goal

Build a small iPhone application that queries Github to get repositories that mention `GraphQL`.
The results are to be displayed in a list view with pagination support.
Remember it’s a demo and not a fully featured app! However, we would like to see code that you are proud of and that would you merge into the mainline of your project.
Please explain in a README file the choices you made to complete the code challenge and list the things you would have added if you had more time to spend on it.

## Services
The application will interface with the [Github V4 API](https://developer.github.com/v4)

- [Perform a search](https://developer.github.com/v4/query)
- [Search Result](https://developer.github.com/v4/object/searchresultitemconnection/)


## Requirements

Initial launch: fetch the initial set of repos that contain the string `graphql`
Infinite scrolling: Fetch the next set of repository.
Error handling
Each table cell should contain:
- The name of the repo
- The owner login name
- The owner avatar
- The number of stars

We are using MVVM at Peek to build iOS apps and we would like you to use it to build this demo app.

## Setup
This project uses [CocoaPods](https://cocoapods.org/) and leverages the [Apollo iOS client](https://github.com/apollographql/apollo-ios) to fetch data from a GraphQL API. In order to pull data from Github API, please generate an access [token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).

The `githubToken` varaible will need to be updated the `GraphQLClientProtocol.swift` file.

## Libraries
You are allowed to used third party libraries when appropriate.
Use your good judgement and please justify the use (when necessary) of any third party library.

## Specifications
Language: Swift 5 or later
Development environment: Xcode 10 or later
Target: iOS 12 or later

## Submission
When finished, create a public Github repository with your solution.
We want your code to represent the best of your abilities.
Please also include any documentation or ramblings to help us better understand your submission and the coding choices you made.
 
 
Finally, there are plenty of details that are purposefully vague here, because we want to give you leeway to be creative and show us your way of doing things. 

## Question?
If you have any questions, do not hesitate at all to ask (tony@peek.com).
