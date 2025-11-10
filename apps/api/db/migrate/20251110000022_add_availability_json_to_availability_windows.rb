class AddAvailabilityJsonToAvailabilityWindows < ActiveRecord::Migration[8.0]
  def change
    add_column :availability_windows, :availability_json, :jsonb, default: {}
    add_column :availability_windows, :timezone, :string
    
    # GIN index for JSONB queries
    add_index :availability_windows, :availability_json, using: :gin
    
    # Index for timezone queries
    add_index :availability_windows, :timezone
  end
end

