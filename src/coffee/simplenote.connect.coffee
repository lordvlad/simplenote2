statusDef = [
  [ "not&nbsp;set&nbsp;up", "" ]
  [ "disconnected", "red" ]
  [ "connected", "green" ]
  [ "syncing", "yellow" ]
]

# sync status for the one active sync service
SimpleNote::connection = {}
SimpleNote::sync =
  name : obs "sync"
  status : obs "not&nbsp;set&nbsp;up"
  statusColor : obs ""
  
SimpleNote::connect = ->
  @connection[ name ] = module.call( @ ) for name, module of @connection

# modules

SimpleNote::connection.dropbox = ->  
  
  status = obs 0
  statusText = obs -> statusDef[ status() ][0]
  statusColor = obs -> statusDef[ status() ][1]
  
  subscriptions = []
  
  client = null
  
  cfg =
    client :
      key: "cln+B5NwqGA=|N/KUCgCLbVZehdt1CotiS+DAShiZXv3bjTYU2aU56g==",
      sandbox: false
    drivers :
      redirect :
        rememberUser : true
    
  signIn = ->
    connect() if confirm 'you will be redirected to the dropbox sign in page. after signing and allowing simplenote to access your dropbox, you will be redirected back to simplenote. you will see the updated status on the bottom of the page.'
    
  connect = =>
    client = new Dropbox.Client cfg.client
    client.authDriver new Dropbox.Drivers.Redirect cfg.drivers.redirect
    client.authenticate ( e )=>
      if e
        status 1
        return @notifications.push e
      @sync.name 'dropbox'
      subscriptions = [
        statusText.subscribe( (v)=> @sync.status(v) )
        statusColor.subscribe( (v)=>@sync.statusColor(v) )
      ]
      status 2
      console.log client
  
  disconnect = =>
    return if not client and client.signOff
    client.signOff =>
      status 0
      store.remove key if key.match /dropbox-auth/ for own key of store.data
      sub.dispose() for sub in subscriptions
      @notifications.push '<i class=\"icon-cloud\"></i>&nbsp;dropbox dissconnected successfully'
  
  for own key of store.data
    if key.match /dropbox-auth/ then connect(); break;
  
  {
    connect : signIn
    status : status
    statusText : statusText
    statusColor : statusColor
    disconnect : disconnect
  }
