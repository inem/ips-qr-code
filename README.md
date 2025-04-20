# IPS QR Code Generator (Ruby)

Gem to generate IPS QR code formatted strings.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ips_qr_code'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ips_qr_code

## Usage

```ruby
require 'ips_qr_code'

data = IpsQrCode.generate(
  r: '845000000014284968',                  # racun primaoca
  n: 'EPS Snabdevanje 11000 Beograd',       # naziv primaoca
  sf: '221',                                # sifra placanja
  i: 'RSD1000,00'                           # iznos
  # optional:
  # k: 'PR',                                # kod
  # v: '01',                                # verzija
  # c: '1',                                 # kodni raspored
  # o: '200000000012345600',                # racun platioca
  # p: 'Marko Markovic',                    # naziv platioca
  # s: 'Uplata po racunu',                  # svrha placanja
  # m: '1234',                              # merchantCodeCategory
  # js: '12345',                            # jednokratnaSifra
  # ro: '97123456789',                      # pozivNaBroj
  # rl: 'ref primaoca',                     # referencaPrimaoca
  # rp: '1234567890123456789'               # referencaPlacanja
)
puts data
```

### CLI

```bash
$ ips-qr-code --racun-primaoca 845000000014284968 \
    --naziv-primaoca "EPS Snabdevanje 11000 Beograd" \
    --sifra-placanja 221 \
    --iznos RSD1000,00
# => K:PR|V:01|C:1|R:845000000014284968|N:EPS Snabdevanje...
```