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
    # observable Arrays
    @nodes = obs []
    @tags = obs []
    @selectedNodes = obs => @nodes.filter 'selected'
    @bookmarkedNodes = obs => @nodes.filter 'bookmarked'
    @breadcrumbs = obs =>
      crumbs = []
      getParent = (node) =>
        p = @nodes.find (n)->n.children.has( node );
        if p
          crumbs.push node
          console.log p 
          # getParent(node)
      getParent( @current() )
      crumbs
      
    @
      
      
  attachElements : ( view ) =>
    @$view = $( view )
    @view = @$view[ 0 ]
    @pop = $( 'audio', view )[0]
    @$tagsMenu = $( '#tagsMenu', view )

  # only return nodes and tags on serialization
  toJSON : =>
    {
      root   : @root
      tags  : @tags()
    }
    
  # revive from JSON data
  # @param {Object} data json object containting all needed data
  revive : =>
    data = store.get 'simpleNote'
    if data
      console.log data
      @root = data.root
      @tags data.tags
    else 
      root = new Node()
      root.id = 'simpleNoteRoot'
      @root = root
    @current @root
    @
  
  # saves own data to localStorage
  save : =>
    timeout.clear @timeout
    @timeout = timeout.set 100, => store.set "simpleNote", @toJSON()
    @
  
  # apply keyBindings
  applyKeyBindings : ->
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
  selectionRemove : =>
    if confirm "really delete all selected outlines?" 
      @nodes.removeAll @selected()
      @save()
    @
  selectionUnselect : => 
    for node in @selected() 
      do node.selected no
    @
  selectionInvert : =>
    for node in @selected()
      do node.selected not node.selected()
    @
  selectionArchive : =>
    for node in @selected() 
      do node.archived yes
    @
  selectionEditTags : =>
  
  # functions on selected text
  textBold : =>
  textItalics : =>
  textUnderline : =>
  textLink : =>
  textEmbed : =>
  
  # functions that create nodes
  addNodeTo : ( parent, options ) =>
    options = {} unless isObj options
    new Node $.extend options, { parent: parent }
  addNodeHere : ( options ) =>
    @addNodeTo @current(), options
  insertNodeAfter : ( node, options ) =>
    @addNodeTo @current().parent(), options
  
  
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