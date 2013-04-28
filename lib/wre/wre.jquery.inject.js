(function( $ ){
  $.injectScript = function(){
    var script = [].slice.call(arguments);
    $.each( script, function( i, n ){
      $.holdReady( true );
      var src = $( "<script>" ).insertAfter("script:last");
      if ( n.id !== undefined ) { src.attr( "id", n.id ); }
      if ( n.type !== undefined ) { src.attr( "type", n.type ); }
      src.load( n.src , function(){ $.holdReady( false ); } );
    });  
  };
}( jQuery ));