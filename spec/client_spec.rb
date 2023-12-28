# frozen_string_literal: true

RSpec.describe SlackInteractiveClient::Client do
  after do
    described_class.reset
  end

  describe '#configuration' do
    it 'creates a new instance of Configuration' do
      expect(described_class.configuration).to be_instance_of(SlackInteractiveClient::Configuration)
    end
  end

  describe '#reset' do
    it 'creates and assigns a new instance of Configuration' do
      configuration = described_class.configuration
      described_class.reset
      expect(described_class.configuration).not_to eq(configuration)
    end
  end

  describe '#configure' do
    let(:configuration_params) do
      { auth_token: "a-token", logger_instance: 'Rails logger' }
    end

    it 'creates a new instance of Configuration from block' do
      described_class.configure do |config|
        config.auth_token = configuration_params[:auth_token]
        config.logger_instance = configuration_params[:logger_instance]
      end

      expect(described_class.configuration.auth_token).to eq(configuration_params[:auth_token])
      expect(described_class.configuration.logger_instance).to eq(configuration_params[:logger_instance])
    end
  end

  describe '#version' do
    it 'has a version number' do
      expect(SlackInteractiveClient::VERSION).not_to be nil
    end
  end

  describe '#send_message' do
    let(:template_name) { :test_template }
    let(:args) { { some: 'argument' } }
    let(:compilation) do
      instance_double("SlackInteractiveClient::Message::Compilation", 
                      channel: 'C1234567890', 
                      blocks: [], 
                      csv?: false)
    end

    before do
      allow(SlackInteractiveClient::Message).to receive(:compile).and_return(compilation)
      allow_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
      allow_any_instance_of(Slack::Web::Client).to receive(:files_upload)
    end

    it 'compiles the message and sends it to Slack' do
      expect(SlackInteractiveClient::Message).to receive(:compile).with(template_name, args)
      expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).with(hash_including(:channel, :blocks, :as_user))
      described_class.send_message(template_name, args)
    end

    context 'when the compilation includes csv data' do
      let(:csv_data) do
        {
          csv: {
            content: 'id,name\n1,Test',
            title: 'Test CSV',
            filename: 'test.csv',
            comment: 'Here is your CSV!'
          }
        }
      end

      let(:compilation_with_csv) do
        instance_double("SlackInteractiveClient::Message::Compilation",
                        channel: 'C1234567890',
                        blocks: [],
                        csv?: true,
                        csv_data: csv_data)
      end

      it 'uploads a CSV file along with the message' do
        allow(SlackInteractiveClient::Message).to receive(:compile).and_return(compilation_with_csv)
        expect_any_instance_of(Slack::Web::Client).to receive(:files_upload).with(hash_including(:channels, :content, :title, :filename, :initial_comment, :as_user))
        described_class.send_message(template_name, args)
      end
    end

    context 'when Slack::Web::Api::Errors::SlackError is raised' do
      it 'rescues from Slack::Web::Api::Errors::SlackError' do
        allow(SlackInteractiveClient::Message).to receive(:compile).and_raise(Slack::Web::Api::Errors::SlackError.new('Error'))
        expect { described_class.send_message(template_name, args) }.to_not raise_error
      end
    end
  end
end
