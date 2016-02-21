/*
 * Current build command:
 *     dmd testread.d gdal.d -L-lgdal
 */

import std.conv;
import std.string;

import gdal;


void main( string[] args )
{
  import std.stdio;
  import std.string;
  import core.stdc.stdlib;
  
  string testdirs = "/home/craig2/code/git-repos/gdal-test/datasets";
  string[] testfiles = ["july_22_2007.tif","oct_13_2004_ikonos.tif"];
  
  GDALAllRegister();
    
  writeln("gdal.d Test reading GeoTIFF files.");  
 
  foreach(string f; testfiles) {
      string dset = testdirs ~ "/" ~ f;
    
      GDALDatasetH ds = GDALOpen( std.string.toStringz(dset),  
			          GDALAccess.GA_ReadOnly );
			   
      int num_bands = GDALGetRasterCount( ds );
      int x_size = GDALGetRasterXSize( ds );
      int y_size = GDALGetRasterYSize( ds );
  
      writeln(dset, " has ", num_bands, " bands and is [", x_size, "x", y_size, "]");
      
      double[6] geoTransform;
      
      if( GDALGetGeoTransform( ds, geoTransform.ptr ) )
      {
	  writeln("Origin = (",geoTransform[0],", ",geoTransform[3] ,")");
	  writeln("Resolution = (",geoTransform[1],", ",geoTransform[5] ,")");
      }
      else {
	  writeln("Unable to read transform data.");
      }
      
      string projref = to!string( fromStringz( GDALGetProjectionRef( ds )));
      writeln("Projection reference: ", ( projref == null ? "Empty" : projref ) );
  
  
      /* Band index's start at 1. */
      GDALRasterBandH band = GDALGetRasterBand( ds, 1 );
  
      /* Getting Block Size */
      int x_block_size, y_block_size;
      GDALGetBlockSize( band, &x_block_size, &y_block_size );
  
      //Note, you add the x_block_size to the band size, and subtract 1
      //to ensure that you don't cut off a partially full block.
      int x_blocks = (x_size + x_block_size - 1)/x_block_size;
      int y_blocks = (y_size + y_block_size - 1)/y_block_size;
  
      write("Band 1 is of size ", GDALGetRasterBandXSize( band ), " by ");
      writeln( GDALGetRasterBandYSize( band ), ".");
      writeln("\twith block size = ", x_block_size, ", ", y_block_size, ".");
      writeln("\tand ", x_blocks, " blocks(X) by ", y_blocks, " blocks(Y).");
      
      GDALDataType dt = GDALGetRasterDataType( ds );
      
      writeln("The data type is: ", fromStringz( GDALGetDataTypeName( dt) ) );
      
      GDALColorInterp ci = GDALGetRasterColorInterpretation( ds );
      writeln("The colour interpretation name is ",
              to!string( fromStringz( GDALGetColorInterpretationName( ci) )) );
      
      //Get statistics
      int        bGotMin, bGotMax;
      double[2]  adfMinMax;
      
      writeln();
      
      adfMinMax[0] = GDALGetRasterMinimum( band, &bGotMin );
      adfMinMax[1] = GDALGetRasterMaximum( band, &bGotMax );
      
      if( !bGotMin || !bGotMax ) GDALComputeRasterMinMax( band, true, adfMinMax.ptr );
      
      writeln("Band values, min = ", adfMinMax[0], " max = ", adfMinMax[1] );
      writeln("Band has ", GDALGetOverviewCount( band ), " overviews.");
      if( GDALGetRasterColorTable( band ) != null ) {
	writeln("Band has colour table with ", 
	         GDALGetColorEntryCount( GDALGetRasterColorTable( band )),
	         " entries." );
      }
      
      //Get Driver Information
      GDALDriverH  hDriver = GDALGetDatasetDriver( ds );
      //But there is nothing we can do from here, since the 
      //GDALGetDriverShort/LongName functions were deprecated.
      

      auto buffer = new GByte[x_block_size * y_block_size];
  
      int num_zeros = 0;
  
      for( int yblock = 0 ; yblock < y_blocks; yblock++) {
	for( int xblock = 0; xblock < x_blocks; xblock++) {
    
	  GDALReadBlock( band, xblock, yblock, cast(void*)buffer.ptr );
      
	  int x_valid, y_valid;
      
	  //Compute partial blocks for edge blocks
	  if( xblock == x_blocks - 1 ) x_valid = x_size - (xblock*x_block_size);
	    else x_valid = x_block_size;
      
	    if( yblock == y_blocks - 1 ) y_valid = y_size - (yblock*y_block_size);
	    else y_valid = y_block_size;
      
	    //Now loop over the block pixels and calculate
	    for( int y = 0; y < y_valid; y++ ) {
	      for( int x = 0; x < x_valid; x++ ) {
		if(buffer[y*x_valid + x] == 0) num_zeros++;
	      }
	    }
    
	 }
      }
  
      writeln("There were ", num_zeros, " background values.");
      writeln();
      GDALClose( ds );  
    }
}