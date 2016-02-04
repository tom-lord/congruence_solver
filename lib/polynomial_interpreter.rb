class PolynomialInterpreter
  PolynomialInterpreterError = Class.new(ArgumentError)
  PolynomialInvalid = Class.new(PolynomialInterpreterError)
  class CongruenceInvalid < PolynomialInterpreterError
    def message
      "Congruence invalid: congruences must be of form:\n(lhs polynomial) = (rhs polynomial) mod (modulus)"
    end
  end
  class LhsPolynomialInvalid < PolynomialInvalid
    def message
      "Left hand polynomial invalid: polynomials must be of form: ax^b+cx^d...\n(integer coefficients, positive integer exponents, order irrelevant)"
    end
  end
  class RhsPolynomialInvalid < PolynomialInvalid
    def message
      "Right hand polynomial invalid: polynomials must be of form: ax^b+cx^d...\n(integer coefficients, positive integer exponents, order irrelevant)"
    end
  end
  class ModInvalid < PolynomialInterpreterError
    def message
      "Mod invalid: modulus must be an integer greater than 2"
    end
  end


  def self.read_congruence(input_congruence)
    match_data = input_congruence.match(/^(.*)=(.*) +(?:mod +(.*)|\(mod +(.*)\))$/)

    if match_data.nil?
      raise CongruenceInvalid
    end

    lhs = match_data[1]
    rhs = match_data[2]
    mod = match_data[3] || match_data[4]

    begin
      lh_coeffs = read_coeffs(lhs.gsub(" ", ""))
    rescue PolynomialInvalid
      raise LhsPolynomialInvalid
    end

    begin
      rh_coeffs = read_coeffs(rhs.gsub(" ", ""))
    rescue PolynomialInvalid
      raise RhsPolynomialInvalid
    end

    if mod !~ /\d+/ or mod.to_i < 2
      raise ModInvalid
    end

    0.upto rh_coeffs.length-1 do |idx|
      unless rh_coeffs[idx].nil?
        lh_coeffs[idx] ||= 0
        lh_coeffs[idx] -= rh_coeffs[idx]
      end
    end

    [lh_coeffs, mod.to_i]
  end

  def self.read_coeffs(input_polynomial)
    if input_polynomial == ""
      raise PolynomialInvalid
    end

    last_var = nil
    coeffs = Array.new

    loop do
      input_polynomial.slice!(/^(\d+)\*?/)
      match_data_coe = Regexp.last_match

      input_polynomial.slice!(/^([a-zA-Z])(?:\^(\d+))?/)
      match_data_exp = Regexp.last_match

      if match_data_coe.nil? and match_data_exp.nil?
        raise PolynomialInvalid
      else
        if match_data_exp.nil?
          coe = match_data_coe[1].to_i
          exp = 0
        else
          unless last_var.nil? or last_var == match_data_exp[1]
            raise PolynomialInvalid
          end

          last_var = match_data_exp[1]

          if match_data_coe.nil?
            coe = 1
          else
            coe = match_data_coe[1].to_i
          end

          if match_data_exp[2].nil?
            exp = 1
          else
            exp = match_data_exp[2].to_i
          end
        end
      end

      coeffs[exp] ||= 0
      coeffs[exp] += coe.to_i

      break if input_polynomial.length == 0

      op = input_polynomial.slice!(0)

      unless op.match /[-+]/
        raise PolynomialInvalid
      end
    end

    0.upto(coeffs.length-1) do |idx|
      coeffs[idx] ||= 0
    end

    coeffs
  end
end
