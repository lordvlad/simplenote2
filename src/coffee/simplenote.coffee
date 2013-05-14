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
    @archive = null
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
    @syncStatus = obs 0
    @syncStatusText = obs =>
      switch @syncStatus()
        when 0 then 'not set up'
        when 1 then 'connected'
        when 2 then 'disconnected'
        when 3 then 'synchronizing'
    @syncStatusColor = obs =>
      switch @syncStatus()
        when 0 then ''
        when 1 then 'green'
        when 2 then 'red'
        when 3 then 'orange'
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
      a = if @options.appearance.titles() then "" else @current()
      @current()?.parents?().concat( a ) or []
    # subscribe to location hash changes    
    hash.subscribe ( id ) =>
      @current ( id and id.length and @nodes.find("id", id) ) or ( id and id.length and hash( '' ) and @root ) or @root
      @current()?.editingNote on
  


  # revive from JSON data
  # @param {Object} data json object containting all needed data
  revive : =>
    @root = store.get( 'root' ) ? new Node( { id : 'root', title : 'home' } )
    if options = store.get( 'options' )
      koMap @options, options
    # update current viewed node from location.hash
    hash.valueHasMutated()
    delay =>
      store.get( 'tags' ) ? []
      @archive = store.get( 'archive' ) ? new Node( { id : 'archive', title : 'archive' } )
    @
  
  # saves own data to localStorage
  save : =>
    timeout.clear @timeout
    @timeout = timeout.set 100, => 
      store.set 'root', @root.toJSON()
      store.set 'tags', @tags()
      store.set 'options', ko.toJSON @options
      if @archive
        store.set 'archive', @archive.toJSON()
    @
  
  # set up online check
  startOnlineCheck : ->
    offlineCount = 0
    numShortChecks = 5 # how often to check with a short interval before switching to long interval
    short = 2 # seconds
    long = 60 # seconds
    checkConnection = =>
      $.get( 
        'online/online.json' 
      ).error( =>
        @connectionStatus 0
        timeout.set ( if offlineCount++ < numShortChecks then short else long )*1e3, checkConnection
      ).done( =>
        @connectionStatus 1
        offlineCount = 0
        timeout.set long*1e3, checkConnection
      )
    checkConnection()
    
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
  selectionArchive : => node.archive() for node in @selectedNodes() 
  selectionEditDeadlines : => d=prompt 'set a deadline for the selected items', new Date(); node.deadline d for node in @selectedNodes()
  selectionRemove : => node._delete() for node in @selectedNodes() if confirm "really delete #{@selectedNodes().length} selected outlines? ATTENTION! Children Nodes will be deleted with their parents!"
  selectionEditTags : =>
  
  # functions that create nodes
  addNodeTo : ( parent, options ) =>( new Node $.extend (if isObj options then options else {}), { parent: parent } ).editingTitle on
  addNodeHere : ( options ) => 
    @addNodeTo ( options.id? and options or @current() ), options
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
  checkForOptions : (el) =>
    if ( domnode = $( '.options', el ) ).length > 0 and $( '[data-bind]', el ).length > 0
      ko.applyBindings @, domnode[0]
      
  # helping with sorting
  startSort :=>
    # console.log 'starting sort'
    $( '.node', @view ).on({ "mouseover.sort": ->
      ko.dataFor( $(this)[0] ).expanded( true )
    , "mouseout.sort" : ->
      ko.dataFor( $(this)[0] ).expanded( false )
    })
  stopSort :=>
    $( '.node', @view ).off( '.sort' )
    # console.log 'stopping sort'
  
  # notificationsystem
  removeNotification : (item) => @notifications.remove item
  removeAlert : ( item ) => @alerts.remove item
  
  # filter functions
  clearSearchFilter :=> @searchFilter ''
  
  # get build information
  getBuild : =>
    $.getJSON 'build.json', ( d ) =>
      @build = d

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
    
revive.constructors[ "SimpleNote" ] = SimpleNote
