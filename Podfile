platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

workspace 'Arcus.xcworkspace'

def rx
    pod 'RxSwift'
    pod 'RxCocoa'
end

def utils
    pod 'Swinject'
    pod 'SwinjectAutoregistration'
    pod 'SnapKit'
end

target 'Arcus' do
    project 'Arcus'
    rx
    target 'ArcusTests' do
        rx
    end

end

target 'ArcusExample' do
    project 'ArcusExample/ArcusExample'
    rx
    utils
    target 'ArcusExampleTests' do
        rx
        utils
    end
end
