###
* @class Node
###
class Node
  constructor : ( options ) ->
    # simple variables
    @smplnt = options?.smplnt || window.note
    @id = uuid()
    # observable variables      
    @title = obs( "" ).extend parse : Node.parseHeadline
    @notes = obs( "" ).extend parse : Node.parseNote
    @deadline = obs( null ).extend parse : Node.parseDate
    @bookmarked = obs false
    @selected = obs false
    @done = obs false
    @expanded = obs false
    @listStyleType = obs []
    @editingTitle = obs false
    @editingNote = obs false
    # observable arrays  
    @children = obs []
    @tags = obs []
    @tags.extend pickFrom : { array: @smplnt.tags, key : "name" }
    @files = obs []
    @hasNote = obs => @notes().length
    @hasChildren = obs => @children().length
    @cssClass = obs => @listStyleType().concat("node").filter(Boolean).join(" ")
    @bullet = obs => ( ( @hasNote() or @hasChildren() ) and ( ( not @expanded() and "&#9658;" ) or( @expanded() and "&#9660" ) ) ) or "&#9679;"
    @deadlineDisplay = obs => 
      time()
      d = @deadline()
      if d is not null
        if d > new Date then moment(d).fromNow()
        else @alarm()
      else ""
    
    # push self to simplenote nodes
    @smplnt.nodes.push @
    # push self to parent
    if options?.parent
      options.parent.children.push @
    @
    
  alarm : ->
    @deadline null
    @smplnt.pop.play()
    alert @title()
    return ""
    
    
  # toggle some switches
  toggleExpanded : =>
    @expanded !@expanded()
  toggleBookmarked : =>
    @bookmarked !@bookmarked()
  editTags : ( n, e ) =>
    @smplnt.$tagsMenu
      .trigger "position", e.target
      .on "menuselect", (e, ui) ->
        return unless ui and ui.item
        if not @tags.remove ui.item then @tags.push ui.item
  
  
  toJSON : =>
    {
      __constructor : 'Node'
      id : @id
      title : @title()
      notes : @notes()
      deadline : @deadline()
      bookmarked : @bookmarked()
      done : @done()
      expanded : @expanded()
      listStyleType : @listStyleType()
      children : @children()
    }
  
  # STATIC revive from JSON data
  # @param {Object} data json object containting all needed data
  @fromJSON : ( data ) =>
    delete data.__constructor
    instance = new Node
    koMap instance, data
  # STATIC parser functions
  @parseNote : (v) => v
  @parseHeadline : (v) => v.replace /<br>|\n|\r/ig, ""  
  @parseDate : (v) => v = new Date v; v = null if not isDate v; v