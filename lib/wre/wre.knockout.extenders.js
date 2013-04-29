/*
 * knockout extenders
 * @author waldemar.reusch@googlemail.com
 */
 
(function($, ko){
  "use strict";
  $.extend(true, ko.extenders, {
    // @param {ko.subscribable} the target which should be parsed
    // @param {String|Function} a function which will parse the written value or a string representing the allowed variable type
    parse : function (t,f,r){
      r = ko.computed({read:t,write : function(v,n){if ((n = f(unescape(v)))!==t()){t(n);}}});      
      return r(t()),r;
    },
    numeric : function(target, precision) {
      var result = ko.computed({
          read: target,
          write: function(newValue) {
              var current = target(),
                  roundingMultiplier = Math.pow(10, precision),
                  newValueAsNum = isNaN(newValue) ? 0 : parseFloat(+newValue),
                  valueToWrite = Math.round(newValueAsNum * roundingMultiplier) / roundingMultiplier;
              if (valueToWrite !== current) {
                  target(valueToWrite);
              } else {
                  if (newValue !== current) {
                      target.notifySubscribers(valueToWrite);
                  }
              }
          }
      });   
      result(target());   
      return result;
    }
  });
}(jQuery,ko));