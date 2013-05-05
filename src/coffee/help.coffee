do ( $ = jQuery, view = "body", model = SimpleNote.activeInstance ) ->
  a = new Node( )
  a.id = 'help'
  a.title 'help'
  a.parents = =>
    [ model.root ]
  a.notes( """
    <h1>welcome to simplenote help.</h1>
    here, i will try to help you getting startet with this awesome little outliner.<br><br>    
    doubleclick the title or click ( details... ) to open the first node titled 'first steps'.    
  """ )
  
  c = new Node()
  c.id = 'firstStep'
  c.title 'first step'
  c.parents = =>
    [ model.root, a ]
  c.notes( """
    you opened your first node, YAY!<br><br>
    see how the breadcrumbs above got updated? they provide you a path back to the root.<br><br>
    try to get back to the 'help' page!
  """ )
    
  d = new Node()
  d.id = 'secondStep'
  d.title 'second step'
  d.parents = =>
    [ model.root, a ]
  d.notes( """
    you can also use the little triangles ( #{Node.bullets.right} ) on the side to unfold items <b>if</b> they have more content to them.
    note that on mobile devices this will not unfold but open the item.
  """ )
  
  e = new Node()
  e.id = 'withoutcontent'
  e.title 'i\'m empty :('
  e.parents = =>
    [ model.root, a, d ]
  
  f = new Node()
  f.id = 'withcontent'
  f.title 'i have more to show'
  f.parents = =>
    [ model.root, a, d ]
  f.notes( "see? i have some details " )
  
  g = new Node()
  g.id = 'withcontentcontent'
  g.title 'and another subnote'
  g.parents = =>
    [ model.root, a, d, f ]
  
  b = new Node()
  b.id = 'offline'
  b.title 'working offline'
  b.parents = =>
    [ model.root, a ]
  b.notes( """
    simplenote is capable of working offline, too, because all data is saved only in your browser anyway!<br><br>
    on the bottom of the page, there is a small identifier which will update if you loose or gain an internet connection
  """ )  
    
  h = new Node()
  h.id = 'dropbox'
  h.title 'keep in sync with dropbox'
  h.parents = =>
    [ model.root, a ]
  h.notes( """
    <div class='options'>
    you can use dropbox to keep your notes synced across all your devices.<br><br>
    right now, your dropbox is <span data-bind='text:$root.dropboxStatusText,style:{color:$root.dropboxStatusColor}'></span><br><br>
    you will see your dropbox status at the bottom of the page,too.
    <button>connect to dropbox</button>
    </div>
  """ )
  
  
  a.children [ c, d, b, h ]
  d.children [ e, f ]
  f.children [ g ]
  
  for node in [ a, b, c, d, e, f, g, h ] 
    do ->
      node.remove = -> alert 'cannot delete this node'
      node._delete = -> return null
      node.readonly = true