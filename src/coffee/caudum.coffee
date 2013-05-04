# jquery closure
do ( $ = jQuery, view = "body", model = SimpleNote.activeInstance = new SimpleNote()  ) ->
  applicationCache.oncached =-> console.log('cached')
  applicationCache.onchecking =-> console.log('checking'); $.holdReady(on)
  applicationCache.ondownloading =-> console.log('downloading'); $.holdReady(on)
  applicationCache.onerror =-> console.log('offline'); $.holdReady(off); SimpleNote.connectionStatus(off)
  applicationCache.onnoupdate =-> console.log('online'); $.holdReady(off); SimpleNote.connectionStatus(on)
  applicationCache.onobsolete =-> console.log('obsolete')
  applicationCache.onprogress =-> console.log('progress')
  applicationCache.onupdateready = ->
    console.log('ready')
    delay -> location.href='index.html'
    delay -> $( '#curtain' ).find( 'i' ).after( "<br>there is a new version of this app.<br>please <a style='color:cyan' href='index.html'>reload the page manually</a>" ).find( 'a' ).focus()

    # jquery onload event
  $ ->
    # extend window with simplenote classes
    $.extend true, window, {
      SimpleNote        : SimpleNote
      note              : SimpleNote.activeInstance
      Node              : Node
      Tag               : Tag
    }
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
    # create right click context menu-1
    $( '#tagsMenu', view ).data( 'node', 
      null
    ).on( 'dismiss', ->
      $( this ).fadeOut 'fast',->$( this ).css { top: '', left: '' }
    ).on( 'call', (e,node,o) ->
      $( document ).off 'click.tagsmenu'
      $this = $(this).position({my:'right top',at:'right bottom',of:o.target}).fadeIn('fast').data('node',node)
      $this.find( 'input' ).focus()
      $( document ).on 'click.tagsmenu', (e)->
        return if e.timeStamp is o.timeStamp or $( e.target ).parents( '#tagsMenu' ).length isnt 0
        $( document ).off 'click.tagsmenu'
        $this.trigger( 'dismiss' )
    ).on( 'click', 'li.list', -> 
      tag = ko.dataFor this; node = $( this ).parents( '#tagsMenu' ).data( 'node' );
      if node.tags.remove(tag).length is 0 then node.tags.push tag
    ).on( 'click', 'i.icon-plus', ->
      return if not ( name = $(this).next().val() )      
      $( this ).parents( '#tagsMenu' ).data( 'node' ).tags.push new Tag( { name: name } )
      $(this).next().val( '' ).focus()
    ).on( 'keydown', 'input', (e)->
      $( this ).parents( '#tagsMenu' ).trigger( 'dismiss' ) if e.which is ESC
      return if e.which isnt ENTER
      $( this ).prev().trigger( 'click' )
    )
    
    $( '#search > div >.icon-tags', view ).click (e)->
      model.editingFilter on
      return $( '#tags' ).slideUp() if $( '#tags' ).is 'visible'
      $( '#tags' ).slideDown 'fast'
      $( document ).on 'click.tagsfilter', (f)->
        return if e.timeStamp is f.timeStamp
        $( document ).off 'click.tagsfilter'
        $( '#tags' ).slideUp 'fast'
        
    $( '#search > div >.icon-star', view ).click (e)->
      model.editingFilter on
      if $( '#bookmarks' ).is 'visible' then return $( '#bookmarks' ).slideUp()
      $( '#bookmarks' ).slideDown 'fast'
      $( document ).on 'click.bookmarks', (f)->
        return if e.timeStamp is f.timeStamp
        $( document ).off 'click.bookmarks'
        $( '#bookmarks' ).slideUp 'fast'   
        
        
    # lift the curtains
    delay -> $("#curtain").fadeOut("slow");    
    null  