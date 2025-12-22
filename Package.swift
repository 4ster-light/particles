// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "particles",
    products: [
        .executable(name: "particles", targets: ["particles"])
    ],
    dependencies: [
        .package(url: "https://github.com/STREGAsGate/Raylib.git", branch: "master")
    ],
    targets: [
        .executableTarget(
            name: "particles",
            dependencies: ["Raylib"]
        )
    ]
)
