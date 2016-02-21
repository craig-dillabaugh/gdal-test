/*
 * Current build command:
 *     dmd testread.d gdal.d -L-lgdal
 */

import std.conv;
import std.string;

import gdal;
import ogr_api;


void main( string[] args )
{
  import std.stdio;
  import std.string;
  import core.stdc.stdlib;
  
  GDALAllRegister();
  
  GDALDatasetH dataset;
  
  dataset = GDALOpenEx( "delaware-latest.shp/buildings.shp", GDAL_OF_VECTOR, null, null, null);
  
  int num_layers = 0;
  
  if( dataset == null )
  {
    writeln("Open failed.");
    return;
  }
  else {
    num_layers = GDALDatasetGetLayerCount(dataset);
    writeln("Open succeeded. Layer includes ", num_layers, " layer." );
  }
  
  if( num_layers == 0 ) return;
  
  OGRLayerH layer;
  
  layer = GDALDatasetGetLayer( dataset, 0 );
  writeln("Layer name is: ", fromStringz( OGR_L_GetName( layer )) );
  
  OGRFeatureH feature;
  
  OGR_L_ResetReading(layer);
  
  while( (feature = OGR_L_GetNextFeature(layer)) != null )
  {
  
  }
  
  OGRFeatureDefnH definition = OGR_L_GetLayerDefn(layer);
  
  for(int field_id = 0; field_id < OGR_FD_GetFieldCount(definition); ++field_id )
  {
    OGRFieldDefnH field_def = OGR_FD_GetFieldDefn( definition, field_id );
    
    
    if( OGR_Fld_GetType(field_def) == OGRFieldType.OFTInteger )
        writefln( "%d,", OGR_F_GetFieldAsInteger( feature, field_id ) );
    else if( OGR_Fld_GetType(field_def) == OGRFieldType.OFTInteger64 )
        writefln( "%d,", OGR_F_GetFieldAsInteger64( feature, field_id ) );
    else if( OGR_Fld_GetType(field_def) == OGRFieldType.OFTReal )
        writefln( "%.3f,", OGR_F_GetFieldAsDouble( feature, field_id) );
    else if( OGR_Fld_GetType(field_def) == OGRFieldType.OFTString )
        writefln( "%s,", OGR_F_GetFieldAsString( feature, field_id) );
    else
        writefln( "%s,", OGR_F_GetFieldAsString( feature, field_id) );
  }
  
  
  
  
}