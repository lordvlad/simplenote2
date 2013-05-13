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
      @current()
      ( @current()?.parents?().concat [@current()] ) or []
    # subscribe to location hash changes    
    hash.subscribe ( id ) =>
      @current ( id and id.length and @nodes.find("id", id) ) or ( id and id.length and hash( '' ) and @root ) or @root
      @current()?.editingNote on
  


  # revive from JSON data
  # @param {Object} data json object containting all needed data
  revive : =>
    @root = store.get( 'root' ) ? new Node( { id : 'root', title : 'home' } )
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
      store.set( 'archive', @archive.toJSON() ) if @archive
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
    
  # apply keyBindings
  applyEvents : =>
    [ model, $doc, $view ] = [ @, @doc, @view ]
    # set up event listeners
    $view.on "click", ".headline", (e)->
      $t = $ e.target
      $t.parents(".headline").find("title").focus() unless $t.is(".bullet, .action, .info")
    # $view.on  "keydown", wre.HotKeyHandler( model.hotkeys, model )
    $view.on "keyup, click", => model.save()
    
    # tags menu 
    $tagsMenu = $( '#tagsMenu', $view )
    $tagsMenu.data( 'node', 
      null
    ).on( 'dismiss', ->
      $( this ).fadeOut 'fast',->$( this ).css { top: '', left: '' }
    ).on( 'call', (e,node,o) ->
      $doc.off 'click.tagsmenu'
      $this = $(this).position({my:'right top',at:'right bottom',of:o.target}).fadeIn('fast').data('node',node)
      $this.find( 'input' ).focus()
      $doc.on 'click.tagsmenu', (e)->
        return if e.timeStamp is o.timeStamp or $( e.target ).parents( '#tagsMenu' ).length isnt 0
        $doc.off 'click.tagsmenu'
        $this.trigger( 'dismiss' )
    ).on( 'click', 'li.list', -> 
      tag = ko.dataFor this; node = $#tagsMenu.data( 'node' );
      if node.tags.remove(tag).length is 0 then node.tags.push tag
    ).on( 'click', 'i.icon-tag.addTag', ->
      return if not ( name = $(this).prev().val() )
      $tagsMenu.data( 'node' ).tags.push new Tag( { name: name } )
      $(this).next().val( '' ).focus()
    ).on( 'keydown', 'input', (e)->
      $tagsMenu.trigger( 'dismiss' ) if e.which is k.ESC
      return if e.which isnt k.ENTER
      $( this ).next().trigger( 'click' )
    )
    
    # searchbar tags
    $( '#search > div >.icon-tags', $view ).click (e)->
      model.editingFilter on
      t = $ '#tags'
      return t.slideUp() if t.is 'visible'
      t.slideDown 'fast'
      $doc.on 'click.tagsfilter', (f)->
        return if e.timeStamp is f.timeStamp or $(f.target).is('.icon-trash')
        $doc.off 'click.tagsfilter'
        t.slideUp 'fast'
        
    # searchbar bookmarks
    $( '#search > div >.icon-star', $view ).click (e)->
      model.editingFilter on
      b = $ '#bookmarks'
      return b.slideUp() if b.is 'visible'
      b.slideDown 'fast'
      $doc.on 'click.bookmarks', (f)->
        return if e.timeStamp is f.timeStamp or $(f.target).is('.icon-star-half')
        $doc.off 'click.bookmarks'
        b.slideUp 'fast'   
        
    # searchbar more
    $( '#search > div > .icon-ellipsis-vertical' ).click (e) ->
      s = $( '#specialPages' )
      if s.is 'visible' then return s.slideUp()
      s.slideDown 'fast'
      $doc.on 'click.specialPages', (f)->
        return if e.timeStamp is f.timeStamp
        $doc.off 'click.specialPages'
        s.slideUp 'fast'
     
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
