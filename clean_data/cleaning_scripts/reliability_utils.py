
import pandas as pd
import geopandas as gpd
from shapely.geometry import box
import colorsys

def clean_meta_data(meta_df):
    # split column and add new columns to df, add meter_numb column
    a = meta_df['meter_serial_number_consumer_id'].str.split('_', expand=True)
    meta_df['Meter_Numb'] = a[0]
    meta_df['customer_ID'] = a[1]

    # convert column 'Meter_Numb' to float
    meta_df['Meter_Numb'] = pd.to_numeric(meta_df['Meter_Numb'],errors='coerce') 
    meta_df['customer_ID'] = pd.to_numeric(meta_df['customer_ID'],errors='coerce')
    meta_df = meta_df[['meter_serial_number_consumer_id', 'vending_category_name',
           'district_id', 'district', 'installation_date','eguide_categories', 'Meter_Numb']]
    
    return meta_df


def clean_reliability_files(mv_outages_2020, mv_outages_2019, mv_outages_2018, mv_outages_2017, mv_outages_2016):

    # remove unnecessary columns 
    mv_outages_2020 = mv_outages_2020.iloc[:,1:21] 
    mv_outages_2019 = mv_outages_2019.iloc[:,1:15]
    mv_outages_2018 = mv_outages_2018.iloc[:,1:15]
    mv_outages_2017 = mv_outages_2017.iloc[:,1:]
    mv_outages_2016 = mv_outages_2016.iloc[:,1:]


    # to lower case
    reliablity_dfs = [mv_outages_2020, mv_outages_2019, mv_outages_2018, mv_outages_2017, mv_outages_2016]
    cols = ['Feeder','Substation Name','Hubs', 'Substation']
    for num,df in enumerate(reliablity_dfs):
        for column in cols:
            try:
                df.loc[:,column] = df[column].str.lower()
                df.loc[:,column] = df[column].str.replace(' ', '')
            except KeyError:
                _ = (f'{column} absent in dataframe')
    return reliablity_dfs

def clean_lines(lines):
    # set variables
    feeder_dfs = []
    feeder_bboxs = []
    project_crs = 'epsg:32735'
    geo_crs = 'epsg:4326'
    cols = ['Feeder_Nam','Substation','Branch_Nam']
    corrupt_gps_lines = ['kabarondo',"trf nyamirondogoro",'gikondo','cpgl']
    # set to lower case
    for column in cols:
        lines.loc[:,column] = lines[column].str.lower()
        lines.loc[:,column] = lines[column].str.strip()

    # correct feeder names
    lines['Feeder_Nam'] = lines['Feeder_Nam'].replace(mapping_dict_lines)
    lines['Feeder_Nam'] = lines.apply(lambda x: feeder_name_correction(x.Substation,x.Feeder_Nam),axis=1) # correct wrong feeder names

    lines = lines[~lines['Feeder_Nam'].isin(corrupt_gps_lines)] # remove corrupt lines. GPS coordinates corrupted
    lines = lines[~lines.Feeder_Nam.isna()] # remove feeders with no names
    lines = lines.to_crs(geo_crs) # set WSG84 as CRS
    # bounding boxes of feeders with gps errors
    problem_feeder_bbox_dict = {"kibuye":box(29.25,-2.2,29.56,-1.85),"kigali":box(29.90347104, -1.97384612, 30.065864  , -1.79235741),
        "bugarama":box(28.95,-2.75,29.06,-2.6),"mashyuza":box(28.8675864,-2.6647688,29.1,-2.35),"zaza":box(30.25,-2,30.85521333,-2.4),
        "gatumba":box(29.56,-2.26121117,29.88146333,-1.8),"gisenyi":box(29.284305,-1.4,29.7,-1.9),"ntongwe":box(29.793658  , -2.32904067, 29.97711686, -2.03),
        "kkk":box(30.42676433, -2.05, 30.65, -1.69940648),
        }
    problem_feeders = list(problem_feeder_bbox_dict.keys()) # list of problem feeders. Feeders with gps issues
    feeders = lines.Feeder_Nam.unique().tolist() # list of all feeders



    for feeder in feeders:
        # print(f'feeder name: {feeder}')
        if feeder in problem_feeders:
            feeder_bbox = problem_feeder_bbox_dict[feeder]
            data_feeder_lines = lines[lines.Feeder_Nam==feeder].copy()
            # print(f'Before {feeder}:  {data_feeder_lines.shape}')
            clean_data_feeder_lines = data_feeder_lines[data_feeder_lines.geometry.intersects(feeder_bbox)]
            # print(f'After {feeder}:  {clean_data_feeder_lines.shape}')
        else:
            clean_data_feeder_lines = lines[lines.Feeder_Nam==feeder].copy()
            total_bounds = clean_data_feeder_lines.total_bounds
            feeder_bbox = box(total_bounds[0], total_bounds[1], total_bounds[2]  , total_bounds[3])
        feeder_bboxs.append(feeder_bbox)
        feeder_dfs.append(clean_data_feeder_lines)
    data = {'Feeder_Nam': feeders,}# 'geometry': feeder_bboxs}
    feeder_bboxs_gdf = gpd.GeoDataFrame(data, geometry=feeder_bboxs,crs=geo_crs)

    clean_lines = pd.concat(feeder_dfs)
    
    return clean_lines,feeder_bboxs_gdf

