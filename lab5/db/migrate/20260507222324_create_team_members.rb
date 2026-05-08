class CreateTeamMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :team_members do |t|
      t.string :name
      t.string :role
      t.integer :project_id

      t.timestamps
    end
  end
end
