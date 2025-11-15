# frozen_string_literal: true

class PermissionsController < ApplicationController
  before_action :set_permission, only: [:show, :edit, :update, :destroy]

  def index
    authorize Permission
    @pagy, @permissions = pagy(Permission.order(:name))
  end

  def show
    authorize @permission
  end

  def new
    @permission = Permission.new
    authorize @permission
  end

  def create
    @permission = Permission.new(permission_params)
    authorize @permission

    if @permission.save
      respond_to do |format|
        format.html { redirect_to permissions_path, notice: t("permissions.created_successfully") }
        format.turbo_stream do
          render turbo_stream: [
            turbo_flash(:success, "permissions.created_successfully"),
            close_modal
          ]
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("permission_form", partial: "form", locals: { permission: @permission })
        end
      end
    end
  end

  def edit
    authorize @permission
  end

  def update
    authorize @permission

    if @permission.update(permission_params)
      respond_to do |format|
        format.html { redirect_to permissions_path, notice: t("permissions.updated_successfully") }
        format.turbo_stream do
          render turbo_stream: [
            turbo_flash(:success, "permissions.updated_successfully"),
            close_modal
          ]
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("permission_form", partial: "form", locals: { permission: @permission })
        end
      end
    end
  end

  def destroy
    authorize @permission

    if @permission.destroy
      respond_to do |format|
        format.html { redirect_to permissions_path, notice: t("permissions.deleted_successfully") }
        format.turbo_stream do
          render turbo_stream: [
            turbo_flash(:success, "permissions.deleted_successfully"),
            turbo_stream.remove("permission_#{@permission.id}")
          ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to permissions_path, alert: t("permissions.deletion_failed") }
        format.turbo_stream do
          render turbo_stream: turbo_flash(:error, "permissions.deletion_failed")
        end
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
