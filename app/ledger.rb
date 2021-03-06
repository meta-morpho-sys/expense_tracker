# frozen_string_literal: true

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    EXPENSES = DB[:expenses]

    def record(expense)
      data = %i[payee amount date]
      data.each do |data|
        unless expense.key?(data)
          message = "Invalid expense: `#{data}` is required"
          return RecordResult.new(false, nil, message)
        end
      end
      id = EXPENSES.insert(expense)
      RecordResult.new(true, id, nil)
    end

    def expenses_on(date)
      EXPENSES.where(date: date).all
    end
  end
end
