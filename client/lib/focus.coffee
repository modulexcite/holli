angular.module("app").factory "focus", [ '$timeout', ($timeout) ->
    self = 
      focus: (selector) ->
        # timeout makes sure that it is invoked after any other event has been triggered.
        # e.g. click events that need to run before the focus or
        # inputs elements that are in a disabled state but are enabled when those events
        # are triggered.
        $timeout () ->
          element = angular.element("#{selector}")
          if element 
            element.focus()
    self
]
