  class String

    # Add a method to the String class so we can easily format phone numbers.
    # This enables:
    #   "31612341234".phony_formatted # => '06 12341234'
    #   "31612341234".phony_formatted(:spaces => '-') # => '06-12341234'
    # To first normalize a String use:
    #   "010-12341234".phony_formatted(:normalize => :NL)
    # To return nil when a number is not correct (checked using Phony.plausible?) use
    #   "010-12341234".phony_formatted(strict: true)
    def phony_formatted(options = {})
      normalize_country_code = options.delete(:normalize)
      s = (normalize_country_code ? PhonyRails.normalize_number(self, :default_country_code => normalize_country_code.to_s) : self.gsub(/\D/, ''))
      return if s.blank?
      return if options[:strict] && !Phony.plausible?(s)
      Phony.format(s, options.reverse_merge(:format => :national))
    end

    # The bang method
    def phony_formatted!(options = {})
      replace(self.phony_formatted(options))
    end

  end
