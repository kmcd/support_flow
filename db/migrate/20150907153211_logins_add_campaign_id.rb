class LoginsAddCampaignId < ActiveRecord::Migration
  def change
    add_column :logins, :campaign, :string
  end
end
