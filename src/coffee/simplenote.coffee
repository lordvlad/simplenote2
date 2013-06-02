class SimpleNote
  
  # static properties
  @activeInstance : null
  @syncModules = {}
  @syncModulesCount = null
  
  
  # constructor 
  constructor : ( element ) ->
    @$ = $ @
    SimpleNote.activeInstance = @
    SimpleNote.syncModulesCount = SimpleNote.syncModules.length
    
    # event listeners
    @$.on 'initialized', => $win.trigger 'appInitialized', @
    @$.on 'appsetupready', => 
    @$.on 'ready', => $win.trigger 'appReady', @
    @$.on 'online, offline', => console.log( 'app on/offline', arguments )

    # plain instance properties
    @timeout = null
    @revived = false
    @interval = null
    @root = null
    @archive = null
    # observable instance properties
    @searchFilter = obs ""
    @editingFilter = obs false
    @currentNode = obs null    
    @alerts = obs []
    @notifications = obs []    
    @nodes = obs []
    @tags = obs []
    @bookmarks = obs []
    
    # create observable for selectedNodes
    @selectedNodes = obs => @nodes.filter 'selected'
    
    # set up search filter
    @realFilter = obs( =>
      f = @searchFilter().split(/\s+/)
      return {tags:[],times:[],words:[]} if not f[0] or f[0]?[0] is '!'
      {
        tags : f.filter((n)-> n.match /^#/).map((n)->n.replace(//,''))
        times : f.filter((n)-> n.match /^@/).map((n)->n.replace(/@/,''))
        words : f.filter((n)-> n.match /^[^#@]/)
      }
    ).extend({ debounce: 500 })
    
    # create breadcrumbs
    @breadcrumbs = obs => 
      a = if @options.appearance.titles() then "" else @currentNode()
      @currentNode()?.parents?().concat( a ) or []
      
    # subscribe to location hash changes    
    hash.subscribe ( id ) =>
      @currentNode ( id and id.length and @nodes.find("id", id) ) or ( id and id.length and hash( '' ) and @root ) or @root
      @currentNode()?.editingNote on
      title( @currentNode().title() )

      
    
  # revive from JSON data
  # @param {Object} data json object containting all needed data
  ###
  revive : =>
    @sync.load ( err, data ) =>
      throw err if err
      @root = data.root
      @archive = data.archive
      koMap @options, data.options
      @revived = true
      # update current viewed node from location.hash
      hash.valueHasMutated()
    @
  
  # saves own data to localStorage
  save : =>
    return if not @revived
    timeout.clear @timeout
    @timeout = timeout.set 100, => 
      store.set 'root', @root.toJSON()
      store.set 'tags', @tags()
      store.set 'bookmarks', @bookmarks()
      store.set 'options', ko.toJSON @options
      if @archive
        store.set 'archive', @archive.toJSON()
    @
  ###

  # instance functions
  
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
  addNodeTo : ( parent, options ) =>
    if not parent?.id then parent = @current()
    ( new Node $.extend (if isObj options then options else {}), { parent: parent } ).active(on).editingTitle(on)
  
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
      
  # notificationsystem
  removeNotification : (item) => @notifications.remove item
  removeAlert : ( item ) => @alerts.remove item
  
  # filter functions
  clearSearchFilter :=> @searchFilter ''
  
  # get build information
  getBuild : ->
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
