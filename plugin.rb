# frozen_string_literal: true

# name: discourse-badge-avatar-frame
# about: Adds avatar frame decoration for badges
# version: 0.0.1
# meta_topic_id: TODO
# authors: CodeGeass9527
# url: https://github.com/CodeGeass9527/discourse-badge-avatar-frame
# required_version: 2.7.0

enabled_site_setting :avatar_frame_enabled

register_asset "stylesheets/avatar-frame.scss"

after_initialize do
  # 注册徽章自定义字段
  register_badge_custom_field_type("avatar_frame_enabled", :boolean)
  register_badge_custom_field_type("avatar_frame_url", :string, max_length: 1000)
  
  # 扩展Badge类，添加头像框相关方法
  add_to_class :badge, :avatar_frame_enabled do
    if custom_fields["avatar_frame_enabled"].nil?
      false
    else
      custom_fields["avatar_frame_enabled"] == "true"
    end
  end
  
  add_to_class :badge, :avatar_frame_enabled= do |value|
    self.custom_fields["avatar_frame_enabled"] = value ? "true" : "false"
  end
  
  add_to_class :badge, :avatar_frame_url do
    custom_fields["avatar_frame_url"]
  end
  
  add_to_class :badge, :avatar_frame_url= do |value|
    self.custom_fields["avatar_frame_url"] = value
  end
  
  # 扩展Badge序列化器，添加头像框字段
  add_to_serializer :badge, :avatar_frame_enabled do
    object.avatar_frame_enabled
  end
  
  add_to_serializer :badge, :avatar_frame_url do
    object.avatar_frame_url
  end
  
  # 创建头像框控制器
  module ::DiscourseBadges
    class AvatarFrameController < ::ApplicationController
      requires_login
      skip_before_action :check_xhr
      before_action :ensure_admin
      
      def update
        badge_id = params[:badge_id]
        badge = Badge.find(badge_id)
        
        # 更新徽章头像框设置
        badge.avatar_frame_enabled = params[:avatar_frame_enabled] == "true"
        badge.avatar_frame_url = params[:avatar_frame_url]
        badge.save_custom_fields(true)
        
        render json: success_json
      end
      
      def upload
        badge_id = params[:badge_id]
        badge = Badge.find(badge_id)
        
        # 处理上传
        params.require(:file)
        upload = UploadCreator.new(params[:file], "avatar_frame").create_for(current_user.id)
        
        if upload.present? && upload.persisted?
          badge.avatar_frame_url = upload.url
          badge.save_custom_fields(true)
          
          render json: { url: upload.url }
        else
          render json: { errors: upload.errors.full_messages }, status: 422
        end
      end
      
      private
      
      def ensure_admin
        raise Discourse::InvalidAccess.new unless current_user&.admin?
      end
    end
  end
  
  # 添加路由
  Discourse::Application.routes.append do
    put "/admin/badges/:badge_id/avatar_frame" => "discourse_badges/avatar_frame#update"
    post "/admin/badges/:badge_id/avatar_frame/upload" => "discourse_badges/avatar_frame#upload"
  end
  
  # 扩展用户序列化器，获取头像框URL
  add_to_serializer :user, :avatar_frame_url do
    # 获取用户当前佩戴的徽章中有头像框的
    frame_badge = UserBadge.where(user_id: object.id)
                           .joins(:badge)
                           .where("badges.enabled = true")
                           .order("badges.badge_type_id DESC")
                           .map(&:badge)
                           .find { |badge| badge.avatar_frame_enabled && badge.avatar_frame_url.present? }
    
    frame_badge&.avatar_frame_url
  end
  
  # 添加当前用户的头像框URL
  add_to_serializer :current_user, :avatar_frame_url do
    # 获取用户当前佩戴的徽章中有头像框的
    frame_badge = UserBadge.where(user_id: object.id)
                           .joins(:badge)
                           .where("badges.enabled = true")
                           .order("badges.badge_type_id DESC")
                           .map(&:badge)
                           .find { |badge| badge.avatar_frame_enabled && badge.avatar_frame_url.present? }
    
    frame_badge&.avatar_frame_url
  end
end