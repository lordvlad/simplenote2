do ( $ = jQuery, view = "body", model = window.note ) ->
  a = new Node( )
  a.id = 'help'
  a.title 'help'
  a.notes( """
    welcome to simplenote help.<br>
    
    here, i will try to help you getting startet with this awesome little outliner.<br>
    
    double click on one of the items below to read more,<br>
    or click on the triangle ( #{Node.bullets.right} ) to unfold an outline item.
  """ )
  a.parents = =>
    [ model.root ]
   
  b = new Node()
  b.id = 'offline'
  b.title 'working offline'
  b.notes( """
    simplenote is capable of working offline, too, because all data is saved only in your browser anyway!  
  """ )  
  b.parents = =>
    [ model.root, a ]
    
  
  a.children [ b ]
  
  for node in [ a, b ] 
    do ->
      node.remove = -> alert 'cannot delete this node'
      node._delete = -> return null 