class CreateAuthSessions < ActiveRecord::Migration[7.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_enum :auth_session_status, ["success", "failed", "in_progress"]

    create_table :auth_sessions do |t|
      t.uuid :external_id
      t.jsonb :raw_response
      t.enum :status, enum_type: :auth_session_status, default: "in_progress", null: false
      t.references :account, foreign_key: true
      t.string :redirect_url
      t.string :url

      t.timestamps
    end
  end

  # There's no built in support for dropping enums, but you can do it manually.
  # You should first drop any table that depends on them.
  def down
    disable_extension "pgcrypto" if extension_enabled?("pgcrypto")

    drop_table :auth_sessions

    execute <<-SQL
    DROP TYPE auth_session_status;
    SQL
  end
end
