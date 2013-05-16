# helper functions
jump = ( e, n, dir ) ->
  c = n.filter( '.title:visible,.topNotes:visible>div,#sheet>.body>div>h1:visible' ).xor( '.body.active .title:visible:first' ).xor( 'body' )
  t = c['find'+dir]?( '#sheet>.body>div>h1:visible, .topNotes:visible>div, .title:visible' )[0]
  if ( t ) and d = ko.dataFor( t )
    ko.dataFor( c[0] ).active?( off )
    if $(t).is('h1') then d.editingTitle on
    if $(t).is('.title') then d.active on
    if $(t).is('.topNotes>div') then d.editingNote on
# hotkeyfunctions
SimpleNote::functions = 
  nextItem : ( e, n ) -> jump e, n, 'Next'
  prevItem : ( e, n )-> jump e, n, 'Prev'
  focusSearch : -> $( '#tagsmenu' ).trigger( 'dismiss' ); $( '#search input' ).focus()
  blurSearch : ->  $( '#tagsmenu' ).trigger( 'dismiss' );  $( '#search input' ).blur()
  selectItem : ( e, n, d ) -> d.toggleSelected?()
  zoomIn : ( e, n, d ) -> d.open?()
  zoomOut : ( e, n, d, r ) -> (y=(x=r.current()).editingNote(off).editingTitle(off).parent())?.open?();y.editingNote(off);x.active(on);
  addChild : ( e, n, d, r ) -> r.addNodeTo?( d.expanded?( on ) )
  addSibling : ( e, n, d, r ) -> r.addNodeTo?( d.parent() )
  editNotes : ( e, n, d ) -> d.expanded(on).editingNote(on)
  editTitle : ( e, n, d ) -> d.editingTitle on
  foldItem : ( e, n, d, r ) -> d.toggleExpanded()
  foldAll : ( e, n, d, r ) ->
    f = ( x )->
      x.expanded off
      f(y) for y in x.children() if x.children().length
    u = ( x, i )->
      return if i-- <= 0
      x.expanded on
      u(y,i) for y in x.children() if x.children().length 
      
    f( r.current() )
    u( r.current(), e.which - 48 )
    
# set up options
SimpleNote::options = 
  print : 
    breadcrumbs : obs off
    tags : obs off
    colors : obs on
  appearance :
    titles : obs on
  dropbox : 
    sync : obs off
  hotkeys : [
    # manouvering
    [ 'ctrl j', null, 'nextItem' ]
    [ 'down', null, 'nextItem' ]
    [ 'ctrl k', null, 'prevItem' ]
    [ 'up', null, 'prevItem' ]
    [ 'shift up', null, 'zoomOut' ]
    [ 'shift down', '.title', 'zoomIn' ]
    [ 'ctrl i', '.title', 'zoomIn' ]
    [ 'ctrl o', null, 'zoomOut' ]
    [ 'esc', null, 'focusSearch' ]
    [ 'esc', '#search input', 'blurFocus' ]
    # selecting
    [ 'ctrl space', '.title', 'selectItem' ]
    # folding
    [ 'ctrl u', '.title', 'foldItem' ]
    [ 'ctrl 1', null, 'foldAll' ]
    [ 'ctrl 2', null, 'foldAll' ]
    [ 'ctrl 3', null, 'foldAll' ]
    [ 'ctrl 4', null, 'foldAll' ]
    [ 'ctrl 5', null, 'foldAll' ]
    [ 'ctrl 6', null, 'foldAll' ]
    [ 'ctrl 7', null, 'foldAll' ]
    # editing
    [ 'enter', '.title', 'addSibling' ]
    [ 'shift enter', '.title', 'editNotes' ]
    [ 'shift enter', '.notes>div', 'editTitle' ]
    [ 'ctrl enter', null, 'addChild' ]
  ]