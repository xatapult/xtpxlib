# xtpxlib devenv

The `devenv` part of xtpxlib contains specific support for development environments you can use the library in.

## oXygen

At this moment we have support only for oXygen, in the `oxygen` subdirectory.

Most important parts:

* A standard oXygen project for editing nd working with the library in `xtpxlib.xpr`
* A master file that chains all XSLT libraries together in `oxygen-project-master.xsl`. Use this as a master file in your oXygen project.
* Some templates for creating files in `xtpxlib-templates`. Add this directory at the document templates section of oXygen's preferences. 
