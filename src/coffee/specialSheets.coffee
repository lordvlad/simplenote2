do ->
  specialPages = [{
      id : 'help'
      title : 'help'
      notes : """
        <h2> welcome to the simplenote manual</h2>
        <p>simplenote aims to be your favorite outline tool.</p>

        <p>it evolved from the idea to bring the great and powerful org-mode from the geeky hands of linux-fans to the web. and maybe give it a facelift in the process.</p>
        
        <p>click on a bullet (&nbsp;&bull;&nbsp;) or doubleclick an item title to open it and learn more about this tool.</p>
        <p>to get back to your notebook, click the menu button on the top right ( <i class='icon-ellipsis-vertical'></i> ) and choose the notebook from the appearing menu</p>
      """
      children : [
        {
          id : 'help-first-step'
          title : 'first steps'
          notes : """
            <h2> congratulations! </h2>
            <p>you did your first step already by opening this page!</p>
            <p>see how the breadcrumbs above got updated? use them to easily navigate into the depths of your notebook.</p>
            <p>with your own notes there will be an action bar appearing below the breadcrumbs with buttons to change tags, deadlines, files and more.</p>  
            <p>items with content will have a halo (&nbsp;<span class='bullet full'></span>&nbsp;) while those without details or subitems won't (&nbsp;&bull;&nbsp;).</p>
            <p>use the breadcrumbs to get back to the first help page</p>
          """
        },{
          id : 'help-menu'
          title : 'the menu'
          notes : """
            <h2> menu allmighty </h2>
            <p>click the menu icon ( <i class='icon-ellipsis-vertical'></i> ) to open up simplenote's menu. click on the items below to learn what each of the menu items does.</p>
          """
          children : [
            {
              id : 'help-menu-notebook'
              title : '<i class=\'icon-book\'></i>&nbsp;notebook'
              notes : """
                <h2> the center of simplenote </h2>
                <p>at its core, simplenote is just a note-taking app, so you will propably spend the most of your time here.</p>
                <p>you will learn more on how to work with simplenote when you progress to the chapters about working on a desktop or mobile screen.</p>
                <p>or you can just skip <a href='#help-desktop'>there</a> or <a href='#help-mobile'>there</a>.</p>
              """
            },{
              id : 'help-menu-agenda'
              title : '<i class=\'icon-time\'></i>&nbsp;agenda'
              notes : """
                <h2> coming soon </h2>
              """
            },{
              id : 'help-menu-calendar'
              title : '<i class=\'icon-calendar\'></i>&nbsp;calendar'
              notes : """
                <h2> coming soon </h2>
              """
            },{
              id : 'help-menu-timesheet'
              title : '<i class=\'icon-ticket\'></i>&nbsp;timeheet'
              notes : """
                <h2> coming soon </h2>
              """
            },{
              id : 'help-menu-archive'
              title : '<i class=\'icon-folder-open-alt\'></i>&nbsp;archive'
              notes : """
                <h2> do not throw away </h2>
                but do archive instead.
                <p>instead of deleting items, you can archive them, and they will appear in your archive. from here, you can restore them and move them back to your notebook.</p>
                <p>do not be concerned about a huge archive slowing down your loading times. the archive is loaded seperately, <u>after</u> your notebook.</p>
              """
            },{
              id : 'help-menu-options'
              title : '<i class=\'icon-cog\'></i>&nbsp;options'
            },{
              id : 'help-menu-help'
              title : '<i class=\'icon-question\'></i>&nbsp;help'
            },{
              id : 'help-menu-about'
              title : '<i class=\'icon-info\'></i>&nbsp;about'
            }
          ]
        },{
          id : 'help-desktop'
          title : 'simplenote on a large screen'
          notes : """
            <h2> simplenote on a large screen </h2>
            <p>so you are using simplenote on a large screen. beautiful!</p>
            <p>when you hover above a note, you will notice a small plus sign appearing left to the bullet (&nbsp;+ &bull;&nbsp;). use this to fold or unfold an item and instantly see its contents. you wont have this feature on a small screen, but there isnt enough space for folding anyway. the plus sign won't appear in the help or options sections either.</p>
            <p>also you will notice a square on the right side of the item you are hovering over (&nbsp;<i class='icon-check-empty'></i>&nbsp;). use this to select (&nbsp;<i class='icon-check'></i>&nbsp;) one or multiple items to perform operations on them.</p>
            <p>to the left of the checkbox appears an tag icon with a plus sign (&nbsp;<i class='icon-tag'>+</i>&nbsp;). click it to edit the tags on your item. this, too, won't be available on smaller screens.</p>
          """
        }, {
          id : 'help-mobile'
          title : 'simplenote on a mobile phone'
          notes : """
            <h2> simplenote on a mobile phone </h2>
            <p>so you are using simplenote on a mobile screen. nifty!</p>
            <p>use the bullets (&nbsp;&bull;&nbsp;) and breadcrumbs to navigate through your notebook.</p>
            <p>on the right side of each item you will see a checkbox (&nbsp;<i class='icon-check-empty'></i>&nbsp;). use it to select (&nbsp;<i class='icon-check'></i>&nbsp;) one or multpile items to perform operations on them.</p>
          """
        }, {
          id : 'help-search'
          title : 'simplenote search'
          notes : """
            <h2> find everything (&nbsp;in your notebook&nbsp;) </h2>
            <p>narrow your current view down by using the search bar. you can also search for items with certain tags if you prepend a hash to the tag like (&nbsp;#work&nbsp;).</p>
            <p>when you hover over the search bar, notice how the magnifying glass changes to a cross? use the cross to clear your search and get back to the mess that your notebook is</p>
          """
        }, {
          id : 'help-tags'
          title : 'simplenote tags'
          notes : """
            <h2> even more structure </h2>
            <p><b>Desktop</b><br>
            when you hover above a note, you will see a tag icon appearing on the right hand side (&nbsp;<i class='icon-tag'></i>&nbsp;). use this to add or remove tags to your notes. click on a tag which is already assigned to the note you are working on to toggle it off.</p>
            <p><b>Mobile &amp; Desktop</b></br>
            after selecting one ore more tags, use the appearing menu to toggle the tags on all selected items.</p>
            <p>you can also edit the tags for the current top item with the tag icon located below the breadcrumbs.</p>
            <p>you can search for items with certain tags by prepending a hash like (&nbsp;#work&nbsp;). or you can use the dropdown menu which will appear when you click on the tag icon in the search bar</p>
            <p>in the same dropdown, you will notice a pencil (&nbsp;<i class='icon-pencil'></i>&nbsp;) and a trashcan (&nbsp;<i class='icon-trash'></i>&nbsp;). need a hint what to do with 'em? okay: the pencil renames and repaints the tag and the trashcan trashes it. pretty straightforward, isn't it?</p>
            <p>when picking the color for your tags you can either choose a hex color like (&nbsp;#FF00FF&nbsp;) or a CSS-friendly color name like (&nbsp;CornflowerBlue&nbsp;). for a complete list and some inspiration, check <a href='http://www.w3schools.com/cssref/css_colornames.asp'>W3schools Color Names</a>.</p>
          """
        },{
          id : 'help-bookmarks'
          title : 'simplenote bookmarks'
          notes : """
            <h2> only the important stuff, at one glance </h2>
            <p>selecte one or multiple items and bookmark them with a click on the star icon (&nbsp;<i class='icon-star'></i>&nbsp;) on the appearing menu.</p>
            <p>or use the star icon below the breadcrumbs for the same task</p>
            <p>when you click on the star icon in the search bar, you will get a list of all your bookmarked items.</p>
            <p>in this dropdown, see the half-star on the right side (&nbsp;<i class='icon-star-half-full'></i>&nbsp;)? you can click it to remove a bookmark instantly</p>
          """
        }, {
          id : 'help-deadlines'
          title : 'simplenote deadlines'
          notes : """
            <h2> push yourself with deadlines </h2>
            <p>on the right side of every note you will see a clock icon appearing when you move your mouse over it. use this clock to set a deadline.</p>
            <p>you can also use the clock icon below the breadcrumbs to do the same.</p>
            <p>when setting a deadline, you can also use natual language. try setting an alarm for ( in a week ) for example. if the clock doesn't recognize what you are trying to say, <a href='mailto:#{email}'>give me a shout</a> and i will teach the clock new tongues.</p>
            <p>to delete a deadline, simply pass an empty string in the prompt</p>
          """
        }, {
          id : 'help-offline'
          title : 'simplenote offline'
          notes : """
            <h2> simplenote offline </h2>
            <p>you won't have to do anything special to work offline with simplenote. everything is saved in your browser as you type. go online. go offline. simplenote doesn't care.</p>
            <p>on the bottom of the screen you will see a small notification which will tell you if it is connected to the server or not. but have no fear, the server DOES NOT get any data from simplenote, only the other way around.</p>
          """
        }, {
          id : 'help-sync'
          title : 'simplenote sync'
          notes : """
            <h2> simplenote in sync </h2>
            <p>you want to use simplenote on all of your devices? simplenote will gladly help you.</p>
            <p>swing by the <a href='#options'>options</a> section and connect simplenote to your favorite online storage system.</p>
          """
        }
      ]
    },{
      id : 'options'
      title : 'options'
      notes : """
        <h2> simplenote options </h2>
        <p>not too much to see here yet, but feel free to play around.</p>
        <p>if you're missing an option, <a href='mailto:#{email}'>raise your voice</a>, and i'll be glad to help you out.</p>
      """
      children : [
        {
          id : 'options-appearance'
          title : 'appearance'
          notes : """
            <h2> appearance </h2>
            <p>work in progress</p>
          """
        },{
          id : 'options-dropbox'
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
      id : 'about'
      title : 'about simplenote'
      notes : """
        <h2> about simplenote </h2>
        <p>version : #{version} - #{date} </p>
        <p>author : <a href='mailto:#{email}'>#{author}</a></p>
        <p>github : <a href='#{github}'>#{github}</a></p>
        <p>if you have trouble using simplenote or have found a bug or have an idea you would love to see come to live in simplenote. write me a mail or drop by my github page.</p>
      """
    }
  ]

  addconstructor = (n)->
    n.__constructor = 'Node'
    n.readonly = on
    addconstructor c for c in n.children if n.children

  do ( $ = jQuery, view = 'body', model = SimpleNote.activeInstance ) ->
    addconstructor page for page in specialPages
    $ ->
      JSON.parse( JSON.stringify( specialPages ), revive )
 