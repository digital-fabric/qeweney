require_relative './lib/qna/version'

Gem::Specification.new do |s|
  s.name        = 'qna'
  s.version     = QNA::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'QNA - cross library HTTP request / response API'
  s.author      = 'Sharon Rosner'
  s.email       = 'sharon@noteflakes.com'
  s.files       = `git ls-files`.split
  s.homepage    = 'http://github.com/digital-fabric/qna'
  s.metadata    = {
    "source_code_uri" => "https://github.com/digital-fabric/qna"
  }
  s.rdoc_options = ["--title", "QNA", "--main", "README.md"]
  s.extra_rdoc_files = ["README.md"]
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.6'

  s.add_runtime_dependency      'escape_utils',       '~>1.2.1'

  s.add_development_dependency  'rake',               '~>12.3.3'
  s.add_development_dependency  'minitest',           '~>5.11.3'
  s.add_development_dependency  'minitest-reporters', '~>1.4.2'
end