def color_palette(num_colors):
    '''
    Select distinct colors
    '''
    distinct_colors = []
    # num_colors=len(columns)
    count = 0
    for i in range(num_colors):
        hue = i / num_colors
        rgb_color = colorsys.hsv_to_rgb(hue, 1, 1)
        scaled_color = [int(c * 255) for c in rgb_color]
        hex_color = "#{:02X}{:02X}{:02X}".format(*scaled_color)
        distinct_colors.append(hex_color)
    return distinct_colors

def dark_color_palette(num_colors):
    '''
    Select distinct colors primarily with a darker theme
    '''
    distinct_colors = []

    for i in range(num_colors):
        hue = i / num_colors
        # Decrease the value (brightness) for a darker theme
        rgb_color = colorsys.hsv_to_rgb(hue, 1, 0.7)
        scaled_color = [int(c * 255) for c in rgb_color]
        hex_color = "#{:02X}{:02X}{:02X}".format(*scaled_color)
        distinct_colors.append(hex_color)

    return distinct_colors

def feeder_name_correction(substation, feeder):
    if substation=='birembo' and feeder=='remera':
        return 'kibagabaga/remera'
    elif substation=='rwinkwavu' and feeder=='kagera':
        return 'akagera'
    else:
        return feeder

def merge_meters_2_lines(meter_gps,lines, meter_line_distance=80):
    # Use projected CRS
    meter_gps = meter_gps.to_crs('epsg:32735')
    
    meter_cols = ['Meter_Numb','Transforme','MV_Feeder_',
            'Branch_Nam', 'Connection', 'longitude',
           'latitude', 'District', 'geometry']
    lines_cols = ['OBJECTID','Substation','Feeder_Nam','Branch_Nam','geometry']

    # merge meters with feeder lines
    meter_line_dist = meter_line_distance
    meter_lines = meter_gps[meter_cols].sjoin_nearest(lines[lines_cols],
                           how='left', distance_col='distance_to_line', max_distance=meter_line_dist)
    
    return meter_lines
# match feeder names


# Define the misspelled and correct words
wrong_spelling_2016 = ['cimerwa1','kibagabaga/nyar','kibagabaga/reme',]
correct_spelling_2016 = ['cimerwa-1','kibagabaga/nyarutarama','kibagabaga/remera',]
# Create a dictionary to map the misspelled words to their correct spelling
mapping_dict_2016 = dict(zip(wrong_spelling_2016, correct_spelling_2016))


# Define the misspelled and correct words
wrong_spelling_2017 = ['byumbafromgatuna', 'janja&remera', 'redemi(musha)', 'rubona(solarplant)', 'rubonasolar','rubonasolarpp', 'rukarara2']
correct_spelling_2017 = ['byumba', 'janja', 'redemi', 'rubona', 'rubona', 'rubona', 'rukarara-2']
# Create a dictionary to map the misspelled words to their correct spelling
mapping_dict_2017 = dict(zip(wrong_spelling_2017, correct_spelling_2017))


# Define the misspelled and correct words
wrong_spelling_2018 = [
'byumbafromgatuna',
 'byumbafromrulindo',
#  'campbelge',
#  'cimerwa-2',
#  'cyanika',
#  'feezonei',
#  'gakenke',
#  'gasiza',
#  'gifurwe',
#  'inyange',
 'janja&remera',
#  'kabuga',
 'kibagabaga/nyar',
 'kibagabaga/reme',
#  'kilindamission',
#  'kirambo',
#  'kiziguro',
#  'ngarama',
#  'nyagatare',
 'redemi(musha)',
 'rubonasolarpv',
 'rukarara1',
 'rukarara2',
#  'rwaza',
#  'sucrerie',
 'utexrwa'
 ]
