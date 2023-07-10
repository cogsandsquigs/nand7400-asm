![GitHub](https://img.shields.io/github/license/cogsandsquigs/nand7400?style=for-the-badge)
![CircleCI](https://img.shields.io/circleci/build/github/cogsandsquigs/nand7400/main?style=for-the-badge)

# nand7400

An assembler library for the nand7400 computer, created by me during my internship at [The WCL](https://thewcl.com).

This library is built in Rust, and also binds directly to Swift as well, so you can treat it like a standard Swift package (see [Usage: Swift](#swift)). Swift bindings are made because the nand7400 computer is mainly programmed via an iOS/MacOS app.

## Usage

### Rust

You can use this library as any other standard rust library, no strings attached. Just add it to your `Cargo.toml` and you're good to go.

### Swift

This library is _almost_ plug-and-play with `Xcode`. To use this with `Xcode`, you need to go into `Targets > (your build target) > Build Phases > Link Binary With Libraries` and add the `Nand7400` framework inside the `Nand7400` library (The framework is the icon that looks like a bank or museum under the package). Otherwise, you will get a `module not found` error, because `Xcode` doesn't know where to find the framework powering the library.

## Building

### Lay of the Land

To get started building, you should first familiarize yourself with the project structure. There are 3 main packages in this repository:

-   `nand7400`: The rust library itself. It has no dependencies to UniFFI or Swift, and is the core of the project.

-   `nand7400-ffi`: This is the binding library that is the glue between Rust and Swift. It does this through Mozilla's [UniFFI](https://github.com/mozilla/uniffi-rs), and it also contains a wrapper rust library that is used to execute `uniffi-bindgen` commands.

-   `nand7400-bindings/swift`: The Swift package that binds to the `nand7400` rust library. The package file for this is `Package.swift`.

### Rust

To build the rust library, simply run `cargo build` in the root directory of the project. You can use this library as any other standard rust library.

### Swift

> **_IMPORTANT!_**
>
> If you change the `uniffi` version in the `nand7400-ffi` package, you **_MUST_** change it **_EVERYWHERE_** else in the package. Otherwise, it will not compile correctly in Xcode (you will see a symbols missing/undefined error).

To build this library for Swift, you'll need a Mac with Xcode 12 or later that has the standard rust toolchain (`rustup` and `cargo`) installed. To build, run `make package-swift` -- this automatically calls `make setup-build` which sets up everything needed for building the package. This creates a `Nand7400FFI.xcframework` folder, a `Nand7400FFI.xcframework.zip` file, and a `Nand7400FFI.xcframework.zip.sha256` checksum in the `target` directory. You can then either upload `Nand7400FFI.xcframework.zip` to be downloaded by the package, or point the package binary target path to the `Nand7400FFI.xcframework` file.

When using this library, if `NAND7400_LOCAL` is set, then it will automatically search for a local build of the XCFramework. Otherwise, it will download the XCFramework from the Github release.

## Resources on how I did this

These are the resources I used to help me learn how to bind Rust into Swift:

-   [Creating an XCFramework](https://rhonabwy.com/2023/02/10/creating-an-xcframework/)
-   [UniFFI](https://mozilla.github.io/uniffi-rs/)
-   [The YSwift repository](https://github.com/y-crdt/yswift)

Maybe you'll find them helpful too!

## TODO:

-   [x] Add Swift bindings.
-   [x] Labels are 16 bits wide, not 8 (and count as 2 arguments respectively).
-   [x] Add fuzzing testing/support for the assembler.
-   [ ] Github/CircleCI(?) workflow for testing + building XCFramework and uploading it to Github.
-   [ ] Clean up code.
-   [ ] Add more tests.
