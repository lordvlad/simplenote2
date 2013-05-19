###
* @class Node
###
class Node
  constructor : ( options ) ->
    # simple variables
    @model = SimpleNote.activeInstance
    @id = options?.id || uuid()
    @originalParent = null
    # observable variables      
    @title = obs( options?.title || "" ).extend parse : Node.parseHeadline
    @notes = obs( "" ).extend parse : Node.parseNote
    @deadline = obs( null ).extend parse : Node.parseDate
    active = obs false
    @selected = obs false
    @realExpanded = obs false
    @expanded = obs {
      read : => if window.innerWidth < maxScreenWidthForMobile then false else @realExpanded()
      write : @realExpanded
    }
    @listStyleType = obs []
    @editingTitle = obs false
    @editingNote = obs false
    # observable arrays  
    @children = obs []
    @tags = obs []
    @tags.extend pickFrom : { array: @model.tags, key : "name" }
    @files = obs []
    # computed variables
    @visible = obs =>
      {tags,words} = @model.realFilter()
      @model.current is @ or ( !!@children.filter( 'visible' ).length ) or (( if tags.length then !!intersect( @tags.map('name'), tags ).length else yes ) and ( if words.length then !!(@title()+' '+@notes()).match( new RegExp( words.join('|'), 'i' ) ) else yes ))

      
    @active = obs {
      read: active,
      write : (v) => 
        if v is active() or v is off then return active v
        node.active off for node in @model.nodes()
        active on
        @editingTitle on
      }
    @hasNote = obs => @notes().length
    @hasChildren = obs => @children().length
    @cssClass = obs => @listStyleType().concat("node").filter(Boolean).join(" ")
    @bullet = obs => ( ( @hasNote() or @hasChildren() ) and ( ( not @expanded() and Node.bullets.right ) or( @expanded() and Node.bullets.down ) ) ) or Node.bullets.round
    @forcedparent = obs null
    @parent = obs {
      read : => @forcedparent() || @model.nodes.find( (n) => n.children.has( @ ) )
      write : (v) => @forcedparent v
      }
    @parents = obs =>
      if @parent() is null then return []
      p = [@parent()]
      while ( x = p[0].parent() ) isnt null
        p.unshift x
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
    @model.nodes.push @
    Node.nodes.push @
    # push self to parent
    if options?.parent
      if options.position
        options.parent.children.splice options.position, 0, @
      else 
        options.parent.children.push @
    @
  
  # triggers hash change to open the node
  open : ->
    hash @id 
  # remove node
  remove : =>
    if confirm 'really delete this node?'
      @_delete()
  _delete :=>
    if ( @ is @model.current() ) then @model.current( @parent() )
    @parent().children.remove @
    @model.nodes.remove @
    @model.save()
  alarm : =>
    @model.save()
    @model.notifications.push @deadline() + '\n' + @title()
    @deadline null
    @model.pop.play?()
    
  # toggle some switches
  makeActive : =>
    @active on
  toggleSelected : =>
    @selected !@selected()
  toggleExpanded : =>
    return @open() if ( window.innerWidth < maxScreenWidthForMobile ) 
    return if ( !@hasNote() and !@hasChildren() )
    @expanded !@expanded()
  toggleBookmarked : =>
    @bookmarked !@bookmarked()
  archive : =>
    @selected off
    @originalParent = @parent()
    @parent().children.remove @
    @model.archive.children.push @
  editTags : ( n, e ) =>
    @active on
    @model.$tagsMenu.trigger 'call', [ n, e ]
  editDeadline : =>
    @deadline (prompt 'set a deadline', new Date()) or null
  editListType : =>
  editFiles : =>
  
  toJSON : =>
    {
      __constructor : 'Node'
      id : @id
      title : escape @title()
      notes : escape @notes()
      deadline : @deadline()
      expanded : ( @hasNote() || @hasChildren() ) && @realExpanded()
      listStyleType : @listStyleType()
      children : @children()
      tags : @tags()
      originalParent : @originalParent
    }
  
  # STATIC revive from JSON data
  # @param {Object} data json object containting all needed data
  @fromJSON : ( data ) ->
    delete data.__constructor
    instance = new Node()
    koMap instance, data
    
  # STATIC parser functions
  @parseNote : (v) -> v.replace /(<br>|\n|\r)$/i, ""
  @parseHeadline : (v) -> v.replace /<br>|\n|\r/ig, ""  
  @parseDate : (v) ->
    if v is null then return null
    if isDate( x = new Date v ) or isDate( x = new Date parseInt v ) or isDate( x = Date.intelliParse v ) then return x
    null
  
  @bullets : {
    right : "full" # "&#9658;" # "<i class='icon-circle'></i>",
    down : "full open" # "&#9660" # "<i class='icon-chevron-right'></i>",
    round  : "empty" # "&#9679;" # "<i class='icon-chevron-down'></i>"
  }
  @nodes : obs []
  
revive.constructors[ 'Node' ] = Node
