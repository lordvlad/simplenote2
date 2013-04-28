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
    model.applyKeyBindings()
    # start periodical saving
    model.startPeriodicalSave()