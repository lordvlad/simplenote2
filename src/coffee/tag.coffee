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
    @fgColor = obs => 
      x = []
      c = ( x[0] = new RGBColor( @color() or "white" ) ).foreground()
      delete x[0]
      return c
    @count = obs => Node.nodes.filter((n)=> n.tags.has @).length
    
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
    console.log arguments
    return if $( e.target ).is( '.icon-trash, .icon-pencil' )
    if @model.searchFilter().match( '#' + @name() )
      @model.searchFilter( @model.searchFilter().replace( '#' + @name(), '' ).replace(/\s{2,}/g," ").replace(/^\s*|\s*$/g,"") + " " )
    else
      @model.searchFilter( ( @model.searchFilter() + " #" + @name() ).replace(/\s{2,}/g," ").replace(/^\s*|\s*$/g,"") + " " )
    @model.editingFilter on
      
      
revive.constructors[ 'Tag' ] = Tag
