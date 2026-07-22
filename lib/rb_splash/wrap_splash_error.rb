# frozen_string_literal: true

module RbSplash
  class WrapSplashError < StandardError
    attr_reader :status_code, :status_text, :cause_error

    def initialize(message, status_code: nil, status_text: nil, cause: nil)
      super(message)
      @status_code = status_code
      @status_text = status_text
      @cause_error = cause
    end
  end
end
