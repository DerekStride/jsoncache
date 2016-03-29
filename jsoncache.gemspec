Gem::Specification.new do |s|
  s.name        = 'jsoncache'
  s.version     = '0.6.0'
  s.date        = '2016-04-29'
  s.summary     = 'Simple JSON Caching'
  s.description = 'A simple JSON cache for caching data intended for use' \
    'with HTTP APIs.'
  s.authors     = ['Derek Stride']
  s.email       = 'djgstride@gmail.com'
  s.files       = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'https://github.com/DerekStride/jsoncache'
  s.license     = 'MIT'
  s.add_development_dependency 'rspec', '~> 3.4'
end
