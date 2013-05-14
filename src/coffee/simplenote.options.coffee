# hotkeyfunctions
SimpleNote::functions = 
  next : ( e ) ->
    if ( t = $(e.target).findNext( '.title:visible' )[0] )
      ko.dataFor( t ).active on
  prev : ( e )->
    if ( t = $(e.target).findPrev( '.title:visible' )[0] )
      ko.dataFor( t ).active on
  focusSearch : ->
    $( '#search input' ).focus()
  blurFocus : ->
    $( '#search input' ).blur()
    
    
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
    [ 'ctrl j', null, 'next' ]
    [ 'down', null, 'next' ]
    [ 'ctrl k', null, 'prev' ]
    [ 'up', null, 'prev' ]
    [ 'esc', null, 'focusSearch' ]
    [ 'esc', '#search input', 'blurFocus' ]
  ]