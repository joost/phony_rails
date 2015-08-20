  class String

    # Usage:
    #   "+31 (0)30 1234 123".phony_normalized # => '+31301234123'
    #   "(0)30 1234 123".phony_normalized # => '301234123'
    #   "(0)30 1234 123".phony_normalized(country_code: 'NL') # => '301234123'
    def phony_normalized(options = {})
      raise ArgumentError, "Expected options to be a Hash, got #{options.inspect}" if not options.is_a?(Hash)
      options = options.dup
      PhonyRails.normalize_number(self, options)
    end

    # Add a method to the String class so we can easily format phone numbers.
    # This enables:
    #   "31612341234".phony_formatted # => '06 12341234'
    #   "31612341234".phony_formatted(:spaces => '-') # => '06-12341234'
    # To first normalize a String use:
    #   "010-12341234".phony_formatted(:normalize => :NL)
    # To return nil when a number is not correct (checked using Phony.plausible?) use
    #   "010-12341234".phony_formatted(strict: true)
    # When an error occurs during conversion it will return the original String.
    # To raise an error use:
    #   "somestring".phone_formatted(raise: true)
    def phony_formatted(options = {})
      raise ArgumentError, "Expected options to be a Hash, got #{options.inspect}" if not options.is_a?(Hash)
      options = options.dup
      normalize_country_code = options.delete(:normalize)
      s = (normalize_country_code ? PhonyRails.normalize_number(self, :default_country_code => normalize_country_code.to_s, :add_plus => false) : self.gsub(/\D/, ''))
      return if s.blank?
      return if options[:strict] && !Phony.plausible?(s)
      Phony.format(s, options.reverse_merge(:format => :national))
    rescue
      if options[:raise]
        raise
      else
        s
      end
    end

    # The bang method
    def phony_formatted!(options = {})
      raise ArgumentError, "The :strict options is only supported in the phony_formatted (non bang) method." if options[:strict]
      replace(self.phony_formatted(options))
    end

  end
