Pod::Spec.new do |s|
  s.name             = "Arcus"
  s.version          = "0.0.1"
  s.summary          = "Toolkit for iOS/macOS apps architecture"
  s.homepage         = "https://github.com/hmazelier/Arcus"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Hadrien Mazelier" => "hadrien.mazelier@supinfo.com" }
  s.source           = { :git => "https://github.com/hmazelier/Arcus.git",
                         :tag => s.version.to_s }
  s.source_files = "Arcus/*.{swift,h,m}"
  s.frameworks   = "Foundation"
  s.dependency "RxSwift", ">= 4.0.0"
  s.dependency "RxCocoa", ">= 4.0.0"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
end
