require_relative './lib/qeweney/version'

Gem::Specification.new do |s|
  s.name        = 'qeweney'
  s.version     = Qeweney::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'Qeweney - cross library HTTP request / response API'
  s.author      = 'Sharon Rosner'
  s.email       = 'sharon@noteflakes.com'
  s.files       = `git ls-files`.split
  s.homepage    = 'https://github.com/digital-fabric/qeweney'
  s.metadata    = {
    'source_code_uri' => 'https://github.com/digital-fabric/qeweney'
  }
  s.rdoc_options = ['--title', 'Qeweney', '--main', 'README.md']
  s.extra_rdoc_files = ['README.md']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.6'

  s.add_runtime_dependency      'escape_utils',   '1.3.0'

  s.add_development_dependency  'benchmark-ips',  '2.14.0'
  s.add_development_dependency  'minitest',       '5.25.4'
  s.add_development_dependency  'rake',           '13.2.1'
  s.add_development_dependency  'listen',         '3.9.0'
end
