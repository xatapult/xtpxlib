# xtpxlib xmldoc

xmldoc is a simple system for auto-generating documentation (in HTML format) from XML files like XSLT libraries, XProc pipelines and steps, etc. It's a bit like Javadoc but much more primitive.



## Adding xmldoc comments

xmldoc currently works with XSLT libraries, XProc steps and XML Schemas.

For files that do have a native way of adding documentation (like XSLT) you add your comments in an XML comment that starts with a `*` sign, like this:

`<!--* This an xmldoc comment... --> `

For formats that do have some documentation support, like XProc and XML schema, it relies on the native comments. 

You can find plenty of examples on how to add comments to things like functions, named templates, variables, elements, steps, etc. in the library. I've done my best to make all relevant component in this library behave well when run through xmldoc.

## creating documentation

To create documentation, run the file through the XProc `xpl/xmldoc.xpl` pipeline. This spits out the documentation in HTML.