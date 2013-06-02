$( window ).on
  'noupdate' : ->
    console.log 'appcache is bubbling'
  # pass online offline events to app
  'online, offline' : -> $vm.trigger?.apply vm, arguments
  # while applicationCache is updating
  'appupdating' : ->
    $ -> $( '#curtain div' ).append( '.' )
  # when update is ready
  'appupdateready' : ->
    console.log 'app update ready'
    $ -> $( '#curtain div' ).append( '<br>new version available.<br>please wait a second, or reload<br>the page manually' )
    timeout.set 1000, -> location.reload()
  # when applicationcache is ready
  'appcacheready' : ->
    console.log 'appCache is ready'
    view = 'body'
    vm = new SimpleNote()
    
    # only for debugging purposes
    window.note = vm
  
    vm.activeBookmark = Bookmark.active
    vm.toggleBookmark = Bookmark.toggle
    # wrap vm for easier event handling
    $vm = $ vm
    # jquery onload event
    $ ->
      console.log @, arguments
      $.extend vm, 
        $doc  : $ document
        doc   : document
        $win  : $ window
        win   : window
        $view : $ view
        view  : $( view )[0]
        pop   : $( 'audio' )[0]
            
      ko.applyBindings vm, vm.view
      $vm.trigger 'appsetupready'
    null
  'appReady' : ->
    console.log @
    $( '#curtain' ).show(1).delay(1).fadeOut( 'slow' ) # i need to show and delay the curtain first, else it disappears instantly. bug?
    
    # vm.init()
    # some fixed jquery elements
    # vm.doc = $ document
    # vm.win = $ window
    # vm.view = $ view
    # delay -> vm.pop = $('audio')[0] # this needs to be delayed. due to a bug maybe?
    # start sync modules
    # vm.sync.connect()
    # apply knockout bindings
    # ko.applyBindings vm, vm.view[0]
    # vm.init -> 
    
    # try
    # catch e
    #  console.log e
    #  alert 'there has been an error loading the app, please notify me: waldemar.reusch@googlemail.com. if you know how, it would be awesome if you could provide the console log message.'
    # revive vm
    
    # vm.revive()
    # get build info
    # vm.getBuild()
    # apply key bindings
    # vm.attachClicks()
    # vm.attachHotkeys()
    # start periodical saving
    # vm.startPeriodicalSave()
    # lift the curtains
    # focus first item
    # vm.nodes()[0]?.active?(on).editingTitle?(on)

# applicationCache lifecycle
$( window.applicationCache ).on
  'noupdate' : -> $win.trigger( 'appcacheready' )
  'error' : -> $win.trigger( 'appcacheready' )
  'progress' : -> $win.trigger( 'appupdating' )
  'updateready' : -> $win.trigger( 'appupdateready' )