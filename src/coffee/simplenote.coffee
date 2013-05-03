###
@class simpleNote
###

class SimpleNote
  constructor : ( element ) ->
    # simple variables
    @timeout = null
    @interval = null
    @root = null
    @element = null
    @pop = null
    # observable variable
    @current = obs null    
    @alerts = obs []
    @notifications = obs []
    # observable Arrays
    @nodes = obs []
    @tags = obs []
    # computed variables
    @selectedNodes = obs => @nodes.filter 'selected'
    @bookmarkedNodes = obs => @nodes.filter 'bookmarked'
    @breadcrumbs = obs => 
      @current()
      ( @current()?.parents?().reverse().concat [@current()] ) or []
    # subscribe to location hash changes    
    hash.subscribe ( id ) =>
      @current ( id and id.length and @nodes.find("id", id) ) or @root
      @current().editingNote on
      
  attachElements : ( view ) =>
    @$view = $( view )
    @view = @$view[ 0 ]
    @pop = $( 'audio', view )[0]
    @$tagsMenu = $( '#tagsMenu', view )    

  # only return nodes and tags on serialization
  toJSON : =>
    {
      root : @root
    }
    
  # revive from JSON data
  # @param {Object} data json object containting all needed data
  revive : =>
    data = store.get 'simpleNote'
    if data
      @root = data.root
    else 
      root = new Node()
      root.id = 'simpleNoteRoot'
      root.title 'home'
      @root = root
    # update current viewed node from location.hash
    hash.valueHasMutated()
    @
  
  # saves own data to localStorage
  save : =>
    timeout.clear @timeout
    @timeout = timeout.set 100, => store.set "simpleNote", @toJSON()
    @
  
  # apply keyBindings
  applyEvents : ->
    @$view.on "click", ".headline", (e)->
      $t = $ e.target
      $t.parents(".headline").find("title").focus() unless $t.is(".bullet, .action, .ellipsis, .additional")
    # @$view.on  "keydown", wre.HotKeyHandler( @hotkeys, @ )
    @$view.on "keyup, click", => @save()
    
    @
  
  # functions on self
  startPeriodicalSave : ->
    @interval = interval.set 6e4, @save
    @
  stopPeriodicalSave : ->
    interval.clear @interval
    @
    
  # functions on selected nodes  
  selectionUnselect : => node.selected no for node in @selectedNodes()
  selectionInvert : => node.selected not node.selected() for node in @nodes()
  selectionArchive : => node.archived yes for node in @selectedNodes() 
  selectionRemoveDeadlines : => node.deadline null for node in @selectedNodes()
  selectionRemove : => node._delete() for node in @selectedNodes() if confirm "really delete #{@selectedNodes().length} selected outlines? ATTENTION! Children Nodes will be deleted with their parents!"
  selectionEditTags : =>
  
  # functions that create nodes
  addNodeTo : ( parent, options ) =>( new Node $.extend (if isObj options then options else {}), { parent: parent } ).editingTitle on
  addNodeHere : ( options ) => @addNodeTo @current(), options
  insertNodeAfter : ( node, options ) => @addNodeTo @current().parent(), options
  
  # functions that work with nodes
  openNode : ( el ) =>
    hash (el and el.id) or ( el and el[0] and ko.dataFor(el[0]) )?.id or el or @root.id
  
  # functions that work with tags
  addTag :=> new Tag { smplnt : @, name : prompt 'set a name','' }
  removeTag :(item)=> 
    return if not confirm "really delete the tag named #{item.name()}?"
    @tags.remove item
    node.tags.remove item for node in @nodes()
  
  # effect Functions
  fadeIn : (el) -> $(el).hide().fadeIn('slow')
  fadeOut : (el) -> $(el).fadeOut -> $(el).remove()
  
  # notificationsystem
  removeNotification : (item) => @notifications.remove item
  removeAlert : ( item ) => @alerts.remove item
  
# static values
SimpleNote.liststyletypes = [
  { name : "none", value : [] }
  { name : "1, 2, 3", value: ["decimal"] }
  { name : "1., 2., 3.", value: ["decimal","dot"] }
  { name : "1.1, 1.2, 1.3", value : ["decimal","dot","add"] }
  { name : "a, b, c", value: ["lowerAlpha"] }
  { name : "(a), (b), (c)", value : ["lowerAlpha","dot"] }
  { name : "A, B, C", value: ["upperAlpha"] }
  { name : "(A), (B), (C)", value : ["upperAlpha","dot"] }
]