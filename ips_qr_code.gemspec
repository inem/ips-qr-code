require_relative 'lib/ips_qr_code/version'

Gem::Specification.new do |spec|
  spec.name          = 'ips_qr_code'
  spec.version       = IpsQrCode::VERSION
  spec.authors       = ['ArtBIT']
  spec.email         = ['artbit@example.com']

  spec.summary       = 'Generate IPS QR Code data strings'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/ArtBIT/ips-qr-code'
  spec.license       = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['lib/**/*.rb', 'bin/*', 'README.md', 'LICENSE']
  end

  spec.executables   = ['ips-qr-code']
  spec.require_paths = ['lib']
end