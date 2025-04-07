; extends
(
  (call
    function: (identifier) @func_name (#eq? @func_name "Template")
    arguments: (argument_list (string (string_content) @injection.content) )
  )
  @template_call
)

(
  (call
    function: (identifier) @func_name (#eq? @func_name "HTMLResponse")
    arguments: (argument_list (string (string_content) @injection.content) )
  )
  @template_call
)

(
  (call
    function: (identifier) @func_name (#eq? @func_name "FragmentResponse")
    arguments: (argument_list (string (string_content) @injection.content) )
  )
  @template_call
)

((string_content) @injection.content (#set! injection.language "html"))
