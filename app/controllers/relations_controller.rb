class RelationsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_relation
  before_action :require_relation_ownership!

  # GET /relations/:id/edit/date
  def edit_date
    render layout: false
  end 

  # PATCH /relations/:id/
  def update
    @relation.update_attributes( relation_params )
    redirect_to edit_visualization_path(@relation.visualization)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_relation
    @relation = Relation.find(params[:id])
  end

  def require_relation_ownership!
    redirect_to visualization_path(@relation.visualization) unless authorized
  end

  def authorized
    (@relation.visualization.author == current_user) || (@relation.visualization.author == demo_user)
  end

  def relation_params
    params.require(:relation).permit(:source_id, :target_id, :relation_type, :direction, :at, :from, :to, :dataset_id, custom_fields: params[:relation][:custom_fields].try(:keys))
  end

end
