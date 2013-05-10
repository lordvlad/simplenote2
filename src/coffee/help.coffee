about = 
  id : 'about'
  title : 'about'
  notes : """
    <h2> welcome to the simplenote manual</h2>

    <p>simplenote aims to be your favorite outline tool.</p>

    <p>it evolved from the idea to bring the great and powerful org-mode from the geeky hands of linux-fans to the web. and maybe give it a facelift in the process.</p>
    
    <p>click on a bullet (&nbsp;&bull;&nbsp;) or doubleclick an item title to open it and learn more about this tool.</p>
    """
  children : [{
      id : 'about-help'
      title : 'first steps'
      notes : """
        <h2> congratulations! </h2>
        <p>you did your first step already by opening this page!</p>
        <p>see how the breadcrumbs above got updated? use them to easily navigate into the depths of your notebook.</p>
        <p>items with content will have a halo (&nbsp;<span class='bullet full'></span>&nbsp;) while those without details or subitems won't (&nbsp;&bull;&nbsp;).</p>
        <p>are you using simplenote on a mobile phone or a larger screen? or both?</p>
      """
      children : [
        {
          id : 'about-help-desktop'
          title : 'simplenote on a large screen'
          notes : """
            <h2> simplenote on a large screen </h2>
            <p>so you are using simplenote on a large screen. beautiful!</p>
            <p>when you hover above a note, you will notice a small plus sign appearing left to the bullet (&nbsp;+ &bull;&nbsp;). use this to fold or unfold an item and instantly see its contents. you wont have this feature on a small screen, but there isnt enough space for folding anyway. the plus sign won't appear in the help or options sections either.</p>
            <p>also you will notice a square on the right side of the item you are hovering over (&nbsp;<i class='icon-check-empty'></i>&nbsp;). use this to select (&nbsp;<i class='icon-check'></i>&nbsp;) one or multiple items to perform operations on them.</p>
            <p>to the left of the checkbox appears an tag icon with a plus sign (&nbsp;<i class='icon-tag'>+</i>&nbsp;). click it to edit the tags on your item. this, too, won't be available on smaller screens.</p>
          """
        }, {
          id : 'about-help-mobile'
          title : 'simplenote on a mobile phone'
          notes : """
            <h2> simplenote on a mobile phone </h2>
            <p>so you are using simplenote on a mobile screen. nifty!</p>
            <p>use the bullets (&nbsp;&bull;&nbsp;) and breadcrumbs to navigate through your notebook.</p>
            <p>on the right side of each item you will see a checkbox (&nbsp;<i class='icon-check-empty'></i>&nbsp;). use it to select (&nbsp;<i class='icon-check'></i>&nbsp;) one or multpile items to perform operations on them.</p>
          """
        }, {
          id : 'about-help-offline'
          title : 'simplenote offline'
          notes : """
            <h2> simplenote offline </h2>
            <p>you won't have to do anything special to work offline with simplenote. everything is saved in your browser as you type. go online. go offline. simplenote does'nt care.</p>
            <p>on the bottom of the screen you will see a small notification which will tell you if it is connected to the server or not. but have no fear, the server DOES NOT get any data from simplenote, only the other way around.</p>
          """
        }, {
          id : 'about-help-sync'
          title : 'simplenote sync'
          notes : """
            <h2> simplenote in sync </h2>
            <p>you want to use simplenote on all of your devices? simplenote will gladly help you.</p>
            <p>swing by the <a href='#about-options'>options</a> section and connect simplenote to your favorite online storage system.</p>
            <p>your favorite isn't listed? <a href='mailto:#{email}'>give me a shout</a>, and i will see what i can do for you.</p>
          """
        }
      ]
    },{
      id : 'about-options'
      title : 'options'
      notes : """
        <h2> simplenote options </h2>
        <p>not too much to see here yet, but feel free to play around.</p>
        <p>if you're missing an option, <a href='mailto:#{email}'>raise your voice</a>, and i'll be glad to help you out.</p>
      """
      children : [
        {
          id : 'about-options-appearance'
          title : 'appearance'
          notes : """
            <h2> appearance </h2>
            <p>work in progress</p>
          """
        },{
          id : 'about-options-dropbox'
          title : 'dropbox sync'
          notes : """
            <h2> sync with dropbox </h2>
            <div class='options'>
            <p>your dropbox account is <span data-bind='text:syncStatusText,style:{color:syncStatusColor}'</span></p>
            <p>work in progress</p>
            </div>
          """
        }
      ]
        
    },{
      id : 'about-about'
      title : 'about simplenote'
      notes : """
        <h2> about simplenote </h2>
        <p>version : #{version} </p>
        <p>author : <a href='mailto:#{email}'>#{author}</a></p>
        <p>github : <a href='#{github}'>#{github}</a></p>
        
      """
    }
  ]

addconstructor = (n)->
  n.__constructor = 'Node'
  n.readonly = on
  addconstructor c for c in n.children if n.children

do ( $ = jQuery, view = 'body', model = SimpleNote.activeInstance ) ->
  addconstructor about
  $ ->
    JSON.parse( JSON.stringify( about ), revive )
    model.nodes.find( 'id', 'about' ).parent( model.root )