class NotesController < AuthenticatedController
  before_action :set_note, only: %i[show edit update destroy]

  def index
    @notes = current_user.notes.with_attached_file.order(created_at: :desc)
  end

  def new
    @note = current_user.notes.build
  end

  def create
    @note = current_user.notes.build(note_params)
    if @note.save
      redirect_to @note, notice: "Note created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_note
    @note = current_user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:body, :file, :file_purge)
  end
end
