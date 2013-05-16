keys =
    BACKSPACE : 8
    TAB       : 9
    ENTER     : 13
    ESC       : 27
    PGUP      : 33
    PGDOWN    : 34
    END       : 35
    HOME      : 36
    LEFT      : 37
    UP        : 38
    RIGHT     : 39
    DOWN      : 40
    SPACE     : 32
    DEL       : 46

SimpleNote::attachClicks = ->
  console.log @
  
  [ model, $view, $doc ] = [ @, @view, @doc ]
  
  # click events

  # focus title on click on headlin
  $view.off 'click.headline'
  $view.on 'click.headline', '.headline', (e)->
    $t = $ e.target
    $t.parents(".headline").find("title").focus() unless $t.is(".bullet, .action, .info")

  # save model on every click or keyup
  $view.off 'keyup.doc, click.doc'
  $view.on 'keyup.doc, click.doc', => model.save()

  # tags menu 
  @$tagsMenu = $tagsMenu = $( '#tagsMenu', $view )
  $tagsMenu.off 'dismiss, call, click.li, click.addtag, keydown.input'
  $tagsMenu.data( 'node', 
    null
  ).on( 'dismiss', ->
    $( this ).fadeOut 'fast',->$( this ).css { top : '', left : '' }
  ).on( 'call', (e,node,o) ->
    $doc.off 'click.tagsmenu'
    $this = $(this).position({my:'right top',at:'right bottom',of:o.target}).fadeIn('fast').data('node',node)
    $this.find( 'input' ).focus()
    $doc.on 'click.tagsmenu', (e)->
      return if e.timeStamp is o.timeStamp or $( e.target ).parents( '#tagsMenu' ).length isnt 0
      $doc.off 'click.tagsmenu'
      $this.trigger( 'dismiss' )
  ).on( 'click.li', 'li.list', -> 
    tag = ko.dataFor this; node = $#tagsMenu.data( 'node' );
    if node.tags.remove(tag).length is 0 then node.tags.push tag
  ).on( 'click.addtag', 'i.icon-tag.addTag', ->
    console.log 'clicked'
    return if not ( name = $(this).prev().val() )
    $tagsMenu.data( 'node' ).tags.push new Tag( { name: name } )
    $(this).next().val( '' ).focus()
  )
  .on( 'keydown.input', 'input', (e)->
    $("body").append(e.which)
    $tagsMenu.trigger( 'dismiss' ) if e.which is keys.ESC
    return if e.which isnt keys.ENTER
    $( this ).next().trigger( 'click' )
  )
  # searchbar tags
  $( '#search > div > .icon-tags', $view ).off 'click.icontag'
  $( '#search > div >.icon-tags', $view ).on 'click.icontag', (e)->
    model.editingFilter on
    t = $ '#tags'
    return t.slideUp() if t.is 'visible'
    t.slideDown 'fast'
    $doc.on 'click.tagsfilter', (f)->
      return if e.timeStamp is f.timeStamp or $(f.target).is('.icon-trash')
      $doc.off 'click.tagsfilter'
      t.slideUp 'fast'
      
  # searchbar bookmarks
  $( '#search > div >.icon-star', $view ).off 'click.iconstar'
  $( '#search > div >.icon-star', $view ).on 'click.iconstar', (e)->
    model.editingFilter on
    b = $ '#bookmarks'
    return b.slideUp() if b.is 'visible'
    b.slideDown 'fast'
    $doc.on 'click.bookmarks', (f)->
      return if e.timeStamp is f.timeStamp or $(f.target).is('.icon-star-half')
      $doc.off 'click.bookmarks'
      b.slideUp 'fast'   
      
  # searchbar more
  $( '#search > div > .icon-ellipsis-vertical' ).off 'click.special'
  $( '#search > div > .icon-ellipsis-vertical' ).on 'click.special', (e) ->
    s = $( '#specialPages' )
    if s.is 'visible' then return s.slideUp()
    s.slideDown 'fast'
    $doc.on 'click.specialPages', (f)->
      return if e.timeStamp is f.timeStamp
      $doc.off 'click.specialPages'
      s.slideUp 'fast'
   
# keydown events

SimpleNote::detachHotkeys = ->
    @doc.off 'keydown.hotkeys'

SimpleNote::attachHotkeys = ->
  
  model = @

  stop =(e)-> 
    e.stopPropagation()
    e.preventDefault()
  
  eventToBits = ( e ) ->
    [ 
      if e.altKey then 1 else 0
      if e.ctrlKey then 1 else 0
      if e.shiftKey then 1 else 0
      e.which
    ].join ""
    
  keysToBits = ( a ) ->
    [ 
      if a.match /alt/i then 1 else 0
      if a.match /ctrl/i then 1 else 0
      if a.match /shift/i then 1 else 0
    (( c = a.match( /(?:ctrl|alt|shift|\s)*(?:\s|^)(\w{2,})(?=\s|$)/i ) ) and ( keys[ c[1].toUpperCase() ] )) or (( c = a.match(/(?:ctrl|alt|shift|\s)*(?:\s|^)([\w\d]{1})(?=\s|$)/i ) ) and (c = c[1].toUpperCase().charCodeAt(0)))
    ].join ""
  
  hotkeybits = {}
  
  for h in @options.hotkeys
    if not hotkeybits[ keysToBits( h[0] ) ]
      hotkeybits[ keysToBits( h[0] ) ] = [[ h[1],h[2] ]]
    else
      hotkeybits[ keysToBits( h[0] ) ].push [ h[1],h[2] ]
  @doc.on 'keydown.hotkeys', ( e )->
    if h = hotkeybits[ eventToBits( e ) ]
      $t = $ e.target
      if not $t[0].nodeType then $t = $view
      for k in h
        if not k[0] or $t.is(k[0])
          stop e
          model.functions[ k[1] ]?( e, $t, ko.dataFor( $t[0] ) , ko.contextFor( $t[0] ).$root )
