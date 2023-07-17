# frozen_string_literal: true

require "spec_helper"

RSpec.describe Jambots::Clients::OpenAIClientClient do
  let(:open_ai_client) { instance_double(OpenAI::Client) }

  describe "#initialize" do
    it "initializes an OpenAI client" do
      allow(OpenAI::Client).to receive(:new).and_return(nil)

      described_class.new(api_key: "sample_api_key", request_timeout: 10)

      expect(OpenAI::Client).to have_received(:new).with(access_token: "sample_api_key", request_timeout: 10)
    end
  end

  xdescribe "#chat" do
    let(:client) { described_class.new(api_key: "test_api_key", request_timeout: 10) }
    let(:params) do
      {
        model: "the_model",
        messages: [{role: "user", content: "Hello, world!"}],
        temperature: 0.9
      }
    end
    let(:provider_response) do
      {"choices" => [{"message" => {"content" => "Response"}}]}
    end
    before do
      allow(client.provider_client).to receive(:chat).with(parameters: params).and_return(provider_response)
    end

    context "when the bot has a conversation" do
      it "returns the response text" do
        output = client.chat(**params)

        expect(output).to eq("Response")
      end
    end

    context "when the API response contains an error" do
      context "when the error code is 'invalid_api_key'" do
        let(:provider_response) do
          {
            "error" => {
              "code" => "invalid_api_key"
            }
          }
        end

        it "raises a ChatClientError with an appropriate error message" do
          expect {
            client.chat(**params)
          }.to raise_error(Jambots::ChatClientError, /Invalid OpenAI API key/)
        end
      end

      context "when the error code is 'max_tokens'" do
        let(:provider_response) do
          {
            "error" => {
              "code" => "max_tokens"
            }
          }
        end

        it "raises a ChatClientError with an appropriate error message" do
          expect {
            client.chat(**params)
          }.to raise_error(Jambots::ChatClientError, /Check the limitations of the model/)
        end
      end

      context "when error is not recognized (API error for instance)" do
        let(:provider_response) do
          {
            "error" => {
              "code" => "unknown_error",
              "message" => "An unknown error occurred"
            }
          }
        end

        it "raises a ChatClientError with the error message from the response" do
          expect {
            client.chat(**params)
          }.to raise_error(Jambots::ChatClientError, /An unknown error occurred/)
        end
      end
    end
  end
end
