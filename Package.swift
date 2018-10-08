// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "GitHubAnalysis",
    products: [
        .executable(name: "github-analysis", targets: ["GitHubAnalysis"]),
	.library(name: "GitHubAnalysis", targets: ["GitHubAnalysisCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.7.3"),
	.package(url: "https://github.com/antitypical/Result.git", from: "4.0.0"),
	.package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.11.0")
    ],
    targets: [
	.target(
	    name: "GitHubAnalysisCore",
	    dependencies: ["Result"]),
        .target(
            name: "GitHubAnalysis",
            dependencies: ["Alamofire", "Result", "GitHubAnalysisCore"]),
        .testTarget(
            name: "GitHubAnalysisTests",
            dependencies: ["GitHubAnalysisCore", "SwiftCheck"])
    ]
)
