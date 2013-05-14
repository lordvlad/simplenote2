# set screensize under which the device will be regarded as mobile
# should be the same number which is found in src/less/mobile.less
maxScreenWidthForMobile = 480
{ author, email, github, version, revision, date } = JSON.parse jQuery.ajax({url:'build.json',async:false}).responseText
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
  
# revive objects
revive = ( key, value ) ->
  if value and ( c = value.__constructor ) and ( c = revive.constructors[ c ] ) and ( typeof c.fromJSON is "function" )
    c.fromJSON( value )
  else value
revive.constructors = {}
  
# create storage
store =
  set : ( key, val ) -> localStorage.setItem key, ( if isStr val then val else JSON.stringify val )
  get : ( key ) -> 
    try 
      JSON.parse localStorage.getItem(key), revive
    catch e
      null
  remove : ( key ) -> localStorage.removeItem key
  
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
  for key of map
    if isObj model[ key ] then koMap model[ key ], map[ key ]
    else if ko.isWriteableObservable model[ key ] then model[ key ] map[ key ]
    else model[ key ] = map[ key ]
  model

# wrap location.hash in a ko.computed
hash = do ->
  h = obs ""
  s =-> h location.hash.replace(/#/,"") or ""
  $( window ).on "hashchange", s
  h.subscribe (v) -> location.hash = v
  s(); h
    
# get intersecting elements of two arrays    
intersect = (a,b)-> a.filter( (n)-> return ~b.indexOf(n) )

