###
@class simpleNote
###

class SimpleNote
  @instances : []
  constructor : ( element ) ->
    SimpleNote.instances.push @
    # simple variables
    @timeout = null
    @interval = null
    @root = null
    @element = null
    @pop = null
    # observable variables
    @searchFilter = obs ""
    @editingFilter = obs false
    @current = obs null    
    @alerts = obs []
    @notifications = obs []    
    @connectionStatus = obs 0
    @connectionStatusText = obs =>
      switch @connectionStatus()
        when 0 then 'offline'
        when 1 then 'online'
    @connectionStatusColor = obs =>
      switch @connectionStatus()
        when 0 then 'red'
        when 1 then 'green'
    @dropboxStatus = obs 0
    @dropboxStatusText = obs =>
      switch @dropboxStatus()
        when 0 then 'not set up'
        when 1 then 'connected'
        when 2 then 'disconnected'
        when 3 then 'synchronizing'
    @dropboxStatusColor = obs =>
      switch @dropboxStatus()
        when 0 then ''
        when 1 then 'green'
        when 2 then 'red'
        when 3 then 'yellow'
    # observable Arrays
    @nodes = obs []
    @tags = obs []
    # computed variables
    @realFilter = obs( =>
      f = @searchFilter().split(/\s+/)
      return {tags:[],times:[],words:[]} if  not f[0] or f[0]?[0] is '!'
      {
        tags : f.filter((n)-> n.match /^#/).map((n)->n.replace(/#/,''))
        times : f.filter((n)-> n.match /^@/).map((n)->n.replace(/@/,''))
        words : f.filter((n)-> n.match /^[^#@]/)
      }
    ).extend({ debounce: 500 })
    @selectedNodes = obs => @nodes.filter 'selected'
    @bookmarkedNodes = obs => @nodes.filter 'bookmarked'
    @breadcrumbs = obs => 
      @current()
      ( @current()?.parents?().concat [@current()] ) or []
    # subscribe to location hash changes    
    hash.subscribe ( id ) =>
      @current ( id and id.length and @nodes.find("id", id) ) or @root
      @current()?.editingNote on
      
  attachElements : ( view ) =>
    @$view = $( view )
    @view = @$view[ 0 ]
    @pop = $( 'audio', view )[0]
    @$tagsMenu = $( '#tagsMenu', view )    

  # only return nodes and tags on serialization
  toJSON : =>
    {
      root : @root
      tags : @tags()
    }
    
  # revive from JSON data
  # @param {Object} data json object containting all needed data
  revive : =>
    data = store.get 'simpleNote'
    if data and data.root
      @root = data.root
      @tags data.tags or []
    else 
      root = new Node()
      root.id = 'simpleNoteRoot'
      root.title 'home'
      root.visible = -> true
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
  addTag :=> new Tag { name : prompt 'set a name','' }
  removeTag :(item)=> 
    return if not confirm "really delete the tag named #{item.name()}?"
    @tags.remove item
    node.tags.remove item for node in @nodes()
  
  # afterRender and such Functions
  fadeIn : (el) -> $(el).hide().fadeIn('slow')
  fadeOut : (el) -> $(el).fadeOut -> $(el).remove()
  checkForOptions : (el) ->
    console.log el
  
  # notificationsystem
  removeNotification : (item) => @notifications.remove item
  removeAlert : ( item ) => @alerts.remove item
  
  # filter functions
  clearSearchFilter :=> @searchFilter ''
  

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

$ -> 
  do () ->
    model = SimpleNote.activeInstance
    offlineCount = 0
    numShortChecks = 5 # how often to check with a short interval before switching to long interval
    short = 2 # seconds
    long = 60 # seconds
    checkConnection = ->
      $.get( 
        'online/online.json' 
      ).error( ->
        model.connectionStatus 0
        timeout.set ( if offlineCount++ < numShortChecks then short else long )*1e3, checkConnection
      ).done( ->
        model.connectionStatus 1
        offlineCount = 0
        timeout.set long*1e3, checkConnection
      )
    checkConnection()
    