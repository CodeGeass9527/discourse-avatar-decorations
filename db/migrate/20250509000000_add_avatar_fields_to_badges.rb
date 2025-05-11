# plugins/your-plugin/db/migrate/20250509000000_add_avatar_fields_to_badges.rb
class AddAvatarFieldsToBadges < ActiveRecord::Migration[6.1]
    def change
      add_column :badges, :avatar_frame_enabled, :boolean, default: false, null: false
      add_column :badges, :avatar_frame_url, :string
    end
end
