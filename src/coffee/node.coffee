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
    # computed variables
    @hasNote = obs => @notes().length
    @hasChildren = obs => @children().length
    @cssClass = obs => @listStyleType().concat("node").filter(Boolean).join(" ")
    @bullet = obs => ( ( @hasNote() or @hasChildren() ) and ( ( not @expanded() and "&#9658;" ) or( @expanded() and "&#9660" ) ) ) or "&#9679;"
    @parent = obs => @smplnt.nodes.find (n) => n.children.has @
    @parents = obs =>
      if @parent() is null then return []
      p = [@parent()]
      while ( x = p[p.length-1].parent() ) isnt null
        p.push x
      p
    # create a dummy timer which will work only if there is a deadline set
    # use this timer then in the ko.observable to display a deadline
    @deadlineDisplay = do () => 
      personalTimer = obs null
      subscribed = obs off
      subscription = null
      subscribed.subscribe ( v ) ->
        if v is on then subscription = time.subscribe ( w ) -> personalTimer w
        else subscription.dispose?()
      obs(=>
        personalTimer()
        d = @deadline()
        if d is null then return ""
        if d > now()
          subscribed on
          return moment(d).fromNow()
        subscribed off
        @alarm()
        return ""
      ).extend({throttle:1})
    
    # push self to simplenote nodes
    @smplnt.nodes.push @
    # push self to parent
    if options?.parent
      options.parent.children.push @
    @
  
  # triggers hash change to open the node
  open : ->
    hash( @id )
  # remove node
  remove : =>
    if confirm 'really delete this node?'
      @parent().children.remove @
      @smplnt.nodes.remove @
  alarm : =>
    @deadline null
    @smplnt.save()
    @smplnt.pop.play()
    alert @title()
    
  # toggle some switches
  toggleSelected : =>
    @selected !@selected()
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
  editDeadline : =>
    @deadline (prompt 'set a deadline', new Date()) or null
  editListType : =>
  editFiles : =>
  
  
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
  @parseNote : (v) => v.replace /(<br>|\n|\r)$/i, ""
  @parseHeadline : (v) => v.replace /<br>|\n|\r/ig, ""  
  @parseDate : (v) =>
    if v is null then return null
    if isDate( x = new Date v ) or isDate( x = new Date parseInt v ) or isDate( x = Date.intelliParse v ) then return x
    null