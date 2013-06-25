class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.belongs_to :caller
      t.belongs_to :call
      t.string :globals
      t.string :verb
      t.string :params
      t.datetime :time
      t.integer :feed_level, :default=>30
      t.integer :storage_level, :default =>30
      t.integer :log_level, :default => 10
      t.integer :broadcast_level, :default => 30
      t.integer :lifetime, :default =>86400
      t.datetime :expires_at
      
      t.timestamps
    end
  end
end
