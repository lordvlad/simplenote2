# jquery closure
do ( $ = jQuery, view = "body", model = SimpleNote.activeInstance = new SimpleNote()  ) ->
  applicationCache.onchecking =-> $.holdReady(on)
  applicationCache.ondownloading =-> $.holdReady(on)
  applicationCache.onerror =-> $.holdReady(off); model.connectionStatus(0)
  applicationCache.onnoupdate =-> $.holdReady(off); model.connectionStatus(1)
  applicationCache.onprogress =-> delay -> $( '#curtain' ).find('i').after('.');
  applicationCache.onupdateready = ->
    delay -> location.href='index.html'
    timeout.set 1000, -> $( '#curtain' ).find( 'i' ).after( "<br>there is a new version of this app.<br>please <a style='color:cyan' href='index.html'>reload the page manually</a>" ).find( 'a' ).focus()

    # jquery onload event
  $ ->
    # extend window with simplenote classes
    $.extend true, window, {
      SimpleNote        : SimpleNote
      note              : model
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
        return if e.timeStamp is f.timeStamp or $(f.target).is('.icon-trash')
        $( document ).off 'click.tagsfilter'
        $( '#tags' ).slideUp 'fast'
        
    $( '#search > div >.icon-star', view ).click (e)->
      model.editingFilter on
      if $( '#bookmarks' ).is 'visible' then return $( '#bookmarks' ).slideUp()
      $( '#bookmarks' ).slideDown 'fast'
      $( document ).on 'click.bookmarks', (f)->
        return if e.timeStamp is f.timeStamp or $(f.target).is('.icon-star-half')
        $( document ).off 'click.bookmarks'
        $( '#bookmarks' ).slideUp 'fast'   
        
        
    # lift the curtains
    delay -> $("#curtain").fadeOut("slow", -> $('body').css('overflow','auto') )    
    null  