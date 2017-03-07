# xtpxlib ms-office

This module contains code for processing of some Microsoft Office file formats (Office versions > 2003).  

The namespace for this module is `http://www.xtpxlib.nl/ns/ms-office` (with a recommended prefix of `xtlmso`)
## Excel

The XProc module contains `xplmod/excel.mod` contains pipelines for handling Excel files.


- `xtlmso:extract-xlsx` extracts the contents of an Excel (`.xlsx`) file into something more manageable. The output contains the values, formulas, comments and range names from the cells in the Excel file. A schema for the output of this pipeline can be found in `xsd/xlsx-extract.xsd`. 

