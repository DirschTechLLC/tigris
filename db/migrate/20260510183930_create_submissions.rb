class CreateSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :submissions do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :api_key, null: false, foreign_key: true
      t.jsonb :payload, null: false, default: {}
      t.string :remote_ip
      t.string :user_agent
      t.string :referrer

      t.timestamps
    end

    add_index :submissions, [ :organization_id, :created_at ]
  end
end
