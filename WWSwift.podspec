Pod::Spec.new do |s|
    s.name             = 'WWSwift'
    s.version          = '0.1.0'
    s.summary          = 'WEEX iOS Swift 组件库'
    s.description      = 'WEEX iOS 项目 Swift 工具与 UI 组件集合，可作为 CocoaPods 本地或远程依赖使用。'
    s.homepage         = 'https://github.com/doctor-lijy/WWSwift'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'doctor-lijy' => 'dodo107512@weexdev.com' }
    s.source           = { :git => 'https://github.com/doctor-lijy/WWSwift.git', :tag => s.version.to_s }

    s.ios.deployment_target = '14.0'
    s.swift_version = '5.0'

    s.source_files = 'SourceCode/**/*'
end
