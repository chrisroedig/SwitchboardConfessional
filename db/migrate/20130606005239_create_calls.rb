class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :rec_url
      t.integer :rec_length
      t.integer :caller_id
      t.timestamps
    end
  end
end
