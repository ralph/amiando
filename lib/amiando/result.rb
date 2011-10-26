module Amiando

  ##
  # This object is intended to be used when an api will return value that is
  # not a resource object (a User, an Event, etc), but due to the delayed
  # nature of doing requests in parallel, can't be initialized from the beginning.
  #
  # After the object is populated, you can ask the result with the result
  # method.
  class Result
    include Amiando::Autorun

    attr_accessor :request, :response, :errors

    autorun :request, :response, :result, :errors

    def initialize(&block)
      @populator = block
    end

    def populate(response_body)
      if @populator.arity == 1
        @result = @populator.call(response_body)
      elsif @populator.arity == 2
        @result = @populator.call(response_body, self)
      end
    end
  end
end
