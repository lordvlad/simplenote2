# jquery closure
do ( $ = jQuery, model = window.note = new SimpleNote "body" ) ->
  # jquery onload event
  $ ->
    # extend window with simplenote classes
    $.extend true, window, {
      SimpleNote  : SimpleNote
      Node    : Node
    }
    # apply knockout bindings
    ko.applyBindings model, model.element[0]
    # revive model
    model.revive()
    # apply key bindings
    model.applyKeyBindings()
    # start periodical saving
    model.startPeriodicalSave()