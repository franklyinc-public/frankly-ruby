Gem::Specification.new do |s|
  s.name        = 'frankly_ruby'
  s.version     = '1.0.0'
  s.summary     = 'Frankly Ruby SDK'
  s.authors     = ['Michael Phox', 'Achille Roussel']
  s.files       = [
    'lib/franklyclient.rb',
    'lib/franklyclient/announcement.rb',
    'lib/franklyclient/auth.rb',
    'lib/franklyclient/files.rb',
    'lib/franklyclient/generic.rb',
    'lib/franklyclient/message.rb',
    'lib/franklyclient/rooms.rb',
    'lib/franklyclient/util.rb'
  ]
  s.homepage    =
    'https://github.com/franklyinc/frankly-gem/'
  s.license       = 'MIT'

  s.add_runtime_dependency 'io-console', '~> 0.4', '>= 0.4.2'
  s.add_runtime_dependency 'json', '~> 1.8', '>= 1.8.1'
  s.add_runtime_dependency 'jwt', '~> 1.4', '>= 1.4.1'
  s.add_runtime_dependency 'rest-client', '~> 1.8', '>= 1.8.0'

  s.add_development_dependency 'minitest', '~> 5.4', '>= 5.4.3'
  s.add_development_dependency 'rake', '~> 10.4', '>= 10.4.2'
end
