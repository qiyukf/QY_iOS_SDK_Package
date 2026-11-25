Pod::Spec.new do |s|

    s.name     = 'QY_iOS_SDK_Package'
    s.version  = '9.3.41'
    s.license  = { :"type" => "Copyright",
                   :"text" => " Copyright 2021 Netease \n"}  
    s.summary  = '网易七鱼客服访客端 iOS SDK'
    s.homepage = 'https://qiyukf.com'
    s.author   = { 'qiyukf' => 'yunshangfu@126.com' }
    s.source   = { :git => 'https://github.com/qiyukf/QY_iOS_SDK_Package', :tag => "#{s.version}" }
    s.platform = :ios, '15.0'

    frameworks = %w[
        QYSDK.xcframework
        QYKFNIMSDK.xcframework
        QYKFNIMNOS.xcframework
    ]
    s.vendored_frameworks = frameworks
    s.frameworks = 'AVFoundation', 'UIKit', 'SystemConfiguration', 'MobileCoreServices', 'WebKit', 'CoreTelephony', 'CoreText', 'CoreMedia', 'ImageIO', 'CoreMotion', 'AudioToolbox', 'Photos', 'AssetsLibrary', 'Accelerate'
    s.libraries = 'c++', 'z','sqlite3.0','xml2','resolv'
    s.resources  = ['**/Resources/QYResource.bundle', '**/Resources/QYLanguage.bundle', '**/Resources/QYCustomResource.bundle']
    s.pod_target_xcconfig = { 'VALID_ARCHS' => 'armv7 x86_64 arm64' }
    s.requires_arc = true

    # 归档时使用各 framework 原始真机切片的 dSYM，避免 CocoaPods 中间目录覆盖符号文件。
    s.script_phase = {
        :name => '[QY] Copy SDK dSYMs to xcarchive',
        :execution_position => :after_compile,
        :shell_path => '/bin/sh',
        :script => "frameworks='#{frameworks.join(' ')}'\n" + <<~'SH'
            set -eu
            [ "${ACTION:-}" = "install" ] || exit 0
            [ "${PLATFORM_NAME:-}" = "iphoneos" ] || exit 0
            [ -n "${PODS_TARGET_SRCROOT:-}" ] && [ -n "${DWARF_DSYM_FOLDER_PATH:-}" ] || exit 0

            mkdir -p "$DWARF_DSYM_FOLDER_PATH"
            for framework in $frameworks; do
              symbols="${framework%.xcframework}.framework.dSYM"
              original="$PODS_TARGET_SRCROOT/$framework/ios-arm64/dSYMs/$symbols"
              [ -d "$original" ] || continue
              /usr/bin/ditto "$original" "$DWARF_DSYM_FOLDER_PATH/$symbols"
            done
        SH
    }

end

