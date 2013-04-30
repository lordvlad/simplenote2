# jquery closure
do ( $ = jQuery, view = "body", model = window.note = new SimpleNote ) ->
  # jquery onload event
  $ ->
    # extend window with simplenote classes
    $.extend true, window, {
      SimpleNote  : SimpleNote
      Node    : Node
    }
    # attach view to model
    model.attachElements view
    # apply knockout bindings
    ko.applyBindings model, model.view
    # revive model
    model.revive()
    # apply key bindings
    model.applyEvents()
    # start periodical saving
    model.startPeriodicalSave()
    
    # create right click context menu-1
    $( view ).contextMenu 'text-context-menu', {
      ###
      '<i class="icon-edit"></i>&nbsp;open node' : {
        click : model.openNode
      },
      '<hr />' : {
      },
      ###
      '<i class="icon-bold"></i>&nbsp;bold' : {
        click :-> document.execCommand 'bold', false
      },
      '<i class="icon-italic"></i>&nbsp;italics' : {
        click :-> document.execCommand 'italic', false
      },
      '<i class="icon-underline"></i>&nbsp;underline' : {
        click :-> document.execCommand 'underline', false
      },
      '<i class="icon-strikethrough"></i>&nbsp;strike-through' : {
        click :-> document.execCommand 'strikeThrough', false
      },
      '<i class="icon-font"></i>&nbsp;drop formatting' : {
        click :-> document.execCommand 'removeFormat', false
      },
      '<i class="icon-link"></i>&nbsp;create link' : {
        click :-> document.execCommand 'createLink', false, prompt 'insert url href', ''
      },
      
      
      
    },{
      delegateEventTo: '.title, .notes'
    }
