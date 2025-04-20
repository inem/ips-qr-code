require 'ips_qr_code/version'
require 'ips_qr_code/utils'

module IpsQrCode
  ORDER = %i[k v c r n i sf s m js ro rl rp].freeze

  def self.generate(opts = {})
    opts = Utils.rename_keys(opts)
    opts = { k: 'PR', v: '01', c: '1' }.merge(opts)

    # Validate required fields
    %i[r n i sf].each do |field|
      raise ArgumentError, "Missing required #{field}" unless opts[field]
    end

    # Normalize and validate racun primaoca (r)
    opts[:r] = Utils.normalize_bank_account(opts[:r])
    unless opts[:r] =~ /^\d{18}$/ && Utils.validate_bank_account(opts[:r])
      raise ArgumentError, 'Invalid racunPrimaoca'
    end

    # Optional racun platioca (o)
    if opts[:o]
      opts[:o] = Utils.normalize_bank_account(opts[:o])
      unless opts[:o] =~ /^\d{18}$/ && Utils.validate_bank_account(opts[:o])
        raise ArgumentError, 'Invalid racunPlatioca'
      end
    end

    # Validate naziv primaoca (n)
    n = opts[:n].to_s
    if n.length < 1 || n.length > 70
      raise ArgumentError, 'nazivPrimaoca must be between 1 and 70 characters'
    end
    unless n.match?(/^[a-zA-ZšđžčćŠĐŽČĆ0-9 \(\)\{\}\[\]<>\/\.,:;!@#\$%\^&\?„""""'`''_~=+\-\s]+$/u)
      raise ArgumentError, 'nazivPrimaoca contains invalid characters'
    end
    if n.lines.count > 3
      raise ArgumentError, 'nazivPrimaoca must not contain more than 3 lines'
    end

    # Optional naziv platioca (p)
    if opts[:p]
      p = opts[:p].to_s
      if p.length > 70
        raise ArgumentError, 'nazivPlatioca must be at most 70 characters'
      end
    end

    # Validate iznos (i)
    i_val = opts[:i].to_s
    unless i_val.length.between?(5, 20) && i_val.match?(/^[A-Z]{3}[0-9]+,[0-9]{0,2}$/)
      raise ArgumentError, 'Invalid iznos format'
    end

    # Validate sifra placanja (sf)
    sf = opts[:sf].to_s
    unless sf.match?(/^[12][0-9]{2}$/)
      raise ArgumentError, 'Invalid sifraPlacanja'
    end

    # Optional svrha placanja (s)
    if opts[:s]
      s = opts[:s].to_s
      if s.length > 35
        raise ArgumentError, 'svrhaPlacanja must be at most 35 characters'
      end
    end

    # Optional merchant code category (m)
    if opts[:m]
      m = opts[:m].to_s
      unless m.match?(/^[0-9]{4}$/)
        raise ArgumentError, 'Invalid merchantCodeCategory'
      end
    end

    # Optional jednokratna sifra (js)
    if opts[:js]
      js = opts[:js].to_s
      unless js.match?(/^[0-9]{5}$/)
        raise ArgumentError, 'Invalid jednokratnaSifra'
      end
    end

    # Optional poziv na broj (ro)
    if opts[:ro]
      ro = opts[:ro].to_s
      if ro.length > 35
        raise ArgumentError, 'pozivNaBroj must be at most 35 characters'
      end
      ro = "00#{ro}" unless %w[97 22 11 00].include?(ro[0,2])
      unless Utils.validate_reference_number(ro)
        raise ArgumentError, 'Invalid pozivNaBroj'
      end
      opts[:ro] = ro
    end

    # Optional referenca primaoca (rl)
    if opts[:rl]
      rl = opts[:rl].to_s
      if rl.length > 140
        raise ArgumentError, 'referencaPrimaoca must be at most 140 characters'
      end
    end

    # Optional referenca placanja (rp)
    if opts[:rp]
      rp = opts[:rp].to_s
      unless rp.match?(/^[0-9]{19}$/)
        raise ArgumentError, 'Invalid referencaPlacanja'
      end
    end

    # Build IPS data string
    parts = ORDER.map do |key|
      val = opts[key]
      next unless val
      "#{key.to_s.upcase}:#{val.to_s.gsub('|', '-')}"
    end.compact

    parts.join('|')
  end
end