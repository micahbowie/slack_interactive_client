require 'spec_helper'

RSpec.describe SlackInteractiveClient::Message do
  let(:message) { described_class.new }

  describe '#define' do
    it 'defines a new template with the given block' do
      block_called = false
      described_class.define { block_called = true }
      expect(block_called).to be(true)
    end
  end

  describe '#compile' do
    before do
      described_class.define do
        template :test_template do
          text 'Test message'
        end
      end
    end

    it 'compiles the given template with arguments' do
      expect { described_class.compile(:test_template) }.not_to raise_error
    end

    it 'raises an error for an undefined template' do
      expect { described_class.compile(:undefined_template) }.to raise_error(ArgumentError)
    end
  end

  describe '#template' do
    it 'creates a new template with the given name and block' do
      block_called = false
      described_class.template(:new_template) { block_called = true }
      expect(block_called).to be(true)
    end
  end

  describe '#template' do
    it 'assigns a name and evaluates the block' do
      message.template(:test) { text 'Testing' }
      expect(message.name).to eq(:test)
    end
  end

  describe '#text' do
    it 'sets a text block' do
      message.text 'Hello world'
      compiled_message = message.compile

      expect(compiled_message.blocks).to include('Hello world')
    end
  end

  describe '#title' do
    it 'sets a title block' do
      message.title 'Title'
      compiled_message = message.compile

      expect(compiled_message.blocks).to include('*Title*')
    end
  end

  describe '#markdown_section' do
    it 'sets a markdown section block' do
      message.markdown_section 'Some *markdown* content'
      compiled_message = message.compile

      expect(compiled_message.blocks).to include('Some *markdown* content')
    end
  end

  describe '#environment' do
    it 'sets the environment' do
      message.environment('development')

      expect(message.instance_variable_get(:@environment)).to eq('development')
    end
  end

  describe '#channel' do
    it 'adds channels to the message' do
      message.channel('#general')
      message.channel('#random')
  
      expect(message.channels).to contain_exactly('#general', '#random')
    end
  end

  describe '#mention' do
    it 'formats user mentions' do
      message.mention('user1', 'user2')
      compiled_message = message.compile

      expect(compiled_message.payload[:blocks][0][:elements][0][:text]).to include('<user1> <user2>')
    end
  end

  describe '#csv_data' do
    it 'includes csv data when set to true' do
      message.csv_data(true)
      compiled_message = message.compile(csv: { headers: ['one', 'two'], rows: [['1', '2'], ['3', '4']] })

      expect(compiled_message.csv_data).to include(:csv)
    end
  end

  describe '#compile' do
    it 'compiles the message with blocks, channels, and tagged users' do
      message.text 'Hello world'
      message.channel '#general'
      message.mention 'user1'

      compiled_message = message.compile

      expect(compiled_message).to be_a(SlackInteractiveClient::Message::Compilation)
      expect(compiled_message.channel).to eq('#general')
    end
  end

  describe '#reset_message_blocks' do
    it 'clears all message blocks' do
      message.text 'Hello world'
      message.compile

      expect(message.blocks).not_to be_empty

      message.reset_message_blocks

      expect(message.blocks).to be_empty
    end
  end

  describe '#compile' do
    subject(:message) { described_class.new }

    let(:args) do
      {
        text: 'Hello, World!',
        title: 'Test Message',
        markdown: 'Some *markdown* content',
        channel: '#general',
        users: ['@user1', '@user2'],
        csv: {
          headers: ['header1', 'header2'],
          rows: [['row1data1', 'row1data2'], ['row2data1', 'row2data2']],
        }
      }
    end

    before do
      message.environment('test')
      message.channel(args[:channel])
      message.mention(args[:users])
      message.text(args[:text])
      message.title(args[:title])
      message.markdown_section(args[:markdown])
      message.csv_data(true)
    end

    it 'compiles the message payload with given arguments' do
      compilation = message.compile(args)

      expect(compilation).to be_an_instance_of(SlackInteractiveClient::Message::Compilation)
      expect(compilation.blocks).to include('Hello, World!')
      expect(compilation.blocks).to include('Test Message')
      expect(compilation.blocks).to include('Some *markdown* content')
      expect(compilation.csv_data).to match(hash_including(:csv))
      expect(compilation.channel).to eq(args[:channel])
    end
  end
end
