###
  possible event listeners
  'statuschange' : -> log 'dropbox status changed to', {newstatus}
  'connected' : -> log 'dropbox connected'
  'disconnected ' : -> log 'dropbox disconnected'
  'saved'  : -> log 'save to dropbox'
  'saving' : -> log 'saving to dropbox', {percent}
  'loaded'  : -> log 'load from dropbox' {data}
  'loading' : -> log 'loading from dropbox', {percent}
  'ready' : -> log 'dropbox ready'
  'error' : -> log 'dropbox error', arguments
###
class SimpleNote.SyncModule
  cfg    : {}
  name   : ''
  client : null
  data   : null
  statusText  : null
  statusColor : null
  status : obs 0
  save   : ->
  load   : ->
  
  constructor : ( @data ) ->
    @$ = $ @
    throw new Error 'SyncModule needs a data object to be bound to' if not @data
    prevstatus = 0
    statusDef = [
      [ 'is&nbsp;not&nbsp;set&nbsp;up', '' ]
      [ 'is&nbsp;ready', 'green' ]
      [ 'is&nbsp;working', 'saddlebrown' ]
      [ 'is&nbsp;disconnected', 'orange' ]
      [ 'has&nbsp;an&nbsp;error', 'red' ]
    ]
    @statusText = obs => statusDef[ @status() ][0]
    @statusColor = obs => statusDef[ @status() ][1]
    @status.subscribe( (v)=>
      @$.trigger('statuschange',[ v, prevstatus] )
      prevstatus = v
    )
    
    if @_init? then @_init() else @$.trigger( 'ready' )
    
  
  
class SimpleNote.syncModules.DropBox extends SimpleNote.SyncModule

  timer  : null
  name   : 'dropbox'
  cfg    :
    client :
      key: "iWIaoxmWAjA=|63jY9RIU/8IYCV9ievpExyDksGG126neiK1a9wac8Q==",
      sandbox: true
    drivers :
      redirect :
        rememberUser : true
  
  _init : ->
    c = false
    for own key of store.data
      if key.match /dropbox-auth/
        c = true
        @connect()
        break
    if not c then @$.trigger( 'ready', @ )
    
    
  save : ->
    return @$.trigger( 'error', new Error( 'dropbox client not initialized' ) ) if not @client
    ans = {}
    c = 0
    add = ( k, e, s ) =>
      @$.trigger( 'saving', (++c)/5 )
      if e
        @status( 4 )
        @$.trigger( 'error', e )
        return
      ans[ k ] = s
      if ans.root and ans.bookmarks and ans.tags and ans.archive and ans.options
        @$.trigger( 'saved' )
        @status( 1 )
    @$.trigger( 'saving', 0/5 )
    @client.writeFile 'root', JSON.stringify( @data.root, null, 2 ), ( e, s ) -> add 'root', e, s
    @client.writeFile 'bookmarks', JSON.stringify( @data.bookmarks, null, 2 ), ( e, s ) -> add 'bookmarks', e, s
    @client.writeFile 'tags', JSON.stringify( @data.tags, null, 2 ), ( e, s ) -> add 'tags', e, s
    @client.writeFile 'archive', JSON.stringify( @data.archive, null, 2 ), ( e, s ) -> add 'archive', e, s
    @client.writeFile 'options', JSON.stringify( @data.options, null, 2 ), ( e, s ) -> add 'options', e, s

  saveDelayed : ->
    timeout.reset @timer, 1000, -> @save callback
  
  load : ( callback ) ->
    return @$.trigger( 'error', new Error( 'dropbox client not initialized' ) ) if not @client
    ans = {}
    c = 0
    add = ( k, e, s ) =>
      @$.trigger( 'loading', (++c)/5 )
      if e
        @status( 4 )
        @$.trigger( 'error', e )
        return
      ans[ k ] = s
      if ans.root and ans.bookmarks and ans.tags and ans.archive and ans.options
        try
          b = {}
          for key, value of ans
            b[ key ] = JSON.parse( value, revive )
          @status( 1 )
          @$.trigger( 'loaded', b )
        catch e
          @status( 4 )
          @$.trigger( 'error', e )
    @$.trigger( 'loading', 0/5 )
    @status( 2 )
    @client.readFile 'root', ( e, s ) -> add 'root', e, s
    @client.readFile 'bookmarks', ( e, s ) -> add 'bookmarks', e, s
    @client.readFile 'tags', ( e, s ) -> add 'tags', e, s
    @client.readFile 'archive', ( e, s ) -> add 'archive', e, s
    @client.readFile 'options', ( e, s ) -> add 'options', e, s
      
  
  connect : ->
    cfg = @cfg
    @client = new Dropbox.Client cfg.client
    @client.authDriver new Dropbox.Drivers.Redirect cfg.drivers.redirect
    @client.authenticate ( e ) =>
      @status( if e then 4 else 1 )
      if not e
        @$.trigger( 'ready' )
        @$.trigger( 'connected' )
  
  disconnect : ->
    return @$.trigger( 'error', new Error( 'dropbox client not initialized' ) ) if not @client or not @client.signOff
    @client.signOff =>
      @status 0
      store.remove key if key.match /dropbox-auth/ for own key of store.data
      @$.trigger( 'disconnected' )
