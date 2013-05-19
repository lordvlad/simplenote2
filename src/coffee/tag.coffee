###
@class Tag
###

class Tag
  @fromJSON : ( data ) =>
    return tag if tag = SimpleNote.activeInstance.tags.find 'id', data.id
    delete data.__constructor
    instance = new Tag()
    koMap instance, data
    
  constructor : ( options ) -> 
    @id = uuid()
    @model = SimpleNote.activeInstance
    
    @name = obs options?.name or ""
    @color = obs options?.color or "white"
    @fgColor = obs => if $.Color( @color() ).lightness() < .33 then "white" else "black"
    
    @model.tags.push @
    @model.save()
  
  toJSON : =>
    {
      __constructor : 'Tag'
      id    : @id
      name  : @name()
      color : @color()
    }
    
  edit : =>
    @name prompt("change name from #{@name()} to ...", @name()) or @name()
    @color prompt("change color from #{@color()} to ...", @color()) or @color()
    @model.save()
  
  remove : => 
    @_delete if confirm "really delete tag '#{@name()}'?"
    
  _delete : =>
    @model.tags.remove @
    node.tags.remove @ for node in @model.nodes()
    
  toggleInFilter :(i,e)=>
    return if $( e.target ).is( '.icon-trash, .icon-pencil' )
    if @model.searchFilter().match( '#' + @name() )
      @model.searchFilter( @model.searchFilter().replace( '#' + @name(), '' ).replace(/\s{2,}/g," ").replace(/^\s*|\s*$/g,"") + " " )
    else
      @model.searchFilter( ( @model.searchFilter() + " #" + @name() ).replace(/\s{2,}/g," ").replace(/^\s*|\s*$/g,"") + " " )
    @model.editingFilter on
      
      


class Bookmark
  @fromJSON : ( data ) ->
    return bm if bm = SimpleNote.activeInstance.bookmarks.find 'href', data.href
    delete data.__constructor
    instance = new Bookmark()
    koMap instance, data
  @active : obs(
    read: -> 
      hash()
      SimpleNote.activeInstance.bookmarks.find 'href', location.href
    write: null
    deferEvaluation: true
  )
  @toggle : ->
    if a = SimpleNote.activeInstance.bookmarks.find 'href', location.href
      SimpleNote.activeInstance.bookmarks.remove a
    else
      new Bookmark
    
  constructor : ( options ) ->
    @model = SimpleNote.activeInstance
    @title = options?.name or document.title.replace 'simpleNote | ', ''
    @href = options?.name or location.href
    @model.bookmarks.push @
    @model.save()
    
  toJSON : =>
    {
      __constructor : 'Bookmark'
      title : @title
      href : @href
    }
revive.constructors[ 'Tag' ] = Tag
revive.constructors[ 'Bookmark' ] = Bookmark