class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :rec_url
      t.string :twillio_sid
      t.string :status
      t.integer :rec_length
      t.integer :play_count
      t.integer :play_length
      t.integer :caller_id
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end
  end
end
