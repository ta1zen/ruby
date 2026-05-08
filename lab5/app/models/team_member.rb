class TeamMember < ApplicationRecord
  validates :name, :project_id, presence: true
end
