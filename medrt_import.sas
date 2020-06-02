/************************************************************
 *					IMPORT MED-RT FILES						*
 *			   By: Steven Smith, Univ. of FL				*
 *				  Last update: 06/02/2020					*
 *															*											*
 * This script creates SAS datasets from MED-RT XML files,	*
 * in conjunction with the associated XML map file.			*
 ***********************************************************/

/* NOTES:

	MED-RT is produced by the U.S. Department of Veterans Affairs and is an evolution of the NDF-RT. 
	Source files are available at: https://evs.nci.nih.gov/ftp1/MED-RT/medrt_about.html.

	DEPENDENCIES:
	1. The source XML file (from website above) is REQUIRED for this program. 
	2. The associated XML mapping file (med_rt-xmlmap.map) is REQUIRED for this program.

	OPTIONAL:
	1. SQUEEZE macro
	

	The program produces 6 datasets:
		1. TERM:  MED-RT Terms
		2. CONCEPT:  MED-RT Concepts
		3. CONCEPT_PROPERTY:  Concept properties (many-to-one relationship to CONCEPT table on variable=CODE)
		4. CONCEPT_SYNONYM:  Concept synonyms (many-to-one relationship to CONCEPT table on variable=CODE)
		5. ASSOCIATION:  MED-RT Associations (Asserted Relationships between concepts)
		6. ASSOCIATION_QUALIFIER:  Association qualifiers (many-to-one relationship to ASSOCIATION table on 
			combination of variables TO_CODE and FROM_CODE)
*/

/* USER-DEFINED PATHS */
/* MEDRT source file (XML) */
%let source = E:\DATA\MED-RT\source_files\Core_MEDRT_XML\Core_MEDRT_2020.05.04_XML.xml ;

/* MEDRT map file (.map) */
%let mapfile = E:\DATA\MED-RT\XML_MAP\med-rt_xmlmap.map ;

/* permanent library name and destination */
%let mlib_name = MEDRT;
%let mlib_path = E:\DATA\MED-RT\SAS_Datasets ;
/* END USER-DEFINED PATHS */

/* Run SQUEEZE macro to minimize dataset size? (Y/N) */
%let squeeze=Y;

/* If SQUEEZE=Y, then specify location of macro: */
%let squeeze_loc = E:\SASWORK\MACROS\squeeze2.sas ;

/** END USER INPUT **/



/* SHOULD NOT NEED EDITS BELOW THIS LINE */

filename medrts "&source";
filename map "&mapfile";
libname medrts xml xmlmap=map;
libname &mlib_name "&mlib_path";

proc datasets library=medrts; run;

/* Transfer to permanent library */
%macro store_medrt(sqz=&squeeze);
	%if &SQZ = Y %then %do;
		%include "&squeeze_loc";
		%squeeze(dsnin=MEDRTS.association, dsnout=&mlib_name..ASSOCIATION);
		%squeeze(dsnin=MEDRTS.association_qualifier, dsnout=&mlib_name..association_qualifier);
		%squeeze(dsnin=MEDRTS.concept, dsnout=&mlib_name..concept);
		%squeeze(dsnin=MEDRTS.concept_property, dsnout=&mlib_name..concept_property);
		%squeeze(dsnin=MEDRTS.concept_synonym, dsnout=&mlib_name..concept_synonym);
		%squeeze(dsnin=MEDRTS.term, dsnout=&mlib_name..term);
	%end;

	%else %do;
		proc datasets library=medrts;
			copy out=&mlib_name in=medrts;
		run;
		quit;
	%end;
%mend store_medrt;

%store_medrt;
/** END PROGRAM **/
