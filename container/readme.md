# xtpxlib container

Containers are constructs in which multiple documents are combined in to a single, container, document. This is useful in, for instance, processing zip files with XML contents like MS Office files.

A container is a surrounding structure in a different namespace (`http://www.xtpxlib.nl/ns/container`). There is a schema for this container XML in `xsd/container.xsd`. 

The container system is designed in such a way that it can directly deal with directories *and* zip files, both in reading and writing. 

Files that are not XML are not copied into the container but passed as a *reference* (in a `<external-document>` element). When going from a container back to disk or zip, this reference must of course still exist. 

## Implicit conversions

The container `<document>` element has a `@mime-type` attribute. You can use this to trigger some implicit conversions when writing a container to disk or zip:

| `@mime-type` | Result |
| ----------- | ------ |
| `text/plain` | The result will be that the root element of the document will be turned into a string and written as a *text* file. You can use this to, for instance, create a JSON file: just wrap the JSON in some root element and set `mime-type="text/plain"` on the surrounding container `<document>` element.  |
| `application/pdf` | When the document root element is `<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">` and `mime-type="application/pdf"` the result will be run through the FOP XSL-FO processor and, on no errors, will result in a PDF. You can pass a FOP initialization file in one of the step's options (if you don't, a default will be used). | 

