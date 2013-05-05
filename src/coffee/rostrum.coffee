
# set screensize under which the device will be regarded as mobile
# should be the same number which is found in src/less/mobile.less
maxScreenWidthForMobile = 480;


# borrow from jQuery
isFn = jQuery.isFunction
isArr = jQuery.isArray
isObj = jQuery.isPlainObject
isNum = jQuery.isNumeric
isStr = ( v ) -> typeof v is "string"
isDate = ( v ) -> if Object.prototype.toString.call(v) isnt '[object Date]' then return false else return not isNaN v.getTime()

# setTimeout and interval
timeout =
  set : ( ms, fn ) -> setTimeout fn, ms
  clear : ( t ) -> clearTimeout t
interval =
  set : ( ms, fn ) -> setInterval fn, ms
  clear : ( i ) -> clearInterval i
delay = ( fn ) -> timeout.set 1, fn
  
# create storage
store = 
  set : ( key, val ) -> localStorage.setItem key, ( if isStr val then val else JSON.stringify val )
  get : ( key ) -> JSON.parse localStorage.getItem(key), revive
  remove : ( key ) -> localStorage.removeItem key
  
# revive objects
revive = ( key, value ) ->
  if value and value.__constructor and ( c = window[ value.__constructor ] or revive.constructors[ value.class ] ) and typeof c.fromJSON is "function" 
    c.fromJSON( value )
  else value
revive.constructors = []
  
# create observables
obs = ( value, owner ) ->
  switch
    when value and ( value.call or value.read or value.write ) then ko.computed value
    when value and value.map then ko.observableArray value, owner or this
    else ko.observable value
  
# create a uuid
uuid = do () ->
  ids = []
  id = (a) ->
    if a then (a^Math.random()*16>>a/4).toString(16) else ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g,id)
  return () ->
    loop
      e=id()
      break if !~ids.indexOf e
    ids.push(e)
    e
    
# shortcut for new Date()
now =-> new Date()
# create a timer
time = do() ->
  a = obs 0
  interval.set 1e3, ->a now()
  a
  
# get length of an object, array or string
sizeOf = ( v ) ->
  switch
    when isNum v then v.split("").length
    when isStr v or isArr v then v.length
    when isObj v then (k for own k of v).length
    else null

# map values to an knockout model
koMap = ( model, map ) ->
  for key, value of map
    if ko.isWriteableObservable model[ key ] then model[ key ] value
    else model[ key ] = value
  model

# wrap location.hash in a ko.computed
hash = window.hash = do ->
  h = obs ""
  s =-> h location.hash.replace(/#/,"") or ""
  $( window ).on "hashchange", s
  h.subscribe (v) -> location.hash = v
  s(); h
    
# get intersecting elements of two arrays    
intersect = window.intersect = (a,b)-> a.filter( (n)-> return ~b.indexOf(n) )

# supply shortcuts for popular keys
$.extend true, window, {
  ESC       : 27
  ENTER     : 13
  TAB       : 9
  BACKSPACE : 8
  SPACE     : 32
  UP        : 38
  DOWN      : 40
  LEFT      : 37
  RIGHT     : 39
  DEL       : 46
  HOME      : 36
  PGUP      : 33
  PGDOWN    : 34
  END       : 35
}

