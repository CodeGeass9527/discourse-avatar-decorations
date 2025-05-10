# frozen_string_literal: true

class AvatarDecorationsController < ApplicationController
    requires_login
    
    def available_for_user
      user = current_user
      
      # 获取用户通过装饰分组可用的装饰
      available_decorations = user.available_avatar_decorations
      
      render json: {   
        decorations: available_decorations.map { |d|
          {
            id: d.id,
            name: d.name,
            image_url: d.image_url
          }
        }
      }
    end
  end
  