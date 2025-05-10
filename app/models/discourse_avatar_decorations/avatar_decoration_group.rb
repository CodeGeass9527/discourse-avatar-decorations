# frozen_string_literal: true

class AvatarDecorationGroup < ActiveRecord::Base
    has_many :avatar_decoration_group_items, dependent: :destroy
    has_many :avatar_decorations, through: :avatar_decoration_group_items
    
    has_many :user_avatar_decoration_groups, dependent: :destroy
    has_many :users, through: :user_avatar_decoration_groups
    
    validates :name, presence: true
  end
  