# xtpxlib xdocbook

The `xdocbook` part of the xtpxplib library contains code to work with and convert Docbook 5 (partial) into PDF. This was written to describe and document XML structures.

## XProc libraries

Subdirectory: `xplmod`

| Library | Description |
|--|--|
| `db5-pdf.mod/db5-pdf.mod.xpl` | Turns a limited subset of Docbook 5 into PDF using XSL-FO/FOP. The Docbook 5 dialect used van be found in `test/db5-dialect-description/db5-dialect-description.xml`. If you want to turn this into a PDF, use the module test script `xplmod/db5-pdf.mod/test/test-db5-pdf.xpl`. |
| `descriptions-db5.mod/descriptions-db5.mod.xpl` | Turns descriptions of XML constructs, that you can mingle with your Docbook 5 contents, into full descriptions. Examples in `test/element-description/` | 