do ( $ = jQuery, view = "body", model = window.note = SimpleNote.activeInstance = new SimpleNote()  ) ->

  applicationCache.onchecking =-> $.holdReady(on)
  applicationCache.ondownloading =-> $.holdReady(on)
  applicationCache.onerror =-> $.holdReady(off); model.connectionStatus(0)
  applicationCache.onnoupdate =-> $.holdReady(off); model.connectionStatus(1)
  applicationCache.onprogress =-> $.holdReady( on ); delay -> $( '#curtain' ).find('i').after('.');
  applicationCache.onupdateready = applicationCache.oncached = ->
    $.holdReady( on )
    delay -> location.reload()
    timeout.set 1000, -> 
      $( '#curtain' ).find( 'i' ).after( "<br>there is a new version of this app.<br>please <a style='color:cyan' href='index.html'>reload the page manually</a>" ).find( 'a' ).focus()

    # jquery onload event
  $ ->
    # some fixed jquery elements
    model.doc = $ document
    model.win = $ window
    model.view = $ view
    delay -> model.pop = $('audio')[0] # this needs to be delayed. due to a bug maybe?
    # apply knockout bindings
    ko.applyBindings model, model.view[0]
    # revive model
    model.revive()
    # get build info
    model.getBuild()
    # apply key bindings
    model.attachEvents()
    # start periodical saving
    model.startPeriodicalSave()
    # start checking for connectionStatus
    model.startOnlineCheck()
        
    # lift the curtains
    delay -> $("#curtain").fadeOut("slow", -> $('body').css('overflow','auto') )    
    null
