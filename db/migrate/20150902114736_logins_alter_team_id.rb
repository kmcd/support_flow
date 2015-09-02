class LoginsAlterTeamId < ActiveRecord::Migration
  def change
    execute 'ALTER TABLE logins ALTER COLUMN team_id TYPE integer USING (team_id::integer)'
    add_index :logins, :team_id
  end
end
