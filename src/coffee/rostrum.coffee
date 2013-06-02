# constants
# set screensize under which the device will be regarded as mobile
# should be the same number which is found in src/less/mobile.less
MAXSCREENWIDTHFORMOBILE = 480

# main variables
$    = jQuery
$win = $ window
$doc = $ document
vm   = null
$vm  = null


# get build information from build.json
{ author, email, github, version, revision, date } = JSON.parse $.ajax({url:'build.json',async:false}).responseText


# inject templates
do -> 
  scripts = [
    {src: "tmpl/nodeTemplate.html", id:"nodeTemplate"},
    {src: "tmpl/readonlyNodeTemplate.html", id:"readonlyNodeTemplate"},
    {src: "tmpl/bodyTemplate.html", id:"bodyTemplate"}
  ]
  for script in scripts
    $.holdReady( true )
    $( '<script id="'+script.id+'" type="text/html">' ).insertAfter( 'script:last' ).load( script.src, -> $.holdReady( false ) )
  

# borrow functions from jQuery
isFn = $.isFunction
isArr = $.isArray
isObj = $.isPlainObject
isNum = $.isNumeric
isStr = ( v ) -> typeof v is "string"
isDate = ( v ) -> if Object.prototype.toString.call(v) isnt '[object Date]' then return false else return not isNaN v.getTime()


# more consistent access to common javascript apis
# timeout
timeout =
  set : ( ms, fn ) -> setTimeout fn, ms
  clear : ( t ) -> clearTimeout t
  reset : ( t, ms, fn ) -> clearTimeout(t); t = setTimeout(fn, ms);
# delay a function until after the current runtime
delay = ( fn ) -> setTimeout fn, 1
# interval
interval =
  set : ( ms, fn ) -> setInterval fn, ms
  clear : ( i ) -> clearInterval i
  reset : ( i, ms, fn ) -> clearInterval(i); i = setInterval(fn, ms);
# access localStorage
store =
  data : localStorage
  remove : ( key ) -> localStorage.removeItem key
  set : ( key, val ) -> localStorage.setItem key, ( if isStr val then val else JSON.stringify val )
  get : ( key ) -> 
    try 
      JSON.parse localStorage.getItem( key ), revive
    catch e
      localStorage.getItem key
  # revive objects
revive = ( key, value ) ->
  if value and ( c = value.__constructor ) and ( c = revive.constructors[ c ] ) and ( typeof c.fromJSON is "function" )
    c.fromJSON( value )
  else value
revive.constructors = {}
  
  
# create observables
# shortcode for ko.observable, ko.observableArray, ko.computed
obs = ( value, owner ) ->
  switch
    when value and ( value.call or value.read or value.write ) then ko.computed value
    when value and value.map then ko.observableArray value, owner or this
    else ko.observable value
  
# create a uuid
uuid =  (a) -> if a then (a^Math.random()*16>>a/4).toString(16) else ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g,uuid)
# shortcode for new Date()
now =-> new Date()

# create a ko.observable timer
time = do() ->
  second = obs 0
  interval.set 1e3, -> second now()
  second
  
# get length of an object, array or string
sizeOf = ( v ) ->
  switch
    when isNum v then v.split("").length
    when isStr v or isArr v then v.length
    when isObj v then (k for own k of v).length
    else null

# wrap location.hash in a ko.computed
hash = do ->
  hash = obs ""
  update =-> hash location.hash.replace(/#/,"") or ""
  $( window ).on "hashchange", update
  hash.subscribe ( newHash ) -> location.hash = newHash
  update()
  return hash
# wrap document.title in a ko.computed
title = obs {
  read: -> hash(); document.title.replace 'simpleNote | ', ''
  write: (v)-> document.title = 'simpleNote | ' + v
}
  
# get intersecting elements of two arrays    
intersect = (a,b)-> a.filter( (n)-> return ~b.indexOf(n) )

