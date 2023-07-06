# This makefile is used to build the Nand7400Asm framework for iOS, macOS and Mac Catalyst. To use it, run `make

PACKAGE_NAME=nand7400asm
LIB_NAME=libnand7400asm.a
FRAMEWORK_NAME=Nand7400AsmFFI

BUILD_FOLDER=target
ARTIFACTS_FOLDER=target/uniffi-artifacts
XCFRAMEWORK_FOLDER=target/${FRAMEWORK_NAME}.xcframework
SWIFT_FOLDER=nand7400asm-swift

UNIFFI_CMD=cargo run -p uniffi-bindgen --
CARGO_FLAGS= --package ${PACKAGE_NAME} --features uniffi --locked --release

# Install all the necessary build targets to build for Mac, iOS and Mac Catalyst.
setup:
	@echo "▸ Install toolchains"
# 	iOS Simulator (Intel)
	rustup target add x86_64-apple-ios 
#	iOS Simulator (M1)
	rustup target add aarch64-apple-ios-sim
#	iOS Device 
	rustup target add aarch64-apple-ios 
#	macOS ARM/M1
	rustup target add aarch64-apple-darwin
#	macOS Intel/x86 
	rustup target add x86_64-apple-darwin 

clean:
	@echo ▸ Clean state
	rm -rf ${ARTIFACTS_FOLDER}
	rm -rf ${XCFRAMEWORK_FOLDER}
	mkdir -p ${ARTIFACTS_FOLDER}
	mkdir -p ${SWIFT_FOLDER}

bind: clean
	@echo "▸ Generate Swift Scaffolding Code"
#	cargo run -p uniffi-bindgen generate src/yniffi.udl --language swift --out-dir ${SWIFT_FOLDER}
#	nugmanoff [23.03.2023]: for some reason the above command only works for me when I prepend `generate` with `--`. Like above:
	${UNIFFI_CMD} generate ${PACKAGE_NAME}/src/lib.udl --language swift --out-dir ${SWIFT_FOLDER}

build: bind setup
	@echo "▸ Building for x86_64-apple-ios"
	CFLAGS_x86_64_apple_ios="-target x86_64-apple-ios" \
	cargo build --target x86_64-apple-ios ${CARGO_FLAGS}

	@echo "▸ Building for aarch64-apple-ios-sim"
	CFLAGS_aarch64_apple_ios="-target aarch64-apple-ios-sim" \
	cargo build --target aarch64-apple-ios-sim ${CARGO_FLAGS}

	@echo "▸ Building for aarch64-apple-ios"
	CFLAGS_aarch64_apple_ios="-target aarch64-apple-ios" \
	cargo build --target aarch64-apple-ios ${CARGO_FLAGS}

	@echo "▸ Building for aarch64-apple-darwin"
	CFLAGS_aarch64_apple_darwin="-target aarch64-apple-darwin" \
	cargo build --target aarch64-apple-darwin ${CARGO_FLAGS}

	@echo "▸ Building for x86_64-apple-darwin"
	CFLAGS_x86_64_apple_darwin="-target x86_64-apple-darwin" \
	cargo build --target x86_64-apple-darwin ${CARGO_FLAGS}

	@echo "▸ Building for x86_64-apple-ios-macabi"
	CFLAGS_x86_64_apple_ios="-target x86_64-apple-ios-macabi" \
	cargo +nightly build -Z build-std --target x86_64-apple-ios-macabi ${CARGO_FLAGS}

	@echo "▸ Building for aarch64-apple-ios-macabi"
	CFLAGS_aarch64_apple_ios="-target aarch64-apple-ios-macabi" \
	cargo +nightly build -Z build-std --target aarch64-apple-ios-macabi ${CARGO_FLAGS}

merge: build
	@echo "▸ Consolidating the headers and modulemaps for XCFramework generation"
	mkdir -p ${ARTIFACTS_FOLDER}/includes
	cp ${SWIFT_FOLDER}/${FRAMEWORK_NAME}.h ${ARTIFACTS_FOLDER}/includes
