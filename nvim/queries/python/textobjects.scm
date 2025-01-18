; extends

; Select decorated functions first
(
  (decorated_definition
    (decorator)+ ; Ensure there is at least one decorator
    definition: (function_definition))
  @function_with_decorator
)

; Fallback to undecorated functions
(
  (function_definition)
  @function_with_decorator
)
