# xtpxlib xwebgen

xwebgen is a relatively simple system for generating a static website from templates. It was created for my own website (http://www.xatapult.nl) but I've tried to keep it generic.

You can find an example of input for xwebgen in the `test/` directory. This contains the source for my website (at the time I developed xwebgen, not updated).

## Basics

### Filtering

When you start xwebgen, you can pass it a so-called "filterstring". This is a string with (name, value) pairs, seperated by by vertical bars (|). 

For instance . This defines two (name, value) pairs: `lang=en` and `system=PRD`. 

Now *every* source file used by xwebgen is, as a first step, always filtered based on the filterstring. The system looks for attributes in the `xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen"` namespace. When the name of such an attribute is the same as one of the filterstring names, the value of the attribute *must* be the same as the value given in the filterstring, otherwise the element (and istchildren) are not passed.

For instance: Based on the filterstring `lang|en|system|TST` the following will happen:

| Element | Pass? |
| --- | --- |
| `<section id="home" xtlwg:lang="nl">` | No |
| `<section id="home" xtlwg:lang="en">` | Yes |
| `<section id="home" xtlwg:lang="en" xtlwg:system="PRD">` | No (all `@xtlwg:*` values with names in the filterstring must match) |
| `<section id="home" xtlwg:lang="en" xtlwg:foo="BAR">` | Yes (`foo` is not a name in the filterstring, so it isn't taken into account) |

### Property substitution

You can set properties on about any level in xwebgen, global but also for specific pages (see below). The values for these properties can be inserted in the end result.

xwebgen looks for `${...}` constructions in any text node and any attribute value. When it finds one it looks for a corresponding property and, when it exists, it substitutes its value. Values themselves can also have `${...}` constructions inside which will be resolved. However, xwebgen does not check for circular definitions so if you make one the system will crash on a stack overflow.

The values on the filterstring will automatically be turned into properties for substition. This means that you can for instance dynamically determine the output directory by specifying something like `dref-base-output-dir="../../websites-generated/site-${lang}-${system}"` (on the main specification's root element).

## Document formats

### Specification

xwebgen processing starts with a specification document. The format of this document is described in `xsd/xwebgen-specification.xsd`. An example can be found in `test/source/website-xatapult-specification.xml`. It defines:

- The output directory (in `/*/@dref-base-output-dir`)
- One or more (html) template files. These are files that are used as the basis for the page generation. Examples can be found in `test/source/templates/`
- One or more page specification. A page specification results in a generated html page, based on a template.
- Copy directory specifications for copying stuff like css and javascript and images and so on
- Global properties (you can define specific properties for every template and page specificationm if needed)

### Sections

The other format xwebgen uses is called sections. A sections document contains one or more `<section>` elements with contents. The contents of these sections can be used in generating pages of inserting fixed stuff like menus.

The format is described in `xsd/xwebgen-sections.xsd`. Examples can be found in the directory `test/source/data/`.

As for all xwebgen documents, *before* anything happens to/with a section document, it is always filtered and properties are substituted.

A section can hold an optional reference to an XSLT stylesheet in the `dref-transformer` attribute. When this is present , the contents of the section is always transformed using this stylesheet before usage/insertion.


## Processing

xwebgen performs the following processing:

1. Read the specification file (and filter it and substitute properties)
2. For all `<page>` elements:
  1. Find the referenced template entry (by identifier)
  1. Read and filter it, substitute properties
  1. Substitute `<xtlwg:section-expand>` elements with the section mentioned 
  1. Substitute the `<xtlwg:page-contents-expand>` element with the section mentioned in the specification's `<page>` element
1. Optionally copy the directories mentioned in the specification (`<copy-dir>` elements)





