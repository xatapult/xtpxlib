# xtpxlib common

The `common` part of the xtpxplib library contains all sorts of common stuff, like XSLT libraries, XProc pipelines, etc. These have been proofed useful over time in various projects.

It's most important parts are:

## XSLT Libraries

Subdirectory: `xslmod`


| Library | Description |
|--|--|
| `common.mod.xsl` | Very generic XSLT functions and named templates for, for instance, converting stuff, presenting stuff, etc. |
| `compare.mod.xsl` | Module for comparing XML documents/elements | 
| `date-time.mod.xsl` | Various functions related to the handling and conversion of dates and times. For instance computing week and day numbers, getting month names, etc. | 
| `dref.mod.xsl` | XSLT functions for working with "document references", which is the xtpxlib term for things like filenames, directory names, etc. Get names and extensions, canonicalize a path, find relative paths, etc.|
| `format-output.mod.xsl` | Various functions for converting numbers for output (setting digits, amounts, kb/gb/mb, etc.) |
| `message.mod.xsl` | xtpxlib defines a standard message construct for leaving messages in XML documents. This small library supports this. |
| `mimetypes.mod.xsl` | Library functions for working with MIME types and converting them in/from file extensions. |
| `parameters.mod.xml` | Library for working with a xtpxlib defined format of a parameter file. It has the capability to filter parameter values based on attributes.  |
| `uri.mod.xsl` | Functions for working with URIs (web addresses)  |
| `uuid.mod.xsl` | Library that can generate UUIDs. Its separated because it needs Saxon PE or EE and does not work with the free HE edition. |

## XProc libraries

Subdirectory: `xplmod`

| Library | Description |
|--|--|
| `common.mod/common.mod.xpl` | Common XProc steps for things like tee, writing logs, zipping directories, etc. |

## Binary files

Subdirectory: `bin`

The `bin` subdirectory contains some assorted binaries and scripts that have been proven useful in production pipelines.