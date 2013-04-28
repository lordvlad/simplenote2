/*
 * extends knockout observableArrays by filter, find and map
 * @author waldemar.reusch@googlemail.com
 */
(function($,ko){
  "use strict";
  $.extend(true, ko.observableArray.fn, {
    // @param {String|Function} a : key of object to which to compare to, or a function, which will behave as JS native [].filter
    //                              a RegExp can be used too, but makes only sense on arrays of strings
    // @param {Mixed} b           : value to compare to, or RegExp to test against
    // @return {Array}            : filtered array
    filter : function(a,b){
      return this().filter(a.call?a:function(n){if(a.test){return a.test(n);}var x=(n[a].call?n[a]():n[a]);return b?(b.test?b.test(x):x===b):!!x;});
    },
    // behaves exaclty like filter from above, but returns only the first matching element
    // @param {Mixed} c : default return value, if nothing is found. usefull if a following function requires a specific variable type
    find : function(a,b,c){
      return this.filter(a,b)[0]||(c||null);
    },
    // @args {String|Function} : if the first arg is a function, then it will behave like JS native [].map. if there is only one string argument then an array will be returned containing only the values specified by this key. if there are multiple args, then the array will consist of objects with multiple key : value pairs
    map : function(){
      var a = [].slice.call(arguments);
      return this().map(a[0].call?a[0]:function(n){var r={};if(!a[1]){return(n[a[0]]&&n[a[0]].call)?n[a[0]]():n[a[0]];}a.forEach(function(m){r[m]=(n[m]&&n[m].call)?n[m]():n[m];});return r;});
    }
  });
}(jQuery,ko));