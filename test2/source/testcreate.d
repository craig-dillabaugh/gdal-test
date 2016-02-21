/*
 * Current build command:
 *     dmd testread.d gdal.d -L-lgdal
 */

import std.conv;
import std.string;

import gdal;
import cpl_string;


void main( string[] args )
{
  import std.stdio;
  import std.string;
  import core.stdc.stdlib;
  
  string testdirs = "/home/craig2/code/git-repos/gdal-test/datasets";
  string[] testfiles = ["july_22_2007.tif","oct_13_2004_ikonos.tif"];
  
  GDALAllRegister();
  
  
  //Which drivers support creation?
  string[] formats;
  
  formats ~= "ACE2";
  formats ~= "ENVI";
  formats ~= "GTiff";
  formats ~= "PCIDSK";
  formats ~= "R";
  
  foreach( string f; formats )
  {
    GDALDriverH driver = GDALGetDriverByName( toStringz(f) );
    
    if( driver == null ) {
      writeln("Driver not found for ", f, " format.");
      continue;
    }
    else {
      writeln("Driver found for ", f, " format." );
    }
    
    char** papszMetadata;
    papszMetadata = GDALGetMetadata( driver, null );
    
    
  }
}