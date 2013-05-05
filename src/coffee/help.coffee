do ( $ = jQuery, view = "body", model = SimpleNote.activeInstance ) ->
  a = new Node( )
  a.id = 'help'
  a.title 'help'
  a.parents = =>
    [ model.root ]
  a.notes( """
    welcome to simplenote help.<br>
    
    here, i will try to help you getting startet with this awesome little outliner.<br><br>
    
    doubleclick the title or click ( details... ) to open the first node titled 'first steps'
    
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
    
  
  
  
  a.children [ c, d, b ]
  d.children [ e, f ]
  f.children [ g ]
  
  for node in [ a, b, c, d, e, f, g ] 
    do ->
      node.remove = -> alert 'cannot delete this node'
      node._delete = -> return null
      node.readonly = true