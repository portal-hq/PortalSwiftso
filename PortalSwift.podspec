Pod::Spec.new do |s|
  s.name             = 'PortalSwift'
  s.version          = "3.0.7"
  s.summary          = "Portal's native Swift implementation"

  s.description      = "Portal's native Swift implementation"

  s.homepage         = 'https://portalhq.io'
  s.license          = { :type => 'MIT' }
  s.author           = 'Portal Labs, Inc.'
  s.source           = { :git => 'https://github.com/portal-hq/PortalSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.vendored_frameworks = "PortalSwift/Sources/Frameworks/Mpc.xcframework"


  s.source_files = 'PortalSwift/Sources/PortalSwift/**/*'

  s.dependency "GoogleSignIn", "~> 7.1.0"
  s.dependency "Starscream", "~> 4.0.7"
  s.dependency "AnyCodable-FlightSchool", "~> 0.6.7"

  s.test_spec 'Tests' do |test_spec|
    test_spec.requires_app_host = true
    test_spec.source_files = 'PortalSwift/Tests/**/*.{h,m,swift}'
  end
end
