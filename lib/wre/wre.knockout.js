(function(ko){
  "use strict";
  
  // ko.bindingHandlers
  (function($,x){
    x.log = {
      init : function( el, acc, all, data, context ){
        console.log( el, data, context );
      }
    };
    x.table = {
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
    };
    x.checkbox = {
      init : function( el, acc ){
        function t(){ acc()( ! acc()() ); }
        var $el = $( el ), $icon = $( "<i>" ).on('click', t ), a = 'icon-check', b = 'icon-check-empty';
        $el.hide().after( $icon, "&nbsp;" ).on('change', t );
        acc().subscribe( function( v ){ $icon.addClass( v ? a : b ).removeClass( v ? b : a );$el.attr("checked",!!v); });
        acc().valueHasMutated();
      }
    };
    x.afterRender = {
      init: function( el, acc, all ){
        if ( all().if || all().ifnot ) setTimeout( function(){ acc().call(el,el); }, 25 );
      }
    };
    x.menu = {
      init : function( el, acc ){
        var $el = $(el),
          selector = acc().selector || acc() || "a",
          eventHandler = acc().onselect || false,
          timer = null,
          hide = function(){ timer = setTimeout(function(){ $el.hide("fast",function(){$el.css({top:0,left:0});}).trigger("release"); }, 250);},
          where = null;
        $el.on( "click.menu", selector, function(){ $el.trigger("menuselect", { item: ko.dataFor( this ) } ); $el.hide(); })
          .on( "mouseout", hide )
          .on( "mousein, mouseover", function(){ setTimeout(function(){clearTimeout(timer);},1); } )
          .on( "position", function( e, t ){ where = $(t); $el.position({ my:"right top", at:"right bottom", of: where}).show("fast");where.on("mouseout.menu",hide);})
          .on( "release", function(){ $el.off("menuselect"); where.off(".menu"); } );
          if ( eventHandler ) { $el.on( "menuselect", eventHandler ); }
      }
    };
    x.dblclick = {
      init : function( el, acc, all, obj ){
        function f(){ acc().call(obj);};
        $(el).on("dblclick", f);
      }
    };
    x.editable = {
      init : function( el, acc ){
        var $el = $(el);
        $el.attr("contenteditable",true).html(acc()()).blur(function(){acc()($el.html().replace(/&nbsp;$|^&nbsp;|^\s*|\s*$/g,""));}).focus(function(){$el.html(acc()()||"");});
        acc().subscribe(function(){$el.html(acc()());});
        $el.on("keyup",function(){if($el.html().match(/<br[\s\/]*>$/)){$el.html($el.html().replace(/<br[\s\/]*>$/, ""));}});
      }
    };
  }(jQuery, ko.bindingHandlers));

  // ko.observableArray.fn
  (function(x){"use strict";x.filter=function(a,b){return this().filter(a.call?a:function(n){if(a.test){return a.test(n);}var x=((n[a]&&n[a].call)?n[a]():n[a]);return b?(b.test?b.test(x):x===b):!!x;});};x.find = function(a,b,c){return this.filter(a,b)[0]||(c||null);};x.map=function(a){return this().map(a.call?a:function(n){if(a.match){return(n[a]&&n[a].call)?n[a]():n[a];}var r={};a.forEach(function(m){r[m]=(n[m]&&n[m].call)?n[m]():n[m];});return r;});};x.has = function(a){return !!~this().indexOf(a);};}(ko.observableArray.fn));

  // ko.extenders
  (function(x){
    x.parse = function (t,f,r){
      r = ko.computed({read:t,write : function(v,n){if ((n = f(unescape(v)))!==t()){t(n);}}});      
      return r(t()),r;
    };
    x.debounce = function(a,b){
      var r = ko.observable(a()),t = null;
      a.subscribe(function(){clearTimeout(t);t=setTimeout( function(){r(a());},b);});
      return r; 
    };
  }(ko.extenders));

  // ko
  ko.map = function(model, map) {
    var key;
    for (key in map) {
      if ( !map.hasOwnProperty( key ) ){ continue; }
      switch (false) {
        case !$.isPlainObject(model[key]):
          return ko.map(model[key], map[key]);
        case !ko.isWriteableObservable(model[key]):
          model[key](map[key]);
          break;
        default:
          model[key] = map[key];
      }
    }
    return model;
  };
}(ko));