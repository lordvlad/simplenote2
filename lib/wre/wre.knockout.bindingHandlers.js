(function($,ko){
  "use strict";
  $.extend(true,ko.bindingHandlers, {
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
        $(el).on("dblclick", function(){ acc().call(obj);});
      }
    },
    editable : {
      init : function( el, acc ){
        $(el).attr("contenteditable",true).html(acc()()).blur(function(){acc()($(el).html().replace(/&nbsp;$|^&nbsp;|^\s*|\s*$/g,""));}).focus(function(){$(el).html(acc()()||"");});
        acc().subscribe(function(){$(el).html(acc()());});
      }
    },
    sortable : {
      init : function( el, acc, all, data, context ){
        $( el ).sortable( $.extend( acc(), {
            
        }));
      }
    }
  });
}(jQuery, ko));