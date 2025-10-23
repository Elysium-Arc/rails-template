# frozen_string_literal: true

class PermissionsController < ApplicationController
  include FilterableIndex

  before_action :set_permission, only: %i[show edit update destroy]
  before_action :persist_filters, only: :index

  def index
    authorize Permission
    @permissions = filterable_index(
      Permission,
      base_scope: policy_scope(Permission).includes(:roles),
      custom_filters: [
        { attribute: :name, type: :string },
        { attribute: :resource_type, type: :string },
        { attribute: :description, type: :string },
        { attribute: :created_at, type: :datetime_range },
        { attribute: :updated_at, type: :datetime_range }
      ]
    )
  end

  def show
    authorize @permission
    render layout: false
  end

  def new
    @permission = Permission.new
    authorize @permission
    render layout: false
  end

  def edit
    authorize @permission
    render layout: false
  end

  def create
    @permission = Permission.new(permission_params)
    authorize @permission

    if @permission.save
      respond_to do |format|
        format.turbo_stream do
          reload_table_data

          render turbo_stream: [
            turbo_stream.replace(
              "permissions-table",
              partial: "permissions/table",
              locals: {
                permissions: @permissions,
                pagy: @pagy,
                filters: @filters,
                active_filter_keys: @active_filter_keys,
                custom_params: current_filters
              }
            ),
            turbo_flash(:notice, "permissions.messages.created"),
            close_modal
          ]
        end
        format.html { redirect_to permissions_path, notice: t("permissions.messages.created") }
      end
    else
      render :new, status: :unprocessable_entity, layout: false
    end
  end

  def update
    authorize @permission

    if @permission.update(permission_params)
      respond_to do |format|
        format.turbo_stream do
          reload_table_data

          render turbo_stream: [
            turbo_stream.replace(
              "permissions-table",
              partial: "permissions/table",
              locals: {
                permissions: @permissions,
                pagy: @pagy,
                filters: @filters,
                active_filter_keys: @active_filter_keys,
                custom_params: current_filters
              }
            ),
            close_modal,
            turbo_flash(:success, "permissions.messages.updated")
          ]
        end
        format.html { redirect_to permissions_path, notice: t("permissions.messages.updated") }
      end
    else
      render :edit, status: :unprocessable_entity, layout: false
    end
  end

  def destroy
    authorize @permission
    @permission.destroy
    respond_to do |format|
      format.turbo_stream do
        reload_table_data

        render turbo_stream: [
          turbo_stream.replace(
            "permissions-table",
            partial: "permissions/table",
            locals: {
              permissions: @permissions,
              pagy: @pagy,
              filters: @filters,
              active_filter_keys: @active_filter_keys,
              custom_params: current_filters
            }
          ),
          close_modal,
          turbo_flash(:success, "permissions.messages.deleted")
        ]
      end
      format.html { redirect_to permissions_path, notice: t("permissions.messages.deleted") }
    end
  end

  private

  def set_permission
    @permission = Permission.find(params[:id])
  end

  def permission_params
    params.require(:permission).permit(:name, :description, :resource_type, :resource_id)
  end

  # Reload table data with preserved filters, sorting, and pagination
  def reload_table_data
    @permissions = filterable_index(
      Permission,
      base_scope: policy_scope(Permission).includes(:roles),
      custom_filters: [
        { attribute: :name, type: :string },
        { attribute: :resource_type, type: :string },
        { attribute: :description, type: :string },
        { attribute: :created_at, type: :datetime_range },
        { attribute: :updated_at, type: :datetime_range }
      ],
      custom_params: current_filters
    )
  end
end
