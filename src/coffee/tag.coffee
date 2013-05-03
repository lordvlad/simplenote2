###
@class Tag
###

class Tag
  constructor : ( options ) -> 
    
    @id = uuid()
    @smplnt = options?.smplnt || window.note
    
    @name = obs options?.name or ""
    @color = obs options?.color or "white"
    @count = obs => @smplnt.nodes.filter((n)=> n.tags.has @).length
    
    @smplnt.tags.push @
    @smplnt.save()
  
  toJSON : =>
    {
      __constructor : 'Tag'
      id    : @id
      name  : @name()
      color : @color()
    }
    
  edit : =>
    @name prompt "change name from #{@name()} to ...", @name()
    @color prompt "change color from #{@color()} to ...", @color()
    @smplnt.save()
    
  @fromJSON : ( data ) =>
    delete data.__constructor
    instance = new Tag()
    koMap instance, data