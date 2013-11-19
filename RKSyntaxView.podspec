Pod::Spec.new do |s|
  s.name     = 'RKSyntaxView'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'Syntax highlighting view'
  s.homepage = 'https://github.com/vojto/RKSyntaxView'
  s.source   = { :git => 'git://github.com/vojto/RKSyntaxView.git' }

  s.source_files = ['RKSyntaxView/*.m', 'RKSyntaxView/*.h']
end
