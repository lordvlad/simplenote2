# jquery closure
do ( $ = jQuery, view = "body", model = window.note = new SimpleNote ) ->
  # jquery onload event
  $ ->
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
    # lift the curtains
    delay -> $("#curtain").fadeOut("slow");    
    # create right click context menu-1
    $( '#tagsMenu', view ).data( 'smplnt-reference', 
      null
    ).on( 'call', (e,node,o) ->
      $( document ).off 'click.tagsmenu'
      $this = $(this).position({my:'right top',at:'right bottom',of:o.target}).fadeIn('fast').data('node',node)
      o.stopPropagation(); o.preventDefault(); e.stopPropagation(); e.preventDefault();
      $( document ).on 'click.tagsmenu', (e)->
        return if e.timeStamp is o.timeStamp or $( e.target ).parents( '#tagsMenu' ).length isnt 0
        $( document ).off 'click.tagsmenu'
        $this.fadeOut 'fast',->$this.css { top: '', left: '' }
        on
      on
    ).on( 'click', 'li', -> 
      tag = ko.dataFor this; node = $( this ).parents( '#tagsMenu' ).data( 'node' );
      if node.tags.remove(tag).length is 0 then node.tags.push tag
    )
      
      