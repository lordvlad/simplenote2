(function($,ko){
  "use strict";
  $.extend(true,ko.bindingHandlers, {
    log : {
      init : function( el, acc, all, data, context ){
        console.log( el, data, context );
      }
    },
    table : {
      init : function( el, acc ){
        var cols = acc().cols, data = acc().data, $tbl = $( el ),
          $hea = $( "<tr>" ).appendTo( $tbl );
        cols.forEach(function(hea){
          $( "<th>" ).appendTo( $hea ).html( hea );
        });
        data.forEach(function(row){
         var $row = $( "<tr>" ).appendTo( $tbl );
          row.forEach(function(cell){
            var $cell = $( "<td>" ).appendTo( $row );
            if ( cell && ko.isSubscribable( cell ) ) {
              cell.subscribe( function( v ){ $cell.html( v || "" ); } );
              cell.valueHasMutated();
            } else {
              $cell.html( cell || "" );
            }
          });
        });
      }
    },
    checkbox : {
      init : function( el, acc ){
        var $el = $( el ), $icon = $( "<i>" ), a = 'icon-check', b = 'icon-check-empty';
        $el.hide().after( $icon.on('click', function(){ acc()( ! acc()() );} ));
        acc().subscribe( function( v ){
          $icon.addClass( v ? a : b ).removeClass( v ? b : a );
        });
        acc().valueHasMutated();
      }
    },
    afterRender : {
      init: function( el, acc, all ){
        if ( all().if || all().ifnot ) setTimeout( function(){ acc().call(el,el); }, 25 );
      }
    },
    menu : {
      init : function( el, acc ){
        var $el = $(el),
          selector = acc().selector || acc() || "a",
          eventHandler = acc().onselect || false,
          timer = null,
          hide = function(){ timer = setTimeout(function(){ $el.hide("fast",function(){$el.css({top:0,left:0});}).trigger("release"); }, 250);},
          where = null;
        $el.on( "click.menu", selector, function(e){ $el.trigger("menuselect", { item: ko.dataFor( this ) } ); $el.hide(); })
          .on( "mouseout", hide )
          .on( "mousein, mouseover", function(){ setTimeout(function(){clearTimeout(timer);},1); } )
          .on( "position", function( e, t ){ where = $(t); $el.position({ my:"right top", at:"right bottom", of: where}).show("fast");where.on("mouseout.menu",hide);})
          .on( "release", function(){ $el.off("menuselect"); where.off(".menu"); } );
        if ( eventHandler ) { $el.on( "menuselect", eventHandler ); }
      }
    },
    dblclick : {
      init : function( el, acc, all, obj ){
        function f(){ acc().call(obj);};
        $(el).on("dblclick", f);
        $(el).addSwipeEvents().bind("doubletap",f);
      }
    },
    editable : {
      init : function( el, acc ){
        $(el).attr("contenteditable",true).html(acc()()).blur(function(){acc()($(el).html().replace(/&nbsp;$|^&nbsp;|^\s*|\s*$/g,""));}).focus(function(){$(el).html(acc()()||"");});
        acc().subscribe(function(){$(el).html(acc()());});
      }
    }
  });
}(jQuery, ko));