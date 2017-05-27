Pod::Spec.new do |s|
 s.name = 'Horus'
 s.version = '0.1'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'A swifty way to handle binary data.'
 s.homepage = 'https://caynan.org'
 s.social_media_url = 'https://twitter.com/caynanvls'
 s.authors = { "Caynan Sousa" => "me@caynan.org" }
 s.source = { :git => "https://github.com/cookiecutter-swift/Horus.git", :tag => "v"+s.version.to_s }
 s.platforms     = { :ios => "8.0", :osx => "10.10", :tvos => "9.0", :watchos => "2.0" }
 s.requires_arc = true

 s.default_subspec = "Core"
 s.subspec "Core" do |ss|
     ss.source_files  = "Sources/*.swift"
     ss.framework  = "Foundation"
 end

end
