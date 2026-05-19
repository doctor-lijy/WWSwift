platform :ios, '14.0'
use_frameworks!

target 'WWSwift' do
  pod 'SnapKit', '~> 5.7'
  pod 'SDWebImage', '~> 5.19'
  # PHNet.xcframework 运行时依赖（公司内部 SDK，置于 Vendor/）
  pod 'AFNetworking', '~> 4.0'
end

target 'WWSwiftTests' do
  inherit! :search_paths
  # @testable import WWSwift 需要解析 App 对 SnapKit 的传递依赖
  pod 'SnapKit', '~> 5.7'
end
