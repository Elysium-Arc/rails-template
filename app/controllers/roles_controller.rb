# frozen_string_literal: true

class RolesController < ApplicationController
  before_action :set_role, only: [:show, :edit, :update, :destroy, :assign_permissions]

  def index
    authorize Role
    @pagy, @roles = pagy(Role.order(created_at: :desc))
  end

  def show
    authorize @role
  end

  def new
    @role = Role.new
    authorize @role
  end

  def create
    @role = Role.new(role_params)
    authorize @role

    if @role.save
      respond_to do |format|
        format.html { redirect_to roles_path, notice: t("roles.created_successfully") }
        format.turbo_stream do
          render turbo_stream: [
            turbo_flash(:success, "roles.created_successfully"),
            close_modal
          ]
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("role_form", partial: "form", locals: { role: @role })
        end
      end
    end
  end

  def edit
    authorize @role
  end

  def update
    authorize @role

    if @role.update(role_params)
      respond_to do |format|
        format.html { redirect_to roles_path, notice: t("roles.updated_successfully") }
        format.turbo_stream do
          render turbo_stream: [
            turbo_flash(:success, "roles.updated_successfully"),
            close_modal
          ]
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("role_form", partial: "form", locals: { role: @role })
        end
      end
    end
  end

  def destroy
    authorize @role

    if @role.destroy
      respond_to do |format|
        format.html { redirect_to roles_path, notice: t("roles.deleted_successfully") }
        format.turbo_stream do
          render turbo_stream: [
            turbo_flash(:success, "roles.deleted_successfully"),
            turbo_stream.remove("role_#{@role.id}")
          ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to roles_path, alert: t("roles.deletion_failed") }
        format.turbo_stream do
          render turbo_stream: turbo_flash(:error, "roles.deletion_failed")
        end
      end
    end
  end

  def assign_permissions
    authorize @role, :assign_permissions?

    permission_ids = params[:permission_ids] || []
    @role.permission_ids = permission_ids

    respond_to do |format|
      format.html { redirect_to @role, notice: t("roles.permissions_assigned") }
      format.turbo_stream do
        render turbo_stream: turbo_flash(:success, "roles.permissions_assigned")
      end
    end
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name, :description, :resource_type, :resource_id, permission_ids: [])
  end
end
