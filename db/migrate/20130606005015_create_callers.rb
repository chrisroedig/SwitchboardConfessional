class CreateCallers < ActiveRecord::Migration
  def change
    create_table :callers do |t|
      t.string :number
      t.datetime :last_call_at

      t.timestamps
    end
  end
end
