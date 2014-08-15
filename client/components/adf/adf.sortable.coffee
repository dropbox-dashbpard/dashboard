#
# jQuery UI Sortable plugin wrapper
# https://raw.github.com/CyborgMaster/ui-sortable/angular1.2/src/sortable.js
# @param [ui-sortable] {object} Options to pass to $.fn.sortable() merged onto ui.config
# 
angular.module("ui.sortable", []).value("uiSortableConfig", {}).directive "uiSortable", [
  "uiSortableConfig"
  "$timeout"
  "$log"
  (uiSortableConfig, $timeout, $log) ->
    return (
      require: "?ngModel"
      link: (scope, element, attrs, ngModel) ->
        combineCallbacks = (first, second) ->
          if second and (typeof second is "function")
            return (e, ui) ->
              first e, ui
              second e, ui
              return
          first
        savedNodes = undefined
        opts = {}
        callbacks =
          receive: null
          remove: null
          start: null
          stop: null
          update: null

        angular.extend opts, uiSortableConfig
        if ngModel
          
          # When we add or remove elements, we need the sortable to 'refresh'
          # so it can find the new/removed elements.
          scope.$watch attrs.ngModel + ".length", ->
            
            # Timeout to let ng-repeat modify the DOM
            $timeout ->
              element.sortable "refresh"
              return

            return

          callbacks.start = (e, ui) ->
            
            # Save the starting position of dragged item
            ui.item.sortable = index: ui.item.index()
            return

          callbacks.activate = (e, ui) ->
            
            # We need to make a copy of the current element's contents so
            # we can restore it after sortable has messed it up.
            # This is inside activate (instead of start) in order to save
            # both lists when dragging between connected lists.
            savedNodes = element.contents()
            
            # If this list has a placeholder (the connected lists won't),
            # don't inlcude it in saved nodes.
            placeholder = element.sortable("option", "placeholder")
            
            # placeholder.element will be a function if the placeholder, has
            # been created (placeholder will be an object).  If it hasn't
            # been created, either placeholder will be false if no
            # placeholder class was given or placeholder.element will be
            # undefined if a class was given (placeholder will be a string)
            savedNodes = savedNodes.not(element.find("." + placeholder.element().attr("class").split(/\s+/).join(".")))  if placeholder and placeholder.element
            return

          callbacks.update = (e, ui) ->
            
            # Save current drop position but only if this is not a second
            # update that happens when moving between lists because then
            # the value will be overwritten with the old value
            unless ui.item.sortable.received
              ui.item.sortable.dropindex = ui.item.index()
              
              # Cancel the sort (let ng-repeat do the sort for us)
              # Don't cancel if this is the received list because it has
              # already been canceled in the other list, and trying to cancel
              # here will mess up the DOM.
              element.sortable "cancel"
            
            # Put the nodes back exactly the way they started (this is very
            # important because ng-repeat uses comment elements to delineate
            # the start and stop of repeat sections and sortable doesn't
            # respect their order (even if we cancel, the order of the
            # comments are still messed up).
            savedNodes.detach().appendTo element
            
            # If received is true (an item was dropped in from another list)
            # then we add the new item to this list otherwise wait until the
            # stop event where we will know if it was a sort or item was
            # moved here from another list
            if ui.item.sortable.received
              scope.$apply ->
                ngModel.$modelValue.splice ui.item.sortable.dropindex, 0, ui.item.sortable.moved
                return

            return

          callbacks.stop = (e, ui) ->
            
            # If the received flag hasn't be set on the item, this is a
            # normal sort, if dropindex is set, the item was moved, so move
            # the items in the list.
            if not ui.item.sortable.received and ("dropindex" of ui.item.sortable)
              scope.$apply ->
                ngModel.$modelValue.splice ui.item.sortable.dropindex, 0, ngModel.$modelValue.splice(ui.item.sortable.index, 1)[0]
                return

            return

          callbacks.receive = (e, ui) ->
            
            # An item was dropped here from another list, set a flag on the
            # item.
            ui.item.sortable.received = true
            return

          callbacks.remove = (e, ui) ->
            
            # Remove the item from this list's model and copy data into item,
            # so the next list can retrive it
            scope.$apply ->
              ui.item.sortable.moved = ngModel.$modelValue.splice(ui.item.sortable.index, 1)[0]
              return

            return

          scope.$watch attrs.uiSortable, ((newVal, oldVal) ->
            angular.forEach newVal, (value, key) ->
              
              # wrap the callback
              value = combineCallbacks(callbacks[key], value)  if callbacks[key]
              element.sortable "option", key, value
              return

            return
          ), true
          angular.forEach callbacks, (value, key) ->
            opts[key] = combineCallbacks(value, opts[key])
            return

        else
          $log.info "ui.sortable: ngModel not provided!", element
        
        # Create sortable
        element.sortable opts
        return
    )
]
