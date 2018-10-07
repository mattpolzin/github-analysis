// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "GitHubAnalysis",
    products: [
        .executable(name: "github-analysis", targets: ["GitHubAnalysis"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.7.3"),
	.package(url: "https://github.com/antitypical/Result.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "GitHubAnalysis",
            dependencies: ["Alamofire", "Result"]),
        .testTarget(
            name: "GitHubAnalysisTests",
            dependencies: ["GitHubAnalysis"])
    ]
)
