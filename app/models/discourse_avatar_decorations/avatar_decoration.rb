# frozen_string_literal: true

class AvatarDecoration < ActiveRecord::Base
    has_many :avatar_decoration_group_items, dependent: :destroy
    has_many :avatar_decoration_groups, through: :avatar_decoration_group_items
    
    validates :name, presence: true
    validates :image_url, presence: true
  end
  