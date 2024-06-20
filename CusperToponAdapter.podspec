Pod::Spec.new do |s|
  s.name             = 'CusperToponAdapter'
  s.version          = '1.0.0'
  s.summary          = 'A short description of CusperToponAdapter.'
  s.description      = <<-DESC
                       A more detailed description of CusperToponAdapter.
                       DESC
  s.homepage         = 'https://github.com/Zinco09172/CusperToponAdapter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cusper' => 'nikohouse0917@gmail.com' }
  s.source           = { :git => 'https://github.com/Zinco09172/CusperToponAdapter.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'

  s.source_files     = 'CusperToponAdapter/**/*.{h,m,swift}'
  s.public_header_files = 'CusperToponAdapter/**/*.h'

  # 这里指定生成的 XCFramework 的路径
  s.vendored_frameworks = 'build/CusperToponAdapter.xcframework'

  # 如果有依赖项，可以在这里指定
  
 
  
end
