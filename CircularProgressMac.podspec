Pod::Spec.new do |s|
	s.name = 'CircularProgressMac'
	s.version = '0.1.2'
	s.summary = 'Circular progress indicator for macOS apps'
	s.license = 'MIT'
	s.homepage = 'https://github.com/sindresorhus/CircularProgress'
	s.social_media_url = 'https://twitter.com/sindresorhus'
	s.authors = { 'Sindre Sorhus' => 'sindresorhus@gmail.com' }
	s.source = { :git => 'https://github.com/sindresorhus/CircularProgress.git', :tag => "v#{s.version}" }
	s.source_files = 'Sources/**/*.swift'
	s.swift_version = '4.2'
	s.platform = :macos, '10.12'
end
