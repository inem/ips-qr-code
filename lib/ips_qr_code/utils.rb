module IpsQrCode
  module Utils
    RENAME_KEYS = {
      'kod'                   => :k,
      'verzija'               => :v,
      'version'               => :v,
      'characterEncodingType' => :c,
      'znakovniSkup'          => :c,
      'racunPrimaoca'         => :r,
      'nazivPrimaoca'         => :n,
      'iznos'                 => :i,
      'nazivPlatioca'         => :p,
      'sifraPlacanja'         => :sf,
      'svrhaPlacanja'         => :s,
      'merchantCodeCategory'  => :m,
      'jednokratnaSifra'      => :js,
      'pozivNaBroj'           => :ro,
      'referencaPrimaoca'     => :rl,
      'referencaPlacanja'     => :rp
    }.freeze

    def self.rename_keys(opts)
      result = {}
      opts.each do |key, value|
        key_str = key.to_s
        new_key = RENAME_KEYS[key_str] || key_str.to_sym
        result[new_key] = value
      end
      result
    end

    def self.normalize_bank_account(input)
      numerals = input.to_s.gsub(/\D/, '')
      bank     = numerals[0,3]
      control  = numerals[-2,2] || numerals[-2..-1]
      account  = numerals[3...-2] || ''
      "#{bank}#{account.rjust(13, '0')}#{control}"
    end

    def self.modulo(divident, divisor)
      div     = divident.to_s
      divisor = divisor.to_i
      while div.length > 10
        part = div[0,10].to_i
        div  = (part % divisor).to_s + div[10..-1]
      end
      div.to_i % divisor
    end

    def self.calculate_bank_account_control_number(input)
      98 - modulo(input[0...-2] + '00', 97)
    end

    def self.validate_bank_account(input)
      normalized        = normalize_bank_account(input)
      control_number    = normalized[-2,2]
      calculated_number = calculate_bank_account_control_number(normalized).to_s.rjust(2, '0')
      control_number == calculated_number
    end

    def self.validate_reference_number(input)
      return true if input.nil? || input.to_s.empty?
      input_str = input.to_s
      model     = input_str[0,2]
      case model
      when '97'
        sanitized = sanitize97(input_str)
        control   = sanitized[2,2]
        poziv     = sanitized[4..-1]
        control.to_i == mod97(poziv)
      when '22'
        sanitized = sanitize22(input_str)
        poziv     = sanitized[5...-1]
        control   = sanitized[-1]
        control.to_i == mod22(poziv)
      when '00'
        true
      else
        warn "Model #{model} is not supported."
        true
      end
    end

    def self.sanitize97(input)
      input.to_s.upcase.gsub(/[ \-]/, '').chars.map.with_index do |char, idx|
        code = char.ord
        if code.between?(65, 90)
          (code - 55).to_s
        elsif code.between?(48, 57)
          (code - 48).to_s
        else
          raise ArgumentError, "Invalid character \"#{char}\" at position #{idx}"
        end
      end.join
    end

    def self.sanitize22(input)
      input.to_s.gsub(/[ \-]/, '').chars.map.with_index do |char, idx|
        code = char.ord
        if code.between?(48, 57)
          (code - 48).to_s
        else
          raise ArgumentError, "Invalid character \"#{char}\" at position #{idx}"
        end
      end.join
    end

    def self.mod97(input)
      control = 0
      base    = 100
      input.to_s.reverse.chars.map(&:to_i).each do |char|
        control = (control + base * char) % 97
        base    = (base * 10) % 97
      end
      98 - control
    end

    def self.mod22(input)
      control = input.to_s.reverse.chars.map(&:to_i).each_with_index.reduce(0) do |sum,(char, idx)|
        sum + (idx + 1) * char
      end
      control = 11 - (control % 11)
      control % 10
    end
  end
end