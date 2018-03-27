xquery version "3.1" encoding "UTF-8";
(:~
  
:)
(:============================================================================:)
(:== SETUP: ==:)

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare option exist:serialize "method=xhtml media-type=text/html indent=no";

(:============================================================================:)
(:== GLOBAL VARIABLES: ==:)

declare variable $page-title as xs:string := "/TBD: Page title/";

(:============================================================================:)
(:== FUNCTIONS: ==:)


(:============================================================================:)
(:== MAIN: ==:)

<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta HTTP-EQUIV="Content-Type" content="text/xhtml; charset=UTF-8"/>
    <title>{ $page-title }</title>
  </head>
  <body>
    <h1>{ $page-title }</h1>
    <p>/TBD/</p>
  </body>
</html>

(:============================================================================:)
