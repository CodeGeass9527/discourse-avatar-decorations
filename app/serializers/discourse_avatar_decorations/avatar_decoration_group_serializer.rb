# frozen_string_literal: true

class AvatarDecorationGroupSerializer < ApplicationSerializer
    attributes :id, :name, :description, :decorations_count, :users_count
  
    def decorations_count
      object.avatar_decorations.count
    end
  
    def users_count
      object.users.count
    end
  end
  