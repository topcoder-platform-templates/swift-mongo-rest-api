// swift-tools-version:4.2

import PackageDescription

let package = Package(
	name: "SampleServer",
	products: [
		.executable(name: "SampleServer", targets: ["SampleServer"])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-MongoDB.git", .exact("3.1.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.2.0"),
        .package(url: "https://gitlab.com/seriyvolk83/SwiftEx.git", .exact("0.0.7")),
	],
	targets: [
		.target(name: "SampleServer", dependencies: ["PerfectHTTPServer", "PerfectMongoDB", "SwiftyJSON", "SwiftEx"])
	]
)
