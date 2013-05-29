class CreateBidsLabels < ActiveRecord::Migration
  def change
    create_table :bids_labels do |t|
      t.integer :bid_id
      t.integer :label_id
    end
  end
end
