platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

workspace 'Arcus.xcworkspace'

def rx
    pod 'RxSwift'
    pod 'RxCocoa'
end

target 'Arcus' do
    project 'Arcus'
    rx
    target 'ArcusTests' do
        rx
    end

end
