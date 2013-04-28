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
    @breadcrumbs = obs => @current.parents?()
    @
      
  # only return nodes and tags on serialization
  toJSON : =>
    return {
      nodes   : @nodes()
      tags  : @tags()
    }
    
  # revive from JSON data
  # @param {Object} data json object containting all needed data
  revive : =>
    if data = store.get "simpleNote", true
      koMap @, data
      @root = @nodes.find("id","simpleNoteRoot")
    else 
      root = new Node { smplnt : @ }
      root.id = "simpleNoteRoot"
      @root = root
    @current @root
    @
  
  # saves own data to localStorage
  save : =>
    timout.clear @timeout
    @timeout = timeout.set 100, -> store.set @id, @
    @
  
  # apply keyBindings
  applyKeyBindings : =>
    @element.on "click", ".headline", (e)->
      $t = $ e.target
      $t.parents(".headline").find("title").focus() unless $t.is(".bullet, .action, .ellipsis, .additional")
    # @element.on  "keydown", wre.HotKeyHandler( @hotkeys, @ )
    @element.on "keyup, click", => @save()
  
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
    self = @
    Node $.extend options, { parent: parent, smplnt: self }
  insertNodeHere : ( options ) ->
    @addNodeTo @current(), options
  insertNodeAfter : ( node, options ) ->
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