correct_spelling_2018 = [
    'byumba',
    'byumba',
    'janja',
    'kibagabaga/nyarutarama',
    'kibagabaga/remera',
    'redemi',
    'rubona',
    'rukarara-1',
    'rukarara-2',
    'utexirwa',
    ]
# Create a dictionary to map the misspelled words to their correct spelling
mapping_dict_2018 = dict(zip(wrong_spelling_2018, correct_spelling_2018))


# Define the misspelled and correct words
wrong_spelling_2019 = [
 'byumbafromgatuna',
 'byumbafromrulindo',
 'byumbarulindo',
#  'campbelge',
 'kibagabaga/nyar',
 'kibagabaga/reme',
#  'kilinda',
#  'kilindamission',
#  'kirambo',
#  'kitrako',
#  'kiziguro',
#  'mastelsteel',
#  'mastersteel',
#  'ngarama',
#  'nyabugogo',
#  'nyagatare',
#  'nzove',
#  'pylon20',
#  'pylone20',
#  'rebero(nyarur)',
#  'rebero(nyarurama)',
 'redemi/musha',
 'redemi/rwinkwavu',
 'rukarara1',
 'rukarara2',
#  'rwaza',
#  'serena',
#  'serenah.',
#  'skol',
#  'sucrerie',
 'utexrwa']
correct_spelling_2019 = [
    'byumba',
    'byumba',
    'byumba',
    'kibagabaga/nyarutarama',
    'kibagabaga/remera',
    'redemi',
    'redemi',
    'rukarara-1',
    'rukarara-2',
    'utexirwa',
]
# Create a dictionary to map the misspelled words to their correct spelling
mapping_dict_2019 = dict(zip(wrong_spelling_2019, correct_spelling_2019))



# Define the misspelled and correct words
wrong_spelling_2020 = [
 'byumbafromgatuna',
 'byumbafromrulindo',
#  'campbelge',
#  'cimerwa-2',
#  'cyanika',
#  'departkigali',
#  'freezonei',
#  'gakenke',
#  'gasiza',
#  'gatuna',
#  'inyange',
#  'judiciaire',
#  'kabuga',
 'kibagabaga/reme',
#  'kilindamission',
#  'kirambo',
#  'kitrako',
#  'kiziguro',
#  'mastersteel',
#  'ngarama',
#  'nyagatare',
#  'nzove',
#  'pylon20',
#  'rebero(nyar)',
 'rukarara2',
#  'rwaza',
#  'serena',
#  'skol',
#  'steelrwa',
#  'sucrerie',
 'utexrwa'
]
correct_spelling_2020 = [
    'byumba',
    'byumba',
    'kibagabaga/remera',
    'rukarara-2',
    'utexirwa',
]
# Create a dictionary to map the misspelled words to their correct spelling
mapping_dict_2020 = dict(zip(wrong_spelling_2020, correct_spelling_2020))


# Define the misspelled and correct words
wrong_spelling_lines = ['arrive ntaruka','deutsch welle','deutsche welle', 'deutschewelle','deutschewlle',
                         'deutshewelle', 'gikondo haut', 'hodpital', 'kibagabaga nyarutarama', 'kibagabaga remera',  'kigali i',  'kigali north', 'kigali sourth', 
                         'kigali south',  'kigufi', 'kiyunva', 'kk',  'mururu i',  'parc industriel', 'parc industriel"',  'park industriel',    
                             'rukarara', 'rukarara  ii', 'rukarara ii',   'rwamana',   'rwankina',  'utexrwa', 'utexwa']
correct_spelling_lines = [    'ntaruka',    'd-welle',    'd-welle',    'd-welle',    'd-welle',    'd-welle',    'gikondohaut', 
                             'hospital',    'kibagabaga/nyarutarama',    'kibagabaga/remera',    'kigali',    'kigalinorth',  
                                 'kigalisouth',    'kigalisouth',    'kigali',    'kiyumba',    'kkk',    'mururu-1',    'parcindustriel', 
                                       'parcindustriel',    'parcindustriel',    'rukarara-1',    'rukarara-2',    'rukarara-2',    'rwamagana',  
                                           'rwakina',    'utexirwa',    'utexirwa']

# Create a dictionary to map the misspelled words to their correct spelling
mapping_dict_lines= dict(zip(wrong_spelling_lines, correct_spelling_lines))
