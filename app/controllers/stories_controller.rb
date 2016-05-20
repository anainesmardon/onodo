class StoriesController < ApplicationController
  before_action :set_story, only: [:show, :edit, :editinfo, :update, :update_image, :destroy, :publish, :unpublish]

  # GET /stories/:id
  def show
    @story_id         = @story.id
    @visualization_id = @story.visualization.id
    @nodes            = Node.where(dataset_id: @visualization_id)
    @relations        = Relation.where(dataset_id: @visualization_id)
    # !!! TODO -> Modify related_items to get only related visualizations/stories
    @related_items    = Visualization.published
  end

  # GET /stories/new
  def new
    if current_user.nil?
      redirect_to new_user_session_path()
    end
    @visualizations = Visualization.published.where(author_id: current_user.id).page(params[:page]).per(8)
  end

  # POST /stories
  def create
    story_params                    = {}
    story_params[:name]             = params[:story][:name]
    story_params[:author_id]        = current_user.id
    story_params[:visualization_id] = params[:story][:visualization]
    @story  = Story.new( story_params )
    #@story.visualization = Visualization.where(id: params[:story][:visualization])

    if @story.save
      redirect_to edit_story_path( @story ), :notice => "Your story was created!"
    else
      render "new"
    end
  end

  # GET /stories/:id/edit
  def edit
    if current_user.nil?
      redirect_to new_user_session_path()
    else
      @story_id         = @story.id
      @visualization_id = @story.visualization.id
    end
  end

  # GET /stories/:id/edit/info
  def editinfo
    if current_user.nil?
      redirect_to new_user_session_path()
    end
  end
  
  # PATCH /stories/:id/
  def update
    @story.update_attributes( edit_info_params )
    redirect_to story_path( @story )
  end

  # PATCH /stories/:id/image
  def update_image
    @story.update_attributes( edit_info_params )
    redirect_to edit_story_path( @story )+'/info'
  end

  # DELETE /stories/:id/
  def destroy
    @story.destroy
    redirect_to user_path( current_user ), :flash => { :success => "Story deleted" }
  end

  # POST /stories/:id/publish
  def publish
    if @story.update_attributes(:published => true)
      redirect_to story_path( @story )
    else
      redirect_to edit_story_path( @story )
    end
  end
  
  # POST /stories/:id/unpublish
  def unpublish
    if @story.update_attributes(:published => false)
      redirect_to story_path( @story )
    else
      redirect_to edit_story_path( @story )
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_story
    @story = Story.find(params[:id])
  end

  def edit_info_params
    params.require(:story).permit(:name, :description, :image, :image_cache, :remote_image_url, :remove_image)
  end
end
