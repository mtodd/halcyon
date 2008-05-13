class CreateRecords < Sequel::Migration
  def up
    create_table :records do
      primary_key :id
      varchar :url, :size => 4, :unique => true, :null => false
      text :data
    end
  end
  def down
    execute 'DROP TABLE records'
  end
end
