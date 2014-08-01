module NCore
  class Collection < Array

    attr_accessor :metadata

    def more_results?
      metadata[:more_results]
    end

  end
end
