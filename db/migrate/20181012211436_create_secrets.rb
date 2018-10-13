ROM::SQL.migration do
  up do
    extension :pg_triggers

    create_table :secrets do
      column :id,              String,    null: false, unique: true, primary_key: true
      column :expired,         'Boolean', null: false, default: false
      column :expiration_date, DateTime,  null: false
      column :secret,          String
      column :created_at,      DateTime
    end

    pgt_created_at(
      :secrets,
      :created_at,
      function_name: :trigger_set_created_at,
      trigger_name:  :set_created_at
    )

    create_trigger(
      :secrets,
      :set_uniq_id_trigger,
      :set_uniq_id,
      events: [:insert, :update],
      each_row: true
    )
  end

  down do
    drop_trigger(:secrets, :set_created_at)
    drop_trigger(:secrets, :set_uniq_id)

    drop_table(:secrets)
  end
end
