ROM::SQL.migration do
  up do
    extension :pg_triggers

    create_table :events do
      primary_key :id

      column :data,       :json, null: false
      column :type,       String, null: false
      column :status,     String, null: false
      column :created_at, DateTime

      foreign_key :secret_id, table: :secrets, type: String
    end

    pgt_created_at(
      :events,
      :created_at,
      function_name: :trigger_set_created_at,
      trigger_name:  :set_created_at
    )
  end

  down do
    drop_trigger(:events, :set_created_at)
    drop_table(:events)
  end
end
