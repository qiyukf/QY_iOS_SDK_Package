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
    
    s.vendored_frameworks = ['**/QYSDK.xcframework','**/QYKFNIMSDK.xcframework','**/QYKFNIMNOS.xcframework']

    qy_dsym_phase = {
        :name => '[QY] Copy SDK dSYMs to xcarchive',
        :execution_position => :after_compile,
        :shell_path => '/bin/sh',
        :script => <<~'SH'
            set -eu
            if [ "${ACTION:-}" != "install" ] || [ "${PLATFORM_NAME:-}" != "iphoneos" ] || [ -z "${DWARF_DSYM_FOLDER_PATH:-}" ]; then
                exit 0
            fi

            mkdir -p "${DWARF_DSYM_FOLDER_PATH}"
            for framework in QYSDK QYKFNIMSDK QYKFNIMNOS; do
                # 按 vendored_frameworks 的匹配范围查找原始包，兼容 SDK 和 NIMSDK 分目录交付。
                xcframework=$(/usr/bin/find -H "${PODS_TARGET_SRCROOT}" -name '*.xcframework' -prune -name "${framework}.xcframework" -print -quit)
                dsym="${framework}.framework.dSYM"
                source="${xcframework}/ios-arm64/dSYMs/${dsym}"
                if [ -z "${xcframework}" ] || [ ! -d "${source}" ]; then
                    echo "warning: [QY] Missing ${dsym} for iphoneos"
                    continue
                fi

                /usr/bin/ditto "${source}" "${DWARF_DSYM_FOLDER_PATH}/${dsym}"
            done
        SH
    }
    s.script_phases = [qy_dsym_phase]

    s.frameworks = 'AVFoundation', 'UIKit', 'SystemConfiguration', 'MobileCoreServices', 'WebKit', 'CoreTelephony', 'CoreText', 'CoreMedia', 'ImageIO', 'CoreMotion', 'AudioToolbox', 'Photos', 'AssetsLibrary', 'Accelerate'
    s.libraries = 'c++', 'z','sqlite3.0','xml2','resolv'
    s.resources  = ['**/Resources/QYResource.bundle', '**/Resources/QYLanguage.bundle', '**/Resources/QYCustomResource.bundle']
    s.pod_target_xcconfig = { 'VALID_ARCHS' => 'armv7 x86_64 arm64' }
    s.requires_arc = true

end

