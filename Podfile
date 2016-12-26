#platform :ios, '8.0'
platform :ios, '10.0'


inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'



target 'zither' do
    pod 'AFNetworking', '2.5.1'
    pod 'ReactiveCocoa', '2.2.4'
    pod 'BZGFormViewController'
    pod 'Parse',                '~> 1.14.2' # 1.12 also is compatible as per: https://parse.com/migration Step 7. Point Client to Local Parse Server
    pod 'ZBarSDK'
    pod 'Intercom'
    pod 'SVProgressHUD'
    pod 'CocoaLumberjack'
    pod 'Reader', :git => 'https://github.com/vfr/Reader.git'
    #pod 'FormatterKit'
    pod 'SDWebImage'
    
    target 'zither-dev' do
        inherit! :search_paths
    end
end