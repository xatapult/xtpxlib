xquery version "3.1" encoding "UTF-8";
(:~
  Generic handling of document references.
  Module dependencies: None
:)

(:============================================================================:)
(:== SETUP: ==:)

module namespace xtldr="http://www.xtpxlib.nl/ns/common/dref";

declare namespace xpf="http://www.w3.org/2005/xpath-functions";

(:============================================================================:)
(:== GLOBAL VARIABLES: ==:)

(: Pre-defined protocol specifiers: :)
declare variable $xtldr:protocol-file as xs:string := 'file';
declare variable $xtldr:protocol-exist as xs:string := 'xmldb:exist';

(:============================================================================:)
(:== LOCAL VARIABLES: ==:)

declare %private variable $xtldr:protocol-match-regexp as xs:string := '^[a-z]+://';
declare %private variable $xtldr:protocol-file-special as xs:string := concat($xtldr:protocol-file, ':/');

(:============================================================================:)
(:== FUNCTIONS: ==:)

(:~
  Performs a safe concatenation of document reference path components:
  - Translates all backslashes into slashes
  - Makes sure that all components are separated with a single slash
  - If somewhere in the list is an absolute path, the concatenation stops.
  Examples:
  - xtldr:dref-concat(('a', 'b', 'c')) ==> a/b/c
  - xtldr:dref-concat(('a', '/b', 'c')) ==> /b/c
  
  @param $dref-path-components The path components that will be concatenated into a document reference.
:)
declare function xtldr:dref-concat(
  $dref-path-components as xs:string*
) as xs:string
{
  if (empty($dref-path-components)) then
    ''
  else
    let $current-dref-1 as xs:string := translate($dref-path-components[last()], '\', '/')
    let $current-dref as xs:string := replace($current-dref-1, '/+$', '')
    return
      if (xtldr:dref-is-absolute($current-dref)) then
        $current-dref
      else
        let $prefix as xs:string := xtldr:dref-concat(remove($dref-path-components, count($dref-path-components)))
        return
          concat($prefix, if ($prefix eq '') then () else '/', $current-dref)
};

(:----------------------------------------------------------------------------:)

(:~
  Performs a safe concatenation of document reference path components:
  - Translates all backslashes into slashes
  - Makes sure that all components are separated with a single slash
  - This version does not stop at an absolute path. Leading slashes are removed on all but the first component
  Examples:
  - xtldr:dref-concat-noabs(('a', 'b', 'c')) ==> a/b/c
  - xtldr:dref-concat-noabs(('a', '/b', 'c')) ==> a/b/c
  - xtldr:dref-concat-nabs(('/a', '/b', 'c')) ==> /a/b/c
  
  @param $dref-path-components The path components that will be concatenated into a document reference.
:)
declare function xtldr:dref-concat-noabs(
  $dref-path-components as xs:string*
) as xs:string
{
  if (empty($dref-path-components)) then
    ''
  else
    let $is-first-component as xs:boolean := count($dref-path-components) eq 1
    let $current-dref-1 as xs:string := translate($dref-path-components[last()], '\', '/')
    let $current-dref-2 as xs:string := if ($is-first-component) then $current-dref-1 else replace($current-dref-1, '^/+', '')
    let $current-dref as xs:string := replace($current-dref-2, '/+$', '')
    let $prefix as xs:string := xtldr:dref-concat-noabs(remove($dref-path-components, count($dref-path-components)))
    return
      concat($prefix, if ($prefix eq '') then () else '/', $current-dref)
};

(:----------------------------------------------------------------------------:)

(:~
  Returns true if the document reference can be considered absolute.
  A path is considered absolute when it starts with a / or \, contains a protocol specifier (e.g. file://) or
  starts with a Windows drive letter.
  
  @param $dref Document reference to work on.
:)
declare function xtldr:dref-is-absolute(
  $dref as xs:string
) as xs:boolean
{
  starts-with($dref, '/') or starts-with($dref, '\') or contains($dref, ':/') or matches($dref, '^[a-zA-Z]:')
};

(:----------------------------------------------------------------------------:)

(:~
  Returns the (file)name part of a complete document reference path.
  Examples:
  - xtldr:dref-name('a/b/c') ==> c
  - xtldr:dref-name('c') ==> c
  
  @param $dref Document reference to work on.
:)
declare function xtldr:dref-name(
  $dref as xs:string
) as xs:string
{
  replace($dref, '.*[/\\]([^/\\]+)$', '$1')
};

(:----------------------------------------------------------------------------:)

(:~
  Returns the complete document reference path but without its extension.
  Examples:
  - xtldr:dref-noext('a/b/c.xml') ==> a/b/c
  - xtldr:dref-noext('a/b/c') ==> a/b/c
  
  @param $dref Document reference to work on.
:)
declare function xtldr:dref-noext(
  $dref as xs:string
) as xs:string
{
  replace($dref, '\.[^\.]+$', '')
};

(:----------------------------------------------------------------------------:)

(:~
  Returns the (file)name part of a document reference path but without its extension.
  Examples:
  - xtldr:dref-name-noext('a/b/c.xml') ==> c
  - xtldr:dref-name-noext('a/b/c') ==> c
  
  @param $dref Document reference to work on.
:)
declare function xtldr:dref-name-noext(
  $dref as xs:string
) as xs:string
{
  xtldr:dref-noext(xtldr:dref-name($dref))
};

(:----------------------------------------------------------------------------:)

(:~
  Returns the extension part of a document reference path.
  Examples:
  - xtldr:dref-ext('a/b/c.xml') ==> xml
  - xtldr:dref-ext('a/b/c') ==> ''
  
  @param $dref Document reference to work on.
:)
declare function xtldr:dref-ext(
  $dref as xs:string
) as xs:string
{
  let $name-only as xs:string := xtldr:dref-name($dref)
  return
    if (contains($name-only, '.')) then
      replace($name-only, '.*\.([^\.]+)$', '$1')
    else
      ''
};

(:----------------------------------------------------------------------------:)

(:~
  Returns the path part of a document reference path.
  Examples:
  - xtldr:dref-path('a/b/c') ==> a/b
  - xtldr:dref-path('c') ==> ''
  
  @param $dref Document reference to work on.
:)
declare function xtldr:dref-path(
  $dref as xs:string
) as xs:string
{
  if (matches($dref, '[/\\]')) then
    replace($dref, '(.*)[/\\][^/\\]+$', '$1')
  else
    ''
};

(:----------------------------------------------------------------------------:)

(:~
  Makes a document reference canonical (remove any .. and . directory specifiers).
  Examples:
  - dref-canonical('a/b/../c') ==> a/c
  
  @param $dref Document reference to work on.
:)
declare function xtldr:dref-canonical(
  $dref as xs:string
) as xs:string
{
  let $protocol as xs:string := xtldr:protocol($dref)
  let $dref-no-protocol as xs:string := xtldr:protocol-remove($dref)
  let $dref-components as xs:string* := tokenize($dref-no-protocol, '/')
  let $dref-canonical-filename as xs:string := string-join(xtldr:dref-canonical-process-components($dref-components, 0), '/')
  return
    xtldr:protocol-add($dref-canonical-filename, $protocol, false())
};

(:----------------------------------------------------------------------------:)

declare %private function xtldr:dref-canonical-process-components(
  $dref-components-unprocessed as xs:string*,
  $parent-directory-marker-count as xs:integer
) as xs:string*
(: Helper function for xtldr:dref-canonical() :)
{
  let $component-to-process as xs:string? := $dref-components-unprocessed[last()]
  let $remainder-components as xs:string* := subsequence($dref-components-unprocessed, 1, count($dref-components-unprocessed) - 1)
  return
     if (empty($component-to-process)) then 
       (:  No input, no output:  :)
       ()
     else if ($component-to-process eq '..') then
       (:  On a parent directory marker (..) we output the remainder and increase the $parent-directory-marker-count. 
           This will cause the next name-component of the remainders to be removed: :)
       xtldr:dref-canonical-process-components($remainder-components, $parent-directory-marker-count + 1)
     else if ($component-to-process eq '.') then
       (:  Ignore any current directory (.) markers:  :)
       xtldr:dref-canonical-process-components($remainder-components, $parent-directory-marker-count)
     else if ($parent-directory-marker-count gt 0) then
       (:  Check if $parent-directory-marker-count is >= 0. If so, do not take the current component into account:  :)
       xtldr:dref-canonical-process-components($remainder-components, $parent-directory-marker-count - 1)
     else 
       (:  Normal directory name and no $parent-directory-marker-count. This must be part of the output:  :)
       (xtldr:dref-canonical-process-components($remainder-components, 0), $component-to-process)
};

(:----------------------------------------------------------------------------:)

(:~
  Computes a relative document reference from one document to another.
  Examples:
  - dref-relative('a/b/c/from.xml', 'a/b/to.xml') ==> ../to.xml
  - dref-relative('a/b/c/from.xml', 'a/b/d/to.xml') ==> ../d/to.xml
  
  @param $from-dref Document reference (of a document) of the starting point.
  @param $to-dref Document reference (of a document) of the target.
:)
declare function xtldr:dref-relative(
  $from-dref as xs:string,
  $to-dref as xs:string
) as xs:string
{
    xtldr:dref-relative-from-path(xtldr:dref-path($from-dref), $to-dref)
};

(:----------------------------------------------------------------------------:)

(:~
  Computes a relative document reference from a path to a document.
  Examples:
  - dref-relative-from-path('a/b/c', 'a/b/to.xml') ==> ../to.xml
  - dref-relative-from-path('a/b/c', 'a/b/d/to.xml') ==> ../d/to.xml
  
  @param $from-dref-path Document reference (of a directory) of the starting point.
  @param $to-dref Document reference (of a document) of the target.
:)
declare function xtldr:dref-relative-from-path(
  $from-dref-path as xs:string,
  $to-dref as xs:string
) as xs:string
{
  let $from-dref-path-canonical as xs:string := xtldr:dref-canonical($from-dref-path)
  let $from-protocol as xs:string := xtldr:protocol($from-dref-path-canonical, $xtldr:protocol-file)
  let $from-no-protocol as xs:string := xtldr:protocol-remove($from-dref-path-canonical)
  let $from-components-no-filename as xs:string* := tokenize($from-no-protocol, '/')[. ne '']
  let $to-dref-canonical as xs:string := xtldr:dref-canonical($to-dref)
  let $to-protocol as xs:string := xtldr:protocol($to-dref-canonical, $xtldr:protocol-file)
  let $to-no-protocol as xs:string := xtldr:protocol-remove($to-dref-canonical)
  let $to-components as xs:string* := tokenize($to-no-protocol, '/')[. ne '']
  let $to-components-no-filename as xs:string* := subsequence($to-components, 1, count($to-components) - 1)
  let $to-filename as xs:string := $to-components[last()]
  return
    if (empty($to-components-no-filename) or (lower-case($from-protocol) ne lower-case($to-protocol))) then 
      (:  Unequal protocols or no from-dref/to-dref means there is no relative path...  :)
      $to-dref-canonical
    else
      xtldr:dref-concat((xtldr:relative-dref-components-compare($from-components-no-filename, $to-components-no-filename), $to-filename))
};

(:----------------------------------------------------------------------------:)

declare %private function xtldr:relative-dref-components-compare(
  $from-components as xs:string*,
  $to-components as xs:string*
) as xs:string*
(: helper function for xtldr:dref-relative-from-path() :)
{
  if ($from-components[1] eq $to-components[1]) then 
    xtldr:relative-dref-components-compare(subsequence($from-components, 2), subsequence($to-components, 2))
  else
    (for $p in (1 to count($from-components)) return '..', $to-components)
};

(:----------------------------------------------------------------------------:)

(:~
  Returns true when a reference has a protocol specifier (e.g. file:// or http://).
  Handles the special case for file:/ (one slash!)
  
  @param $ref Reference to work on.
:)
declare function xtldr:protocol-present(
  $ref as xs:string
) as xs:boolean
{
  starts-with($ref, $xtldr:protocol-file-special) or matches($ref, $xtldr:protocol-match-regexp)
};

(:----------------------------------------------------------------------------:)

(:~
  Removes the protocol part from a document reference.
  Examples:
  - xtldr:protocol-remove('file:///a/b/c') ==> /a/b/c
  
  @param $ref Reference to work on.
:)
declare function xtldr:protocol-remove(
  $ref as xs:string
) as xs:string
{
  let $ref-0 as xs:string := translate($ref, '\', '/')
  let $ref-1 as xs:string :=
    if (matches($ref-0, $xtldr:protocol-match-regexp)) then 
      replace($ref, $xtldr:protocol-match-regexp, '')
    else if (starts-with($ref-0, $xtldr:protocol-file-special)) then
      substring-after($ref-0, $xtldr:protocol-file-special)
    else $ref-0
  return
    (: Check for a Windows absolute path with a slash in front. That must be removed :)
    if (matches($ref-1, '^/[a-zA-Z]:')) then substring($ref-1, 2) else $ref-1
};

(:----------------------------------------------------------------------------:)

(:~
  Adds a protocol part (written without the trailing ://) to a reference.
  
  @param $ref Reference to work on.
  @param $protocol The protocol to add, without a leading :// part (e.g. just 'file' or 'http').
  @param $force When true an existing protocol is removed first. When false, a reference with an existing protocol is left unchanged.
:)
declare function xtldr:protocol-add(
  $ref as xs:string,
  $protocol as xs:string,
  $force as xs:boolean
) as xs:string
{
  let $ref-1 as xs:string := if ($force) then xtldr:protocol-remove($ref) else translate($ref, '\', '/')
  return
     if (not($force) and xtldr:protocol-present($ref-1)) then
       (:  When $force is false, do not add a protocol when one is present already:  :)
       $ref-1
     else if (($protocol eq $xtldr:protocol-file) and matches($ref-1, '^[a-zA-Z]:/')) then 
       (:  When this is a Windows file dref, make sure to add an extra / :  :)
       concat($protocol, ':///', $ref-1)
     else if ($protocol ne '') then 
       concat($protocol, ':///', $ref-1)
     else
       $ref-1
};

(:----------------------------------------------------------------------------:)

(:~
  Returns the protocol part of a reference (without the ://).
  
  @param $ref Reference to work on.
:)
declare function xtldr:protocol(
  $ref as xs:string
) as xs:string
{
  xtldr:protocol($ref, '')
};

(:----------------------------------------------------------------------------:)

(:~
  Returns the protocol part of a reference (without the ://) or a default value when none present.
  
  @param $ref Reference to work on.
  @param $default-protocol Default protocol to return when $ref contains none.
:)
declare function xtldr:protocol(
  $ref as xs:string,
  $default-protocol as xs:string
) as xs:string
{
  if (xtldr:protocol-present($ref)) then 
    replace($ref, '(^[a-z]+):/.*$', '$1')
  else
    $default-protocol
};

(:----------------------------------------------------------------------------:)

(:~
  Turns a dref into a uri. It will replace all "strange" characters with %xx.
  Any existing %xx parts will be kept as is.
  
  @param $dref Document reference to work on.
:)
declare function xtldr:dref-to-uri(
  $dref as xs:string
) as xs:string
{
  let $protocol as xs:string := xtldr:protocol($dref)
  let $dref-no-protocol as xs:string := xtldr:protocol-remove($dref)
  let $dref-parts as xs:string* := tokenize($dref-no-protocol, '/')
  let $dref-parts-uri as xs:string* := 
    for $part at $index in $dref-parts
    return
      if (($index eq 1) and matches($part, '^[a-zA-Z]:$')) then 
        (: Windows drive letter, keep: :)
        $part
      else
        xtldr:dref-part-to-uri($part)
  return
    xtldr:protocol-add(string-join($dref-parts-uri, '/'), $protocol, false())
};

(:----------------------------------------------------------------------------:)

declare function xtldr:dref-part-to-uri(
  $dref-part as xs:string
) as xs:string
(: Helper function for xtldr:dref-to-uri() :)
{
  let $dref-part-parts as xs:string* := 
    for $part in analyze-string($dref-part, '%[0-9][0-9]')/(xpf:match | xpf:non-match)
    return
      if ($part/self::xpf:match) then
        string($part)
      else encode-for-uri(string($part))
  return
    string-join($dref-part-parts)
};

(:----------------------------------------------------------------------------:)

