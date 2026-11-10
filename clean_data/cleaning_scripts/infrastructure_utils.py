import pandas as pd
import geopandas as gpd

def get_survey_geopandas_df(eicv_HH, geo_crs, project_crs, project=True):

    temp = eicv_HH.groupby(['hhid'])['s0q15n'].unique().reset_index(
    ).explode('s0q15n').rename(columns={'s0q15n':'Name_HHH'})

    temp = temp.merge(eicv_HH[['hhid','district','cs_dname','cs_sname','cs_cname','cs_vname','lat','longitude']],
                        on=['hhid'], how='left')
    survey = temp.drop_duplicates()
    survey = survey.drop_duplicates(subset=['hhid'],keep='first')

    # Convert to lowercase
    columns = ['Name_HHH','district','cs_dname','cs_sname','cs_cname','cs_vname']
    for col in columns:
        survey[col] = survey[col].str.lower() # convert to lower
        survey[col] = survey[col].str.strip() # remove leading and trailing whitespace
        
    # create geopandas dataframe using latitude and longitude   
    temp_df = survey.copy()
    survey_gdf = gpd.GeoDataFrame(
        temp_df, geometry=gpd.points_from_xy(survey.longitude, survey.lat), crs=geo_crs)
    
    if project:
        survey_gdf = survey_gdf.to_crs(project_crs)
    
    return survey_gdf