;; extends

;; Triple-quoted strings (multiline) with SQL keywords
(string
  (string_start) @_start
  (string_content) @injection.content
  (#match? @injection.content "(SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP|WITH|FROM|WHERE|JOIN|UNION|GROUP BY|ORDER BY|HAVING)")
  (#set! injection.language "sql"))

;; f-strings with SQL
(string
  (string_start) @_start
  (interpolation)?
  (string_content) @injection.content
  (#match? @injection.content "(SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP|WITH|FROM|WHERE|JOIN)")
  (#set! injection.language "sql"))
