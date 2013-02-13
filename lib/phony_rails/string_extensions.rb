  class String

    # Add a method to the String class so we can easily format phone numbers.
    # This enables:
    #   "31612341234".phony_formatted # => '06 12341234'
    #   "31612341234".phony_formatted(:spaces => '-') # => '06-12341234'
    def phony_formatted(options = {})
      if Phony.plausible?(self)
        Phony.formatted(self.gsub(/[^0-9]/,''), options.reverse_merge(:format => :national))
      end
    end

  end
