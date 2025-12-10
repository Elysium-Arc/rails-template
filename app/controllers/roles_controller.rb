# frozen_string_literal: true

class RolesController < ApplicationController
  before_action :authorize_admin!, except: [:show]
  before_action :set_role, only: [:show, :edit, :update, :destroy, :add_permission, :remove_permission]

  def index
    @q = Role.ransack(params[:q])
    @roles = @q.result(distinct: true)
    @pagy, @roles = pagy(@roles, items: 25)
  end

  def show
    @permissions = @role.permissions
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)

    if @role.save
      respond_to do |format|
        format.html { redirect_to @role, notice: t('roles.created') }
        format.turbo_stream { render turbo_stream: turbo_flash(:success, 'roles.created') }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @role.update(role_params)
      respond_to do |format|
        format.html { redirect_to @role, notice: t('roles.updated') }
        format.turbo_stream { render turbo_stream: turbo_flash(:success, 'roles.updated') }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @role.destroy
      respond_to do |format|
        format.html { redirect_to roles_url, notice: t('roles.deleted') }
        format.turbo_stream { render turbo_stream: turbo_flash(:success, 'roles.deleted') }
      end
    else
      respond_to do |format|
        format.html { redirect_to @role, alert: t('roles.delete_error') }
        format.turbo_stream { render turbo_stream: turbo_flash(:error, 'roles.delete_error') }
      end
    end
  end

  def add_permission
    permission = Permission.find(params[:permission_id])
    @role.grant_permission(permission)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_flash(:success, 'roles.permission_added') }
    end
  end

  def remove_permission
    permission = Permission.find(params[:permission_id])
    @role.revoke_permission(permission)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_flash(:success, 'roles.permission_removed') }
    end
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name, :description, :resource_type, :resource_id)
  end
end
