# frozen_string_literal: true

class UsersController < ApplicationController
  include FilterableIndex

  before_action :set_user, only: %i[show edit update destroy]
  before_action :persist_filters, only: :index

  def index
    @users = filterable_index(
      User,
      base_scope: User.includes(:sessions),
      custom_filters: [
        { attribute: :email_address, type: :email },
        { attribute: :created_at, type: :datetime_range },
        { attribute: :updated_at, type: :datetime_range }
      ]
    )
  end

  def show
    render layout: false
  end

  def new
    @user = User.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @user = User.new(user_params)

    if @user.save
      respond_to do |format|
        format.turbo_stream do
          reload_table_data

          render turbo_stream: [
            turbo_stream.replace(
              "users-table",
              partial: "users/table",
              locals: {
                users: @users,
                pagy: @pagy,
                filters: @filters,
                active_filter_keys: @active_filter_keys,
                custom_params: current_filters
              }
            ),
            turbo_flash(:notice, "users.messages.created"),
            close_modal
          ]
        end
        format.html { redirect_to users_path, notice: "users.messages.created" }
      end
    else
      render :new, status: :unprocessable_entity, layout: false
    end
  end

  def update
    # Don't require password if not provided
    update_params = user_params
    update_params = update_params.except(:password, :password_confirmation) if update_params[:password].blank?

    if @user.update(update_params)
      respond_to do |format|
        format.turbo_stream do
          reload_table_data

          render turbo_stream: [
            turbo_stream.replace(
              "users-table",
              partial: "users/table",
              locals: {
                users: @users,
                pagy: @pagy,
                filters: @filters,
                active_filter_keys: @active_filter_keys,
                custom_params: current_filters
              }
            ),
            close_modal,
            turbo_flash(:success, "users.messages.updated", default: "User updated successfully")
          ]
        end
        format.html { redirect_to users_path, notice: t("users.messages.updated", default: "User updated successfully") }
      end
    else
      render :edit, status: :unprocessable_entity, layout: false
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.turbo_stream do
        reload_table_data

        render turbo_stream: [
          turbo_stream.replace(
            "users-table",
            partial: "users/table",
            locals: {
              users: @users,
              pagy: @pagy,
              filters: @filters,
              active_filter_keys: @active_filter_keys,
              custom_params: current_filters
            }
          ),
          close_modal,
          turbo_flash(:success, "users.messages.deleted", default: "User deleted successfully")
        ]
      end
      format.html { redirect_to users_path, notice: t("users.messages.deleted", default: "User deleted successfully") }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end

  # Reload table data with preserved filters, sorting, and pagination
  def reload_table_data
    @users = filterable_index(
      User,
      base_scope: User.includes(:sessions),
      custom_filters: [
        { attribute: :email_address, type: :email },
        { attribute: :created_at, type: :datetime_range },
        { attribute: :updated_at, type: :datetime_range }
      ],
      custom_params: current_filters
    )
  end
end
