instance = -> SimpleNote.activeInstance
do ->
  statusDef = [
    [ 'not&nbsp;set&nbsp;up', '' ]
    [ 'ready', 'green' ]
    [ 'syncing', 'yellow' ]
    [ 'disconnected', 'red' ]
  ]
  localStorageModule = { name: 'localStorage' }
  module = obs localStorageModule
  subscription = null
  load = null
  save = null
  connect = null
  disconnect = null
  
  activate : ( mod ) =>
  status : status
  module : module
      
  connect : -> 
    if not connect and ( module = store.get 'syncModule' ) and ( module = SimpleNote.syncModules[ module ] )
      activate module
    if connect and instance() then connect.apply instance(), arguments
    
  disconnect : -> store.remove('syncModule'); if disconnect and instance() then disconnect.apply instance(), arguments
  
  
  
  
  status = obs 0
  SimpleNote::sync = 
    name : obs 'localStorage'
    status : status
    statusText : obs -> statusDef[ status() ][0]
    statusColor : obs -> statusDef[ status() ][1]
    save : null
    load : null
    connect : null
    disconnect : null
    
  SimpleNote::connect = ( module = store.get 'syncModule' ) ->
    @sync.disconnect?()
    console.log module
    mod = SimpleNote.syncModules[ mod ] if typeof mod is 'string'
    store.set 'syncModule', module.name
    subscription = module.status.subscribe @status
    module.status.valueHasMutated()
    save = module.save
    load = module.load
    connect = module.connect
    disconnect = module.disconnect
  
  SimpleNote::load = ( callback ) ->
    if load and instance()
      load.call instance()
    else
      callback null, {
        root : store.get 'root'
        bookmarks : store.get 'bookmarks'
        tags : store.get 'tags'
        archive : store.get 'archive'
        options : store.get 'options'
      }
  SimpleNote::save = ( callback ) ->
    return if not @revived
    store.set 'root', JSON.stringify obj.root
    store.set 'bookmarks', JSON.stringify obj.bookmarks
    store.set 'tags', JSON.stringify obj.tags
    store.set 'archive', JSON.stringify obj.archive
    store.set 'options', JSON.stringify obj.options
    if save and instance() 
      save.call instance(), callback
    else
      callback null, obj



# dropbox module



SimpleNote.syncModules.dropbox = do ->

  status = obs 0
  client = timer = null
  saveDelayed = ( obj, callback ) ->
    timeout.reset timer, 1000, -> save obj, callback
    
  save = ( callback ) ->
    ans = {}
    add = ( k, e, s ) ->
      ans[ k ] = e or s
      callback( null, ans ) if ans.root and ans.bookmarks and ans.tags and ans.archive and ans.options
    return if not obj or not callback or not client 
    client.writeFile 'root', JSON.stringify( obj.root, null, 2 ), ( e, s ) -> add 'root', e, s
    client.writeFile 'bookmarks', JSON.stringify( obj.bookmarks, null, 2 ), ( e, s ) -> add 'bookmarks', e, s
    client.writeFile 'tags', JSON.stringify( obj.tags, null, 2 ), ( e, s ) -> add 'tags', e, s
    client.writeFile 'archive', JSON.stringify( obj.archive, null, 2 ), ( e, s ) -> add 'archive', e, s
    client.writeFile 'options', JSON.stringify( obj.options, null, 2 ), ( e, s ) -> add 'options', e, s
  
  load = ( callback ) ->
    return if not callback or not client
    callback( new Error( 'dropbox client not initialized' ), null ) if not client
    ans = {}
    add = ( k, e, s )->
      if e then return callback e, null
      ans[ k ] = s
      if ans.root and ans.bookmarks and ans.tags and ans.archive and ans.options
        try
          ans = JSON.stringify ans
          ans = JSON.parse ans, revive
          callback null, ans
        catch e
          callback e, null
          
    client.readFile 'root', ( e, s ) -> add 'root', e, s
    client.readFile 'bookmarks', ( e, s ) -> add 'bookmarks', e, s
    client.readFile 'tags', ( e, s ) -> add 'tags', e, s
    client.readFile 'archive', ( e, s ) -> add 'archive', e, s
    client.readFile 'options', ( e, s ) -> add 'options', e, s
      
  
  cfg =
    client :
      key: "iWIaoxmWAjA=|63jY9RIU/8IYCV9ievpExyDksGG126neiK1a9wac8Q==",
      sandbox: true
    drivers :
      redirect :
        rememberUser : true
    
  signIn = ( callback, skip ) ->
    connect( callback ) if skip or confirm 'you will be redirected to the dropbox sign in page. after signing and allowing simplenote to access your dropbox, you will be redirected back to simplenote. you will see the updated status on the bottom of the page.'
    
  connect = ( callback ) =>
    instance()?connect 'dropbox'
    client = new Dropbox.Client cfg.client
    client.authDriver new Dropbox.Drivers.Redirect cfg.drivers.redirect
    client.authenticate ( e )=>
      status( if e then 1 else 2 )
      callback [].slice.call( arguments, 1 )
  
  disconnect = ( callback ) =>
    if client and client.signOff
      client.signOff =>
        status 0
        store.remove key if key.match /dropbox-auth/ for own key of store.data
        sub.dispose() for sub in subscriptions
        callback null, 'dropbox disconnected successfully'
    else
      callback null
  ###
  for own key of store.data
    if key.match /dropbox-auth/ then connect(); break;
  ###
  {
    name : 'dropbox'
    load : load
    saveNow : save
    save : saveDelayed
    status : status
    connect : connect
    disconnect : disconnect
  }
