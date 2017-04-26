class Api::NodesController < ApiController

  before_action :set_node, except: [:index, :types, :create]
  before_action :require_node_ownership!, except: [:index, :types, :create, :show]
  before_action :require_visualization_published!, only: [:show]

  def index
    dataset = Dataset.find_by(visualization_id: params[:visualization_id])
    render json: [] and return unless (dataset.visualization.published || (dataset.visualization.author == current_user) || (dataset.visualization.author == demo_user))
    @nodes = dataset.nodes.order(:name)
  end

  def types
    dataset = Dataset.find_by(visualization_id: params[:visualization_id])
    render json: [] and return unless (dataset.visualization.published || (dataset.visualization.author == current_user) || (dataset.visualization.author == demo_user))
    @node_types = dataset.nodes
                      .select(:node_type)
                      .map(&:node_type)
                      .reject(&:blank?)
                      .uniq
  end

  def create
    @node = Node.create(node_params)
    render :show
  end

  def show
  end

  def update
    if params[:node][:image].nil? && params[:node][:remote_image_url].nil?
      params[:node][:remove_image] = 1
    end

    current_custom_fields = @node.custom_fields || {}
    @node.dataset.node_custom_fields.each do |cf|
      field = cf["name"]
      data = params[:node][field]
      next if data.nil?
      current_custom_fields = current_custom_fields.merge({cf["name"] => data})
      next
    end
    params[:node][:custom_fields] = current_custom_fields

    @node.update(node_params)
    render :show
  end

  def destroy
    @node.destroy
    head :no_content
  end

  private

  def set_node
    @node = Node.find(params[:id])
  end

  def require_node_ownership!
    render :show and return unless authorized
  end

  def require_visualization_published!
    render json: {} unless (@node.visualization.published || authorized)
  end

  def authorized
    (@node.visualization.author == current_user) || (@node.visualization.author == demo_user)
  end

  def node_params
    params.require(:node).permit(:name, :description, :visible, :node_type, :visualization_id, :dataset_id, :posx, :posy, :image, :image_cache, :remote_image_url, :remove_image, custom_fields: params[:node][:custom_fields].try(:keys))
  end

end