# frozen_string_literal: true

module RbSplash
  class Response
    attr_reader :status, :status_text, :data

    def initialize(status:, status_text:, data:)
      @status = status
      @status_text = status_text
      @data = data
    end
  end
end
