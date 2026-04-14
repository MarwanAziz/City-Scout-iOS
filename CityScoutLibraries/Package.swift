// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "CityScoutLibraries",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "SharedResources",
      targets: ["SharedResources"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/MarwanAziz/CityScoutShared.git",
      exact: "1.0.6"
    ),
    .package(
      url: "https://github.com/rickclephas/KMP-NativeCoroutines.git",
      exact: "1.0.2"
    )
  ],
  targets: [
    .target(
      name: "SharedResources",
      dependencies: [
        .product(name: "CityScoutShared", package: "CityScoutShared"),
        .product(name: "KMPNativeCoroutinesAsync", package: "KMP-NativeCoroutines"),
        .product(name: "KMPNativeCoroutinesCombine", package: "KMP-NativeCoroutines")
      ],
      path: "sources/SharedResources"
    ),
    .testTarget(
      name: "SharedResourcesTests",
      dependencies: ["SharedResources"],
      path: "tests"
    )
  ]
)
