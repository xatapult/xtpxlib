# xtpxlib container

Containers are constructs in which multiple documents are combined in to a single, container, document. This is useful in, for instance, processing zip files with XML contents like MS Office files.

A container is a surrounding structure in a different namespace (`http://www.xtpxlib.nl/ns/container`). There is a schema for this container XML in `xsd/container.xsd`. 

The container system is designed in such a way that it can directly deal with directories *and* zip file, both in reading and writing. 

Files that are not XML are not copied into the container but passed as a *reference* (in a `<external-document>` element). When going from a container back to disk or zip, this reference must of course still exist. 