# frozen_string_literal: true

class AvatarDecorationGroupItem < ActiveRecord::Base
    belongs_to :avatar_decoration
    belongs_to :avatar_decoration_group
  end
  