# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SlackInteractiveClient::Message::Compilation do
  let(:payload) { { blocks: [{ type: 'section', text: { type: 'mrkdwn', text: 'Test message' } }], channel: ['#general'] } }
  let(:csv_message) { true }
  let(:csv_data) { { header: ['Column1', 'Column2'], rows: [['Data1', 'Data2'], ['Data3', 'Data4']] } }

  subject(:compilation) { described_class.new(payload, csv_message, csv_data) }

  describe '#initialize' do
    it 'initializes with payload, csv_message, and csv_data' do
      expect(compilation.payload).to eq(payload)
      expect(compilation.csv_message).to be(csv_message)
      expect(compilation.csv_data).to eq(csv_data)
    end
  end

  describe '#blocks' do
    context 'when blocks are present in payload' do
      it 'returns a JSON representation of blocks' do
        expect(compilation.blocks).to eq(payload[:blocks].to_json)
      end
    end

    context 'when blocks are absent in payload' do
      let(:payload) { {} }

      it 'returns nil' do
        expect(compilation.blocks).to be_nil
      end
    end
  end

  describe '#channel' do
    it 'returns the first channel from the payload' do
      expect(compilation.channel).to eq(payload[:channel].first)
    end
  end

  describe '#csv?' do
    context 'when csv_message is true' do
      it 'returns true' do
        expect(compilation.csv?).to be_truthy
      end
    end

    context 'when csv_message is false' do
      let(:csv_message) { false }

      it 'returns false' do
        expect(compilation.csv?).to be_falsey
      end
    end
  end
end
