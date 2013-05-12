# jquery closure
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
    # apply knockout bindings
    ko.applyBindings model, model.view
    # attach view to model
    model.attachElements view
    # revive model
    model.revive()
    # apply key bindings
    model.applyEvents()
    # start periodical saving
    model.startPeriodicalSave()
    # start checking for connectionStatus
    model.startOnlineCheck()
        
    # lift the curtains
    delay -> $("#curtain").fadeOut("slow", -> $('body').css('overflow','auto') )    
    null  