# xtpxlib: Xatapult XML Library

**V2.4.6 - November 14, 2018** 

Xatapult Content Engineering - http://www.xatapult.nl

Erik Siegel - erik@xatapult.nl - +31 6 53260792

----

xtpxlib is a library containing software, both libraries and ready-to-run stuff, for processing XML with languages like XSLT, XProc etc. 

----

## Using xtpxlib

* Dump the files on some appropriate location on disk. That's basicly it for installation.
* If you want/need you can add the catalog `xmlcatalog/xtpxlib-catalog.xml` to your system or IDE. Then you can reference the files with `urn:x-xtpxlib.nl://`, e.g. `urn:x-xtpxlib.nl://common/xslmod/common.mod.xsl`.
* Documentation is scattered around the library in Markdown `readme.md` files (like this one). I've also tried to document the code by adding enough comments.
* Code documentation is done in such a way that you can extract some nice HTML page (a bit like Javadoc) from it. See the `readme.md` file in the xmldoc subdirectory.
* There is a basic oXygen project file for working with the library in `devenv/oxygen/xtpxlib.xpr`

----

## Library contents

### Directories at root level

The root directories separate the library into subject areas. You will usually not need them all. The table below lists their dependencies. 

Most subdirectories contain a `readme.md` file that details its contents.

| Directory | Description | Dependencies |
| --------- | ----------- | ----------- |
| `common` | Sub-library with common code for processing strings, filenames, etc. | Always needed |
| `container` | Sub-library for working with document containers. | Depends on: `common` | 
| `devenv` | Development environment related files, like templates. xtpxlib can be used in any XML processing environment but specifically supports oXygen as its main IDE. | Only necessary when you use xtpxlib in development situations |
| `ms-office` | Sub-library for handling and working with some Microsoft Office formats (Office version > 2003) | Depends on: `common`, `container` |
| `xdocbook` | Sub-library with code for generating PDF from (a limited subset of) DocBook 5. Includes stuff for generating XML structure documentation.  | Depends on: `common` |
| `xmlcatalog` | Contains the XML catalog file(s) for easy access to the library  from code. | Only necessary when you use the XML catalog system
| `xmldoc` | Sub-library with code for generating documentation. A bit like Javadoc. | Depends on: `common` |
| `xwebgen` | Sub-library with code for generating a simple static website from templates. | Depends on: `common` and `container` |

## Main conventions used

### Commonly used (sub)directory names

| Directory | Description |
| --------- | ----------- |
| `assets` | Binary static assets (images, etc.)
| `bin` | Executable binaries and/or batch/shell files | 
| `data` | Static datafiles |
| `etc` | Anything that does not fit in one of the other categories. |
| `doc` | Documentation |
| `xpl` | XProc scripts |
| `xplmod` | XProc modules/libraries |
| `xqmod` | XQuery modules |
| `xsl` | XSLT scripts |
| `xslmod` | XSLT modules/libraries |

### File- and Directory-name Conventions

* All file- and directory-names are in lower-case.
* Words/parts in names are separated with hyphens (e.g. `this-is-a-name`).
* Normal extensions are used (e.g. `.xsl`, `.xml`, etc.)
* For a file that contains a module or library, the extension is prefixed with `.mod.` (e.g. `xslt-library.mod.xsl`)
* Keep the filename simple, the location in the library will usually contain enough information

### Common XML Conventions

* All names (elements, attributes, prefixes, etc.) are in lower-case.
* Words/parts in names are separated with hyphens (e.g. `this-is-a-name`).
* Wherever possible (and appropriate), namespaces are used:
    * xtpxlib namespace prefixes start with `xtl`, short for xtpxlib. (e.g. `xtlc` for `http:\\www.xtpxlib.nl\ns\common`)
    * A sub-library of xtpxlib uses a single namespace for everything (unless technical reasons dictate otherwise).
* Often a local namespace is needed for stuff like local functions, templates, etc. The prefix `local` is used and the namespace is called `#local.some-unique-id`, e.g. `xmlns:local="#local.ab-cd-ef"` or `xmlns:local="#local.filename"`. Templates use the oXygen `${id}` editor variable for this.

