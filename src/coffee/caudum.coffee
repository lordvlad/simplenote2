do ( $ = jQuery, view = "body", model = window.note = SimpleNote.activeInstance = new SimpleNote()  ) ->
  
  SimpleNote.activeInstance.activeBookmark = Bookmark.active
  SimpleNote.activeInstance.toggleBookmark = Bookmark.toggle


  applicationCache.onchecking =-> $.holdReady(on)
  applicationCache.ondownloading =-> $.holdReady(on)
  applicationCache.onerror =-> $.holdReady(off);
  applicationCache.onnoupdate =-> $.holdReady(off);
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
    # start the sync/online check modules
    model.connect()
    # apply knockout bindings
    ko.applyBindings model, model.view[0]
    # revive model
    model.revive()
    # get build info
    model.getBuild()
    # apply key bindings
    model.attachClicks()
    model.attachHotkeys()
    # start periodical saving
    model.startPeriodicalSave()
    # lift the curtains
    delay -> $("#curtain").fadeOut("slow")
    # focus first item
    model.nodes()[0]?.active?(on).editingTitle?(on)
    null
    # remove pipes from last item in line
    do ->
    lastElement = false;