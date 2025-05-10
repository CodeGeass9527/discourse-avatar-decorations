# frozen_string_literal: true

class Admin::AvatarDecorationsController < Admin::AdminController
  def index
    decorations = AvatarDecoration.all
    
    render json: {
      decorations: decorations.map { |d|
        {
          id: d.id,
          name: d.name,
          image_url: d.image_url
        }
      }
    }
  end
  
  def create
    decoration = AvatarDecoration.new(
      name: params[:name],
      image_url: params[:image_url]
    )
    
    if decoration.save
      render json: { success: true, decoration: { id: decoration.id, name: decoration.name, image_url: decoration.image_url } }
    else
      render json: { success: false, errors: decoration.errors.full_messages }, status: 422
    end
  end
  
  def update
    decoration = AvatarDecoration.find_by(id: params[:id])
    
    if decoration.nil?
      return render json: { success: false, error: I18n.t("avatar_decorations.errors.not_found") }, status: 404
    end
    
    if decoration.update(name: params[:name], image_url: params[:image_url])
      render json: { success: true }
    else
      render json: { success: false, errors: decoration.errors.full_messages }, status: 422
    end
  end
  
  def destroy
    decoration = AvatarDecoration.find_by(id: params[:id])
    
    if decoration.nil?
      return render json: { success: false, error: I18n.t("avatar_decorations.errors.not_found") }, status: 404
    end
    
    # 检查是否有用户正在使用此装饰
    user_count = User.where("user_custom_fields.name = 'selected_avatar_decoration_id' AND user_custom_fields.value = ?", decoration.id.to_s)
                    .joins(:_custom_fields)
                    .count
    
    if user_count > 0
      return render json: { 
        success: false, 
        error: I18n.t("avatar_decorations.errors.in_use", count: user_count) 
      }, status: 422
    end
    
    decoration.destroy
    render json: { success: true }
  end
end
