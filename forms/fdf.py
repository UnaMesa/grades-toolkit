#!/usr/bin/env python
"""
Port of the PHP forge_fdf library by Sid Steward
(http://www.pdfhacks.com/forge_fdf/)

Anders Pearson <anders@columbia.edu> at Columbia Center For New Media Teaching
and Learning <http://ccnmtl.columbia.edu/>

HandleJson added by Martin Boliek for the GRADES project.
"""

__author__ = "Anders Pearson <anders@columbia.edu>"
__credits__ = ("Sebastien Fievet <zyegfryed@gmail.com>,"
               "Brandon Rhodes <brandon@rhodesmill.org>")

import codecs
import os, sys, json

# ------------------------------------------------------------------------------
def smart_encode_str(s):
    """Create a UTF-16 encoded PDF string literal for `s`."""
    utf16 = s.encode('utf_16_be')
    safe = utf16.replace('\x00)', '\x00\\)').replace('\x00(', '\x00\\(')
    return ('%s%s' % (codecs.BOM_UTF16_BE, safe))


# ------------------------------------------------------------------------------
def handle_hidden(key, fields_hidden):
    if key in fields_hidden:
        return "/SetF 2"
    else:
        return "/ClrF 2"


# ------------------------------------------------------------------------------
def handle_readonly(key, fields_readonly):
    if key in fields_readonly:
        return "/SetFf 1"
    else:
        return "/ClrFf 1"


# ------------------------------------------------------------------------------
def handle_data_strings(fdf_data_strings, fields_hidden, fields_readonly):
    for (key, value) in fdf_data_strings:
        if type(value) is bool:
            if value:
                yield "<<\n/V/Yes\n/T (%s)\n%s\n%s\n>>\n" % (
                    smart_encode_str(key),
                    handle_hidden(key, fields_hidden),
                    handle_readonly(key, fields_readonly),
                )
            else:
                yield "<<\n/V/Off\n/T (%s)\n%s\n%s\n>>\n" % (
                    smart_encode_str(key),
                    handle_hidden(key, fields_hidden),
                    handle_readonly(key, fields_readonly),
                )
        else:
            yield "<<\n/V (%s)\n/T (%s)\n%s\n%s\n>>\n" % (
                smart_encode_str(value),
                smart_encode_str(key),
                handle_hidden(key, fields_hidden),
                handle_readonly(key, fields_readonly),
            )


# ------------------------------------------------------------------------------
def handle_data_names(fdf_data_names, fields_hidden, fields_readonly):
    for (key, value) in fdf_data_names:
        yield "<<\n/V /%s\n/T (%s)\n%s\n%s\n>>\n" % (
            smart_encode_str(value),
            smart_encode_str(key),
            handle_hidden(key, fields_hidden),
            handle_readonly(key, fields_readonly),
        )


# ------------------------------------------------------------------------------
def forge_fdf( pdf_form_url="", fdf_data_strings=[], fdf_data_names=[],
              fields_hidden=[], fields_readonly=[] ):
    """Generates fdf string from fields specified

    pdf_form_url is just the url for the form fdf_data_strings and
    fdf_data_names are arrays of (key,value) tuples for the form fields. FDF
    just requires that string type fields be treated seperately from boolean
    checkboxes, radio buttons etc. so strings go into fdf_data_strings, and
    all the other fields go in fdf_data_names. fields_hidden is a list of
    field names that should be hidden fields_readonly is a list of field names
    that should be readonly

    The result is a string suitable for writing to a .fdf file.

    """
    fdf = ['%FDF-1.2\n%\xe2\xe3\xcf\xd3\r\n']
    fdf.append("1 0 obj\n<<\n/FDF\n")

    fdf.append("<<\n/Fields [\n")
    fdf.append(''.join(handle_data_strings(fdf_data_strings,
                                           fields_hidden, fields_readonly)))
    fdf.append(''.join(handle_data_names(fdf_data_names, fields_hidden,
                                         fields_readonly)))
    fdf.append("]\n")

    if pdf_form_url:
        fdf.append("/F (" + smart_encode_str(pdf_form_url) + ")\n")

    fdf.append(">>\n")
    fdf.append(">>\nendobj\n")
    fdf.append("trailer\n\n<<\n/Root 1 0 R\n>>\n")
    fdf.append('%%EOF\n\x0a')

    return ''.join(fdf)


# ------------------------------------------------------------------------------
def ReadJsonFieldFile( fileName ) :
	""" Reads a JSON file with key, value pairs for the fields in the pdf
		document. Altered by Martin Boliek
	"""
	
	# The data cannot easily be extracted from the PDF after it is flattened.
	# We should store the JSON file as the "truth" for the value. The PDF file
	# can be regernerated and the JSON file can preload the form for further
	# editing.
	
	# open and read the JSON file
	jsonData = open( fileName ).read()
	fieldData = json.loads( jsonData )

	# read JSON key, value pairs into
	fields = []
	for i in range ( 0, len( fieldData['fdf_fields']['field'] )) :
		tmpKey = fieldData['fdf_fields']['field'][i]['key']
		tmpValue = fieldData['fdf_fields']['field'][i]['value']
		fields.append( (tmpKey, tmpValue) )
	#print 'fields', fields
	
	# call the fdf creation 
	fdf = forge_fdf( fdf_data_strings = fields )
	
	# create the fdf file
	templateName = fieldData['fdf_fields']['formType'] + '.pdf'
	fdfName = fieldData['fdf_fields']['caseID'] + fieldData['fdf_fields']['formType'] + '.fdf'
	pdfName = fieldData['fdf_fields']['caseID'] + fieldData['fdf_fields']['formType'] + '.pdf'
	#print fdfName, pdfName, templateName
	
	# save file		  
	fdf_file = open( fdfName, "w" )
	fdf_file.write( fdf )
	fdf_file.close()
	
	# Use pdftk to merge and flattent the FDF and PDF files
	returnValue = os.system( "pdftk %s fill_form %s output %s flatten" %
							 ( templateName, fdfName, pdfName )
						   )
		

# ------------------------------------------------------------------------------
# Main altered by Martin Boliek for the GRADES project

if __name__ == "__main__":

	# Get the file from the command line
	if len( sys.argv ) == 2 :
		fields = ReadJsonFieldFile( sys.argv[1] )
	else :
		fields = ReadJsonFieldFile( 'example.json' )

					   
