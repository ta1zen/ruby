class Project < ApplicationRecord
  enum :status, { planned: 0, in_progress: 1, completed: 2, cancelled: 3 }

  validates :title, :client, :start_date, :deadline, :budget, presence: true
  validates :budget, numericality: { greater_than_or_equal_to: 0 }
end
