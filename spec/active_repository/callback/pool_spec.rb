require 'spec_helper'
require 'active_repository/callback/base'
require 'active_repository/callback/pool'

describe ActiveRepository::Callback::Pool do
  let(:callback) { ActiveRepository::Callback::Base.new(Object.new, :to_s) }
  subject { described_class.new }

  describe '.initialize' do
    it 'return a Callback::Pool' do
      object = described_class.new

      expect(object).to be_a described_class
    end
  end

  describe '#get' do
    context 'when pool is blank' do
      it 'returns an empty array' do
        expect(subject.get('')).to eq []
      end

      it 'returns an empty array' do
        expect(subject.get()).to eq []
      end
    end

    context 'when pool does not exists' do
      it 'returns an empty array' do
        expect(subject.get('new_pool')).to eq []
      end
    end

    context 'when pool exists' do
      before do
        subject.add('new_pool', callback)
      end

      it 'returns the pool' do
        expect(subject.get('new_pool')).to eq [callback]
      end
    end
  end

  describe '#add' do
    context 'when pool is nil' do
      it 'returns false' do
        expect(subject.add(nil, callback)).not_to be
      end
    end

    context 'when object to be added is not a callback' do
      it 'returns false' do
        expect(subject.add('new_pool', 'a')).not_to be
      end
    end

    context 'when object to be added is already on the pool' do
      it 'returns false' do
        expect(subject.add('old_pool', callback)).to be
        expect(subject.add('old_pool', callback)).not_to be
      end
    end

    context 'when pool does not exist' do
      let!(:callback1) { ActiveRepository::Callback::Base.new(Object.new, 'to_s') }

      before do
        subject.add('new_pool', callback)
      end

      it 'returns true' do
        expect(subject.add('old_pool', callback)).to be
      end

      it 'creates the specified pool' do
        pool = subject.get('new_pool')

        expect(pool).to eq [callback]
      end

      it 'appends object to the pool' do
        subject.add('new_pool', callback1)

        pool = subject.get('new_pool')

        expect(pool).to eq [callback, callback1]
      end

      it 'adds object to the right pool' do
        subject.add('old_pool', callback1)

        expect(subject.get('new_pool')).to eq [callback]
        expect(subject.get('old_pool')).to eq [callback1]
      end
    end
  end
end
