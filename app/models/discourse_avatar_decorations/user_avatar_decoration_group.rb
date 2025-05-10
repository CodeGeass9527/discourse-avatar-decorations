# frozen_string_literal: true

class UserAvatarDecorationGroup < ActiveRecord::Base
    belongs_to :user
    belongs_to :avatar_decoration_group
  end
  