#	cp ${SWIFT_FOLDER}/${FRAMEWORK_NAME}.modulemap ${ARTIFACTS_FOLDER}/includes/${FRAMEWORK_NAME}.modulemap
	cp ${SWIFT_FOLDER}/${FRAMEWORK_NAME}.modulemap ${ARTIFACTS_FOLDER}/includes/module.modulemap

	mkdir -p ${ARTIFACTS_FOLDER}/ios-simulator/release
	@echo "▸ Lipo (merge) x86 and arm iOS simulator static libraries into a fat static binary"
	lipo -create  \
		./${BUILD_FOLDER}/x86_64-apple-ios/release/${LIB_NAME} \
		./${BUILD_FOLDER}/aarch64-apple-ios-sim/release/${LIB_NAME} \
		-output ${ARTIFACTS_FOLDER}/ios-simulator/release/${LIB_NAME}

	mkdir -p ${ARTIFACTS_FOLDER}/apple-darwin/release
	@echo "▸ Lipo (merge) x86 and arm macOS static libraries into a fat static binary"
	lipo -create  \
		./${BUILD_FOLDER}/x86_64-apple-darwin/release/${LIB_NAME} \
		./${BUILD_FOLDER}/aarch64-apple-darwin/release/${LIB_NAME} \
		-output ${ARTIFACTS_FOLDER}/apple-darwin/release/${LIB_NAME}

	mkdir -p ${ARTIFACTS_FOLDER}/mac-catalyst/release
	@echo "▸ Lipo (merge) x86 and arm macOS Catalyst static libraries into a fat static binary"
	lipo -create  \
		./${BUILD_FOLDER}/x86_64-apple-ios-macabi/release/${LIB_NAME} \
		./${BUILD_FOLDER}/aarch64-apple-ios-macabi/release/${LIB_NAME} \
		-output ${ARTIFACTS_FOLDER}/mac-catalyst/release/${LIB_NAME}

package: merge
	@echo "▸ Create XCFramework"
#	what docs there are:
#	xcodebuild -create-xcframework -help
#	https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
	xcodebuild -create-xcframework \
		-library ./${BUILD_FOLDER}/aarch64-apple-ios/release/${LIB_NAME} \
		-headers ./${ARTIFACTS_FOLDER}/includes \
		-library ./${ARTIFACTS_FOLDER}/ios-simulator/release/${LIB_NAME} \
		-headers ./${ARTIFACTS_FOLDER}/includes \
		-library ./${ARTIFACTS_FOLDER}/apple-darwin/release/${LIB_NAME} \
		-headers ./${ARTIFACTS_FOLDER}/includes \
		-library ./${ARTIFACTS_FOLDER}/mac-catalyst/release/${LIB_NAME} \
		-headers ./${ARTIFACTS_FOLDER}/includes \
		-output ./${XCFRAMEWORK_FOLDER}

#	Move modulemaps to the right place, so that the XCFramework can be used directly in Swift Package Manager
	mkdir -p ${XCFRAMEWORK_FOLDER}/ios-arm64/Modules
	mkdir -p ${XCFRAMEWORK_FOLDER}/ios-x86_64-simulator/Modules
	mkdir -p ${XCFRAMEWORK_FOLDER}/ios-arm64_x86_64-simulator/Modules
	mkdir -p ${XCFRAMEWORK_FOLDER}/ios-arm64_x86_64-maccatalyst/Modules
	mkdir -p ${XCFRAMEWORK_FOLDER}/macos-arm64_x86_64/Modules
	cp ${SWIFT_FOLDER}/${FRAMEWORK_NAME}.modulemap ${XCFRAMEWORK_FOLDER}/ios-arm64/Modules/module.modulemap
	cp ${SWIFT_FOLDER}/${FRAMEWORK_NAME}.modulemap ${XCFRAMEWORK_FOLDER}/ios-x86_64-simulator/Modules/module.modulemap
	cp ${SWIFT_FOLDER}/${FRAMEWORK_NAME}.modulemap ${XCFRAMEWORK_FOLDER}/ios-arm64_x86_64-simulator/Modules/module.modulemap
	cp ${SWIFT_FOLDER}/${FRAMEWORK_NAME}.modulemap ${XCFRAMEWORK_FOLDER}/ios-arm64_x86_64-maccatalyst/Modules/module.modulemap
	cp ${SWIFT_FOLDER}/${FRAMEWORK_NAME}.modulemap ${XCFRAMEWORK_FOLDER}/macos-arm64_x86_64/Modules/module.modulemap

	@echo "▸ Compress xcframework"
	ditto -c -k --sequesterRsrc --keepParent ${XCFRAMEWORK_FOLDER} ${XCFRAMEWORK_FOLDER}.zip

	@echo "▸ Compute checksum"
	swift package compute-checksum ${XCFRAMEWORK_FOLDER}.zip > ${XCFRAMEWORK_FOLDER}.zip.sha256


