# frozen_string_literal: true

# name: discourse-avatar-decorations
# about: Allows admins to create avatar decorations that users can select
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: https://github.com/CodeGeass9527/discourse-avatar-decorations
# required_version: 2.7.0


enabled_site_setting :avatar_decorations_enabled

register_asset "stylesheets/common/avatar-decorations.scss"
register_asset "stylesheets/desktop/avatar-decorations.scss", :desktop
register_asset "stylesheets/mobile/avatar-decorations.scss", :mobile

after_initialize do
  module ::AvatarDecorations
    PLUGIN_NAME = "discourse-avatar-decorations".freeze
    
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace AvatarDecorations
    end
  end
  
  # 扩展 User 模型
  add_to_class(:user, :avatar_decoration_groups) do
    UserAvatarDecorationGroup
      .where(user_id: self.id)
      .includes(:avatar_decoration_group)
      .map(&:avatar_decoration_group)
  end
  
  add_to_class(:user, :available_avatar_decorations) do
    return [] unless SiteSetting.avatar_decorations_enabled
    
    AvatarDecoration
      .joins(:avatar_decoration_groups)
      .where(avatar_decoration_groups: {
        id: UserAvatarDecorationGroup
              .where(user_id: self.id)
              .select(:avatar_decoration_group_id)
      })
      .distinct
  end
  
  # 用户自定义字段
  register_user_custom_field_type('selected_avatar_decoration_id', :integer)
  
  # 添加到用户序列化器
  add_to_serializer(:user, :avatar_decoration_url) do
    if SiteSetting.avatar_decorations_enabled && object.custom_fields['selected_avatar_decoration_id']
      decoration_id = object.custom_fields['selected_avatar_decoration_id'].to_i
      decoration = AvatarDecoration.find_by(id: decoration_id)
      decoration&.image_url
    else
      nil
    end
  end
  
  add_to_serializer(:user, :include_avatar_decoration_url?) do
    SiteSetting.avatar_decorations_enabled && 
    object.custom_fields['selected_avatar_decoration_id'].present?
  end
  
  # 添加以下帮助器方法到 ApplicationController
  add_to_class(:application_controller, :fetch_avatar_decoration) do |id|
    AvatarDecoration.find_by(id: id)
  end
  
  # 添加路由
  Discourse::Application.routes.append do
    namespace :admin, constraints: AdminConstraint.new do
      resources :avatar_decorations, constraints: StaffConstraint.new
      
      resources :avatar_decoration_groups, constraints: StaffConstraint.new do
        member do
          get 'users'
          post 'add_users'
          delete 'remove_user/:user_id' => 'avatar_decoration_groups#remove_user'
        end
      end
    end
    
    # 用户相关路由
    get "avatar-decorations/available" => "avatar_decorations#available_for_user"
    put "u/:username/preferences/avatar-decoration" => "users#update_avatar_decoration", 
        constraints: { username: USERNAME_ROUTE_FORMAT }
  end
  
  # 为用户控制器添加update_avatar_decoration方法
  ::UsersController.class_eval do
    def update_avatar_decoration
      user = fetch_user_from_params
      guardian.ensure_can_edit!(user)
      
      decoration_id = params[:decoration_id].to_i
      
      # 检查权限 - 用户是否可以使用该装饰
      if decoration_id > 0
        decoration = fetch_avatar_decoration(decoration_id)
        if decoration
          # 检查用户是否有权使用此装饰
          unless user.available_avatar_decorations.include?(decoration)
            return render_json_error(I18n.t("avatar_decorations.errors.not_allowed"))
          end
        else
          return render_json_error(I18n.t("avatar_decorations.errors.not_found"))
        end
      end
      
      # 保存用户选择
      user.custom_fields['selected_avatar_decoration_id'] = decoration_id > 0 ? decoration_id : nil
      user.save_custom_fields
      
      render json: success_json
    end
  end
end