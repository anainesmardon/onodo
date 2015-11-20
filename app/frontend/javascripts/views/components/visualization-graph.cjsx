d3            = require 'd3'
React         = require 'react'
ReactFauxDOM  = require 'react-faux-dom'

#ReactFauxDOM Example 
VisualizationGraphD3Component = React.createClass
  #propTypes:
  #  data: React.PropTypes.arrayOf(React.PropTypes.number)

  color:    d3.scale.category20()
  svg:      null
  force:    null

  getDefaultProps: ->
    return {
      width: 600
      height: 400
      collection: {}
      data: {}
    }

  getInitialState: ->
    return {} 

  # Setup before render call
  componentWillMount: ->
    console.log 'componentWillMount -> setup force'
    # This is where we create the faux DOM node and give it to D3.
    @svg = d3.select( ReactFauxDOM.createElement('svg') )
      .attr('width', @props.width)
      .attr('height', @props.height)
    # Setup Force Layout
    @force = d3.layout.force()
      .charge(-120)
      .linkDistance(60)
      #.linkStrength(2)
      .size([@props.width, @props.height])

  # Update Node when model change
  componentDidMount: ->
    console.log 'componentDidMount'

    @props.collection.nodes.on 'change', (e) =>
      @forceUpdate()
    , @
    @props.collection.relations.on 'change', (e) =>
      @forceUpdate()
    , @

  render: ->

    console.log('render')
    
    # setup nodes & relations as arrays with Models attributes
    @props.data.nodes      = @props.collection.nodes.models.map((d) -> return d.attributes)
    @props.data.relations  = @props.collection.relations.models.map((d) -> return d.attributes)

    # Fix relations source & target index (based on 1 instead of 0)
    @props.data.relations.forEach (d) ->
      d.source = d.source_id-1
      d.target = d.target_id-1

    @force
      .nodes(@props.data.nodes)
      .links(@props.data.relations)
      .start();

    # Setup Links
    link = @svg.selectAll('.link')
      .data(@props.data.relations)
    .enter().append('line')
      .attr('class', 'link');

    # Setup Nodes
    nodes = @svg.selectAll('.node')
      .data(@props.data.nodes)
    .enter().append('circle')
      .attr('class', 'node')
      .attr('r', 6)
      .attr('cx', @props.width*0.5)
      #.attr('cx', (d,i) -> return 20+30*i )
      .attr('cy', @props.height*0.5)
      #.style('visibility', (d) -> return if d.visible then 'visible' else 'hidden') 
      .style('fill', (d) => return @color(d.node_type))
      .call(@force.drag)

    # Setup Force Layout tick
    @force.on 'tick', ->
      console.log 'tick'
      link.attr('x1', (d) -> return d.source.x)
          .attr('y1', (d) -> return d.source.y)
          .attr('x2', (d) -> return d.target.x)
          .attr('y2', (d) -> return d.target.y)
      nodes.attr('cx', (d) -> return d.x)
          .attr('cy', (d) -> return d.y)

    # svg.selectAll('.dot')
    #   .data( data )
    # .enter().append('g')
    #   .attr('class', (d) -> return 'dot dot-'+d.id)
    #   .attr('transform', (d,i) -> return 'translate(20,'+(20+40*i)+')')
    #   .style('visibility', (d) -> return if d.visible then 'visible' else 'hidden') 

    # svg.selectAll('.dot')
    #   .append('circle')
    #   .attr('r', 10)
    #   .attr('fill','gray')

    # svg.selectAll('.dot')
    #   .append('text')
    #   .attr('fill','gray')
    #   .attr('dx', 18)
    #   .attr('dy', 5)
    #   .text((d) -> d.name)

    #We ask D3 for the underlying fake node and then render it as React elements.
    return @svg.node().toReact()

module.exports = VisualizationGraphD3Component