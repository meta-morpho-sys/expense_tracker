# frozen_string_literal: true

require_relative '../../../config/sequel'
require_relative '../../../app/ledger'

module ExpenseTracker

  describe Ledger, :aggregate_failures, :db do
    let(:ledger) { Ledger.new }
    let(:expense) do
      { payee: 'Starbucks',
        amount: 5.75,
        date: '2017-06-10' }
    end

    describe '#record' do
      context 'with a valid expense' do
        it 'successfully saves the expenses in the DB' do
          result = ledger.record(expense)

          expect(result).to be_success
          expect(DB[:expenses].all).to match [a_hash_including(
            id: result.expense_id,
            payee: 'Starbucks',
            amount: 5.75,
            date: Date.iso8601('2017-06-10')
          )]
        end
      end

      context 'when an expense lacks a payee' do
        it 'rejects an expense as invalid' do
          expense.delete(:payee)
          result = ledger.record(expense)

          expect(result).not_to be_success
          expect(result.expense_id).to eq nil
          expect(result.error_message).to include '`payee` is required'
          expect(DB[:expenses].count).to eq 0
        end
      end
    end

    describe '#expenses_on' do
      it 'returns all the expenses for the provided date' do
        result_1 = ledger.record(expense.merge(date: '2017-06-10'))
        result_2 = ledger.record(expense.merge(date: '2017-06-10'))
        result_3 = ledger.record(expense.merge(date: '2017-06-11'))

        expect(ledger.expenses_on('2017-06-10')).to contain_exactly(
          a_hash_including(id: result_1.expense_id),
          a_hash_including(id: result_2.expense_id)
        )
      end

      it 'returns a blank array when there are no matching expenses' do
        expect(ledger.expenses_on('2017-06-10')).to eq []
      end
    end
  end
end

