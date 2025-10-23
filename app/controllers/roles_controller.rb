# frozen_string_literal: true

class RolesController < ApplicationController
  include FilterableIndex

  before_action :set_role, only: %i[show edit update destroy]
  before_action :persist_filters, only: :index

  def index
    authorize Role
    @roles = filterable_index(
      Role,
      base_scope: policy_scope(Role).includes(:permissions, :users),
      custom_filters: [
        { attribute: :name, type: :string },
        { attribute: :resource_type, type: :string },
        { attribute: :created_at, type: :datetime_range },
        { attribute: :updated_at, type: :datetime_range }
      ]
    )
  end

  def show
    authorize @role
    render layout: false
  end

  def new
    @role = Role.new
    authorize @role
    render layout: false
  end

  def edit
    authorize @role
    render layout: false
  end

  def create
    @role = Role.new(role_params)
    authorize @role

    if @role.save
      respond_to do |format|
        format.turbo_stream do
          reload_table_data

          render turbo_stream: [
            turbo_stream.replace(
              "roles-table",
              partial: "roles/table",
              locals: {
                roles: @roles,
                pagy: @pagy,
                filters: @filters,
                active_filter_keys: @active_filter_keys,
                custom_params: current_filters
              }
            ),
            turbo_flash(:notice, "roles.messages.created"),
            close_modal
          ]
        end
        format.html { redirect_to roles_path, notice: t("roles.messages.created") }
      end
    else
      render :new, status: :unprocessable_entity, layout: false
    end
  end

  def update
    authorize @role

    if @role.update(role_params)
      respond_to do |format|
        format.turbo_stream do
          reload_table_data

          render turbo_stream: [
            turbo_stream.replace(
              "roles-table",
              partial: "roles/table",
              locals: {
                roles: @roles,
                pagy: @pagy,
                filters: @filters,
                active_filter_keys: @active_filter_keys,
                custom_params: current_filters
              }
            ),
            close_modal,
            turbo_flash(:success, "roles.messages.updated")
          ]
        end
        format.html { redirect_to roles_path, notice: t("roles.messages.updated") }
      end
    else
      render :edit, status: :unprocessable_entity, layout: false
    end
  end

  def destroy
    authorize @role
    @role.destroy
    respond_to do |format|
      format.turbo_stream do
        reload_table_data

        render turbo_stream: [
          turbo_stream.replace(
            "roles-table",
            partial: "roles/table",
            locals: {
              roles: @roles,
              pagy: @pagy,
              filters: @filters,
              active_filter_keys: @active_filter_keys,
              custom_params: current_filters
            }
          ),
          close_modal,
          turbo_flash(:success, "roles.messages.deleted")
        ]
      end
      format.html { redirect_to roles_path, notice: t("roles.messages.deleted") }
    end
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name, :description, :resource_type, :resource_id, permission_ids: [])
  end

  # Reload table data with preserved filters, sorting, and pagination
  def reload_table_data
    @roles = filterable_index(
      Role,
      base_scope: policy_scope(Role).includes(:permissions, :users),
      custom_filters: [
        { attribute: :name, type: :string },
        { attribute: :resource_type, type: :string },
        { attribute: :created_at, type: :datetime_range },
        { attribute: :updated_at, type: :datetime_range }
      ],
      custom_params: current_filters
    )
  end
end
