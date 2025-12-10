# frozen_string_literal: true

class PermissionsController < ApplicationController
  before_action :authorize_admin!
  before_action :set_permission, only: [:show, :edit, :update, :destroy]

  def index
    @q = Permission.ransack(params[:q])
    @permissions = @q.result(distinct: true)
    @pagy, @permissions = pagy(@permissions, items: 25)
  end

  def show
    @roles = @permission.roles
  end

  def new
    @permission = Permission.new
  end

  def create
    @permission = Permission.new(permission_params)

    if @permission.save
      respond_to do |format|
        format.html { redirect_to @permission, notice: t('permissions.created') }
        format.turbo_stream { render turbo_stream: turbo_flash(:success, 'permissions.created') }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @permission.update(permission_params)
      respond_to do |format|
        format.html { redirect_to @permission, notice: t('permissions.updated') }
        format.turbo_stream { render turbo_stream: turbo_flash(:success, 'permissions.updated') }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @permission.destroy
      respond_to do |format|
        format.html { redirect_to permissions_url, notice: t('permissions.deleted') }
        format.turbo_stream { render turbo_stream: turbo_flash(:success, 'permissions.deleted') }
      end
    else
      respond_to do |format|
        format.html { redirect_to @permission, alert: t('permissions.delete_error') }
        format.turbo_stream { render turbo_stream: turbo_flash(:error, 'permissions.delete_error') }
      end
    end
  end

  private

  def set_permission
    @permission = Permission.find(params[:id])
  end

  def permission_params
    params.require(:permission).permit(:name, :description, :resource_type, :resource_id)
  end
end
