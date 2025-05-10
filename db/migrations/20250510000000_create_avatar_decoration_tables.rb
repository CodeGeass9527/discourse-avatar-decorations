# frozen_string_literal: true

class CreateAvatarDecorationTables < ActiveRecord::Migration[6.1]
    def change
       # 头像装饰
      create_table :avatar_decorations do |t|
        t.string :name, null: false, index: true
        t.string :image_url, null: false
        t.timestamps
      end
  
      # 头像装饰分组
      create_table :avatar_decoration_groups do |t|
        t.string :name, null: false, index: true
        t.text :description
        t.timestamps
      end
      
      # 头像装饰与分组的关系（一个分组可以包含多个装饰）
      create_table :avatar_decoration_group_items do |t|
        t.integer :avatar_decoration_id, null: false
        t.integer :avatar_decoration_group_id, null: false
        t.timestamps
      end
      
      # 用户与头像装饰分组的关系（用户可以属于多个装饰分组）
      create_table :user_avatar_decoration_groups do |t|
        t.integer :user_id, null: false
        t.integer :avatar_decoration_group_id, null: false
        t.timestamps
      end
      
      # 添加索引
      add_index :avatar_decoration_group_items, [:avatar_decoration_id, :avatar_decoration_group_id], 
                unique: true, name: 'idx_avatar_decoration_group_items'
      add_index :user_avatar_decoration_groups, [:user_id, :avatar_decoration_group_id], 
                unique: true, name: 'idx_user_avatar_decoration_groups'
    end
  end
  