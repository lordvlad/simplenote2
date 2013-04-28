/*
 * knockout extenders
 * @author waldemar.reusch@googlemail.com
 */
 
(function($, ko){
  "use strict";
  $.extend(true, ko.extenders, {
    // @param {ko.subscribable} the target which should be parsed
    // @param {String|Function} a function which will parse the written value or a string representing the allowed variable type
    parse : function ( target, fn ){
      var type,res;
      if ( typeof fn === "string" ) { 
        type = fn;
        fn = function(val){ return (typeof val === type)? val : null ; }
      }
      if ( typeof fn !== "function" ) { return target; }
      res = ko.computed({
        read : target,
        write : function(val){
          target( fn ( unescape( val ) ) );
        }
      }, this);
      res(target());
      return res;
    }
  });
}(jQuery,ko));