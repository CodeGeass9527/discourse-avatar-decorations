# frozen_string_literal: true

class Admin::AvatarDecorationGroupsController < Admin::AdminController
    def index
      groups = AvatarDecorationGroup.all
      
      render json: {
        groups: groups.map { |g|
          {
            id: g.id,
            name: g.name,
            description: g.description,
            decorations_count: g.avatar_decorations.count,
            users_count: g.users.count
          }
        }
      }
    end
    
    def show
      group = AvatarDecorationGroup.find_by(id: params[:id])
      
      if group.nil?
        return render json: { success: false, error: I18n.t("avatar_decorations.errors.group_not_found") }, status: 404
      end
      
      render json: {
        group: {
          id: group.id,
          name: group.name,
          description: group.description,
          decorations: group.avatar_decorations.map { |d|
            {
              id: d.id,
              name: d.name,
              image_url: d.image_url
            }
          }
        }
      }
    end
    
    def create
      group = AvatarDecorationGroup.new(
        name: params[:name],
        description: params[:description]
      )
      
      if group.save
        update_decorations(group, params[:decoration_ids]) if params[:decoration_ids].present?
        render json: { success: true, group_id: group.id }
      else
        render json: { success: false, errors: group.errors.full_messages }, status: 422
      end
    end
    
    def update
      group = AvatarDecorationGroup.find_by(id: params[:id])
      
      if group.nil?
        return render json: { success: false, error: I18n.t("avatar_decorations.errors.group_not_found") }, status: 404
      end
      
      if group.update(name: params[:name], description: params[:description])
        update_decorations(group, params[:decoration_ids]) if params[:decoration_ids].present?
        render json: { success: true }
      else
        render json: { success: false, errors: group.errors.full_messages }, status: 422
      end
    end
    
    def destroy
      group = AvatarDecorationGroup.find_by(id: params[:id])
      
      if group.nil?
        return render json: { success: false, error: I18n.t("avatar_decorations.errors.group_not_found") }, status: 404
      end
      
      group.destroy
      render json: { success: true }
    end
    
    def users
      group = AvatarDecorationGroup.find_by(id: params[:id])
      
      if group.nil?
        return render json: { success: false, error: I18n.t("avatar_decorations.errors.group_not_found") }, status: 404
      end
      
      users = group.users
      
      render json: {
        users: users.map { |u| 
          {
            id: u.id,
            username: u.username,
            name: u.name,
            avatar_template: u.avatar_template
          }
        }
      }
    end
    
    def add_users
      group = AvatarDecorationGroup.find_by(id: params[:id])
      
      if group.nil?
        return render json: { success: false, error: I18n.t("avatar_decorations.errors.group_not_found") }, status: 404
      end
      
      user_ids = params[:user_ids] || []
      
      added_users = []
      errors = []
      
      user_ids.each do |user_id|
        user = User.find_by(id: user_id)
        next unless user
        
        if !UserAvatarDecorationGroup.exists?(user_id: user.id, avatar_decoration_group_id: group.id)
          begin
            UserAvatarDecorationGroup.create!(user_id: user.id, avatar_decoration_group_id: group.id)
            added_users << user.username
          rescue => e
            errors << { username: user.username, error: e.message }
          end
        else
          errors << { username: user.username, error: I18n.t("avatar_decorations.errors.already_in_group") }
        end
      end
      
      render json: { success: true, added_users: added_users, errors: errors }
    end
    
    def remove_user
      group = AvatarDecorationGroup.find_by(id: params[:id])
      
      if group.nil?
        return render json: { success: false, error: I18n.t("avatar_decorations.errors.group_not_found") }, status: 404
      end
      
      user = User.find_by(id: params[:user_id])
      
      if user.nil?
        return render json: { success: false, error: "User not found" }, status: 404
      end
      
      relation = UserAvatarDecorationGroup.find_by(
        user_id: user.id, 
        avatar_decoration_group_id: group.id
      )
      
      if relation
        relation.destroy
        render json: { success: true }
      else
        render json: { success: false, error: I18n.t("avatar_decorations.errors.not_in_group") }, status: 404
      end
    end
    
    private
    
    def update_decorations(group, decoration_ids)
      # 清除现有关联
      group.avatar_decoration_group_items.destroy_all
      
      # 添加新关联
      decoration_ids.each do |decoration_id|
        decoration = AvatarDecoration.find_by(id: decoration_id)
        if decoration
          AvatarDecorationGroupItem.create!(
            avatar_decoration_id: decoration.id,
            avatar_decoration_group_id: group.id
          )
        end
      end
    end
  end
  