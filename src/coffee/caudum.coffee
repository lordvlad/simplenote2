applicationCache.onupdateready = ->
  $.holdReady on
  $( '#curtain' ).css('font-size','.25em').find( 'i' ).after( "<br><span>there is a new version of this app.<br>please <a style='color:cyan' href='index.html'>reload the page</a></a>" )

# jquery closure
do ( $ = jQuery ) ->
  # jquery onload event
  $ ->
    view = "body"
    model = window.note = new SimpleNote 
    # extend window with simplenote classes
    $.extend true, window, {
      SimpleNote  : SimpleNote
      Node        : Node
      Tag         : Tag
    }
    # attach view to model
    model.attachElements view
    # apply knockout bindings
    ko.applyBindings model, model.view
    # revive model
    model.revive()
    # apply key bindings
    model.applyEvents()
    # start periodical saving
    model.startPeriodicalSave()
    # create right click context menu-1
    $( '#tagsMenu', view ).data( 'smplnt-reference', 
      null
    ).on( 'call', (e,node,o) ->
      $( document ).off 'click.tagsmenu'
      $this = $(this).position({my:'right top',at:'right bottom',of:o.target}).fadeIn('fast').data('node',node)
      # o.stopPropagation(); o.preventDefault(); e.stopPropagation(); e.preventDefault();
      $( document ).on 'click.tagsmenu', (e)->
        return if e.timeStamp is o.timeStamp or $( e.target ).parents( '#tagsMenu' ).length isnt 0
        $( document ).off 'click.tagsmenu'
        $this.fadeOut 'fast',->$this.css { top: '', left: '' }
        on
      on
    ).on( 'click', 'li', -> 
      tag = ko.dataFor this; node = $( this ).parents( '#tagsMenu' ).data( 'node' );
      if node.tags.remove(tag).length is 0 then node.tags.push tag
    );
    
    $( '#search > div >.icon-tags', view ).click (e)->
      model.editingFilter on
      return $( '#tags' ).slideUp() if $( '#tags' ).is 'visible'
      $( '#tags' ).slideDown 'fast'
      $( document ).on 'click.tagsfilter', (f)->
        return if e.timeStamp is f.timeStamp or $( f.target ).parents( '#tags' ).length isnt 0
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