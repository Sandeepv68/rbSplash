# frozen_string_literal: true

require "spec_helper"

RSpec.describe RbSplash::WrapSplashError do
  describe "#initialize" do
    it "creates an error with a message" do
      error = described_class.new("Something went wrong")
      expect(error.message).to eq("Something went wrong")
      expect(error.status_code).to be_nil
      expect(error.status_text).to be_nil
      expect(error.cause_error).to be_nil
    end

    it "creates an error with status_code, status_text, and cause" do
      cause = StandardError.new("original")
      error = described_class.new(
        "Not Found",
        status_code: 404,
        status_text: "Not Found",
        cause: cause
      )
      expect(error.message).to eq("Not Found")
      expect(error.status_code).to eq(404)
      expect(error.status_text).to eq("Not Found")
      expect(error.cause_error).to eq(cause)
    end

    it "is a StandardError" do
      error = described_class.new("test")
      expect(error).to be_a(StandardError)
    end
  end
end
