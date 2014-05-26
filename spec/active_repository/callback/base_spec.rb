require 'spec_helper'
require 'active_repository/callback/base'

class Counter
  attr_reader :count

  def initialize
    @count = 0
  end

  def increase
    @count += 1
  end

  def decrease
    @count -= 1
  end

  def true
    true
  end

  def false
    false
  end
end

describe ActiveRepository::Callback::Base do
  let!(:counter) { Counter.new }
  let!(:method) { :increase }

  describe '.initialize' do
    it 'requires object and method parameters' do
      object = described_class.new(counter, method)

      expect(object).to be_a described_class
    end

    it 'accepts options as third parameter' do
      object = described_class.new(counter, method, {})

      expect(object).to be_a described_class
    end
  end

  describe '#call' do
    context 'when options attribute is empty' do
      subject { described_class.new(counter, method) }

      it 'runs the method' do
        expect(counter.count).to be(0)
        subject.call
        expect(counter.count).to be(1)
      end
    end

    context 'when options attribute is not empty' do
      describe 'and has an if option' do
        context 'and it resolves to true' do
          subject { described_class.new(counter, method, if: :true) }

          it 'runs the method' do
            subject.call
            expect(counter.count).to be(1)
          end
        end

        context 'and it resolves to false' do
          subject { described_class.new(counter, method, if: :false) }

          it 'does not run the method' do
            subject.call
            expect(counter.count).to be(0)
          end
        end
      end

      describe 'and has an unless option' do
        context 'and it resolves to true' do
          subject { described_class.new(counter, method, unless: :true) }

          it 'runs the method' do
            subject.call
            expect(counter.count).to be(0)
          end
        end

        context 'and it resolves to false' do
          subject { described_class.new(counter, method, unless: :false) }

          it 'does not run the method' do
            subject.call
            expect(counter.count).to be(1)
          end
        end
      end
    end
  end
end
