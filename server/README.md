
# 1. Clean previous bluild
```
cd SampleServer
swift package clean
rm -rf .build
```

# 2. Build

Follow "development version" if you test the server locally, not as a part of container.

## Development version
```
cd SampleServer
swift build
```
## Release version
```
cd SampleServer
swift build -c release
```
## Build from other directory (the project is in SampleServer)
```
swift build --package-path SampleServer --build-path SampleServer/.build
```

# 3. Xcode project

To generate Xcode project:
```
cd SampleServer
swift package generate-xcodeproj
```

# 4. Try to run it locally

## Run development version
```
.build/debug/SampleServer
```
## Run release version
```
.build/release/SampleServer
```
