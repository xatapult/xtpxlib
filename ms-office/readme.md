# xtpxlib ms-office

This module contains code for processing of some Microsoft Office file formats (Office versions > 2003).  

The namespace for this module is `http://www.xtpxlib.nl/ns/ms-office` (with a recommended prefix of `xtlmso`)


## Excel

The XProc module `xplmod/excel.mod` contains pipelines for handling Excel (`.xlsx`) files.


- **`xtlmso:extract-xlsx`** extracts the contents of an Excel (`.xlsx`) file into something more manageable. The output contains the values, formulas, comments and range names from the cells in the Excel file. A schema for the output of this pipeline can be found in `xsd/xlsx-extract.xsd`. 


## Word

The XProc module `xplmod/word.mod` contains pipelines for handling Word (`.docx`) files.

- **`xtlmso:extract-docx`** extracts the contents of a Word (`.docx`) file into something more manageable and understandable. *Watch out*: This is a pretty rough and not (yet) refined conversion. Several things (like for instance lists) will not be handled elegantly! There is no schema (yet) for this format.
- **`xtlmso:create-docx`** creates a `.docx` file. This is done by merging a template `.docx` file with XML in the same format as created by `xtlmso:extract-docx`.