source 'https://github.com/CocoaPods/Specs.git'

def import_pods
    pod 'SwiftyJSON', '~> 3.1.1'
    pod 'SDWebImage', '~> 3.8.2'
    pod 'RxSwift', '~> 3.0.0'
    pod 'RxCocoa', '~> 3.0.0'
end

target 'PodcastApp_RxSwift' do
    platform :ios, '9.0'
    project 'PodcastApp_RxSwift'

    use_frameworks!

    import_pods

    target 'PodcastApp_RxSwiftTests' do
        inherit! :search_paths

        pod 'OCMock', '~> 3.3.1'
    end
end
