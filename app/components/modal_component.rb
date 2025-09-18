# frozen_string_literal: true

class ModalComponent < BaseComponent
  attr_reader :id, :title, :closable, :backdrop_dismissable, :turbo_frame_id,
              :size, :width, :modal_class, :modal_box_class, :title_class,
              :content_class, :modal_box_class_mode

  SIZES = {
    sm: "max-w-sm",
    md: "max-w-2xl",
    lg: "max-w-4xl",
    xl: "max-w-6xl",
    full: "max-w-7xl"
  }.freeze

  def initialize(
    id:,
    title: nil,
    closable: true,
    backdrop_dismissable: true,
    turbo_frame_id: nil,
    size: :md,
    width: nil,
    modal_class: nil,
    modal_box_class: nil,
    modal_box_class_mode: :add,
    title_class: nil,
    content_class: nil,
    **options
  )
    @id = id
    @title = title
    @closable = closable
    @backdrop_dismissable = backdrop_dismissable
    @turbo_frame_id = turbo_frame_id || "#{id}-content"
    @size = size
    @width = width
    @modal_class = modal_class
    @modal_box_class = modal_box_class
    @modal_box_class_mode = modal_box_class_mode
    @title_class = title_class
    @content_class = content_class
    @options = options
  end

  def modal_dialog_classes
    classes = [ "modal" ]
    classes << modal_class if modal_class.present?
    classes.join(" ")
  end

  def modal_box_classes
    default_classes = "modal-box w-11/12"
    size_class = width.presence || SIZES[@size] || SIZES[:md]

    if @modal_box_class_mode == :replace && @modal_box_class.present?
      @modal_box_class
    else
      classes = [ default_classes, size_class ]
      classes << @modal_box_class if @modal_box_class.present?
      classes.join(" ")
    end
  end

  def title_classes
    default_classes = "font-bold text-lg"

    if @title_class.present?
      [ default_classes, @title_class ].join(" ")
    else
      default_classes
    end
  end

  def content_classes
    default_classes = "py-4"

    if @content_class.present?
      [ default_classes, @content_class ].join(" ")
    else
      default_classes
    end
  end
end
