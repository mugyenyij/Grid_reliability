import numpy as np
import pandas as pd
def school_costs(data,col_name,new_col_name):
    """
    function to calculate education costs
    """
    data[col_name] = data[[col_name]].astype(str)
    data.loc[data[col_name]=='Zero',col_name]=0
    data = data[['hhid','pid',col_name]].astype(float).groupby('hhid')[col_name].sum(
    ).reset_index().rename(columns={
        col_name:new_col_name
    })
    return data

def filter_appliance(data):
    appliances = data[~data.item_code.isin([13,14,15,19,26,27,29])]
    temp = appliances.groupby(['hhid','item_code'])['articles_in_HH_count'].sum().reset_index()
    temp = temp.pivot(index='hhid', columns='item_code', values='articles_in_HH_count').reset_index()
    appliance_count =temp.rename(columns={
        5:'Radio',
        6:'Mobile_phones',
        7:'TV',
        8:'satellite_dish',
        9:'dvd_player',
        10:'decoder',
        11:'music_syst',
        12:'computer',
        16:'cooker',
        17:'laundry_mach',
        18:'electric_fan',
        20:'fridge',
        21:'generator_as_appliance',
        22:'hotplate',
        23:'power_stabilizer',
        24:'still_camera',
        25:'video_camera',
        28:'printer',

    })
    # 13 	Living room suite _arm chairs, couch, coffee tables_ 
    # 14 	Bicycle _For home use only_ 
    # 15 	Cupboard 
    # 16 	Cooker 
    # 19 	Sewing machine 
    # 26 	Motorcycle _For home use only_ 
    # 27 	Car _for home use only_ 
    # 29 	Water Filter 
    appliance_count['num_appliances_HH'] = appliance_count.iloc[:,1:].sum(axis=1)
    return appliance_count

def filter_poverty(data):
    poverty = data[['hhid','member','membernos','exp1','exp4','exp5','exp7','exp8','food','cons1',]]
    poverty = poverty.rename(columns={
        'member':'member_count',
        'membernos':'member_count_minus_servants',
        'exp1':'educ_expenses',
        'exp4':'imputed_rent',
        'exp5':'actual_rent',
        'exp7':'water_expense',
        'exp8':'elec_expense',
        'food':'food_expense',
        'cons1':'annual_consumption',
    })
    return poverty

# def filter_furniture(data):
#     temp = data.groupby(['hhid','item_code'])['articles_in_HH_count'].sum().reset_index()
#     temp = temp.pivot(index='hhid', columns='item_code', values='articles_in_HH_count').reset_index()
#     furniture_count =temp.rename(columns={
#         1:'Benches',
#         2:'chairs',
#         3:'beds',
#         4:'tables',
#         })
#     return furniture_count

def filter_non_electric(furniture, non_electric):

    temp = furniture.groupby(['hhid','item_code'])['articles_in_HH_count'].sum().reset_index()
    temp = temp.pivot(index='hhid', columns='item_code', values='articles_in_HH_count').reset_index()
    furniture_count =temp.rename(columns={
        1:'Benches',
        2:'chairs',
        3:'beds',
        4:'tables',
        })
    
    non_electric = non_electric[non_electric.item_code.isin([13,14,15,19,26,27,29])]
    temp = non_electric.groupby(['hhid','item_code'])['articles_in_HH_count'].sum().reset_index()
    temp = temp.pivot(index='hhid', columns='item_code', values='articles_in_HH_count').reset_index()
    non_electric_count =temp.rename(columns={
    13:"Living_room_furniture",
    14:"Bicycle_For_home", 
    15:"Cupboard", 
    # 16:"Cooker", 
    19:"Sewing_machine", 
    26:"Motorcycle_For_home", 
    27:"Car_for_home", 
    29:"Water_Filter", 
        })
    non_electric_count = non_electric_count.merge(furniture_count)

    return non_electric_count
def assign_tier(hhid, tier_0_hhids,tier_1_hhids, tier_2_hhids,tier_3_hhids, tier_4_hhids,):

    if hhid in (tier_0_hhids):
        return 'tier_0'
    elif hhid in (tier_1_hhids):
        return 'tier_1'
    elif hhid in (tier_2_hhids):
        return 'tier_2'
    elif hhid in (tier_3_hhids):
        return 'tier_3'
    elif hhid in (tier_4_hhids):
        return 'tier_4'
    else:
        return np.nan
    
def check_list_unique(tier_hhid_list):
  seen = set()
  repeated = set()
  for l in tier_hhid_list:
    for i in set(l):
      if i in seen:
        repeated.add(i)
      else:
        seen.add(i)
  return len(repeated)

def loose_assign_tier(hhid, tier_level ,tier_2_hhids,tier_3_hhids, tier_4_hhids,):

    if (hhid in (tier_2_hhids)) & (tier_level is None):
        return 'tier_2'
    elif (hhid in (tier_3_hhids)) & (tier_level is None):
        return 'tier_3'
    elif (hhid in (tier_4_hhids)) & (tier_level is None):
        return 'tier_4'
    else:
        return tier_level
    
def loose_tier_assignment(appliance_presence,any_tier2_appliance,
                           any_tier3_appliance,any_tier4_appliance):
    tier_2_hhids = appliance_presence[appliance_presence.tier_level.isna()&any_tier2_appliance& ~any_tier3_appliance & ~any_tier4_appliance]['hhid'].tolist()
    tier_3_hhids = appliance_presence[appliance_presence.tier_level.isna()&any_tier3_appliance & ~any_tier4_appliance]['hhid'].tolist()
    tier_4_hhids = appliance_presence[appliance_presence.tier_level.isna()&any_tier4_appliance]['hhid'].tolist()

    tier_hhid_list = [tier_2_hhids, tier_3_hhids,tier_4_hhids]

    return tier_hhid_list

def strict_tier_assignment(appliance_presence, any_tier1_appliance,any_tier2_appliance,
                           any_tier3_appliance,any_tier4_appliance):

    tier_1_hhids = appliance_presence[any_tier1_appliance& ~any_tier2_appliance
                                    & ~any_tier3_appliance & ~any_tier4_appliance]['hhid'].tolist()
    tier_2_hhids = appliance_presence[any_tier1_appliance & any_tier2_appliance
                                    & ~any_tier3_appliance & ~any_tier4_appliance]['hhid'].tolist()
    tier_3_hhids = appliance_presence[any_tier1_appliance & any_tier2_appliance 
                                    & any_tier3_appliance & ~any_tier4_appliance]['hhid'].tolist()
    tier_4_hhids = appliance_presence[any_tier1_appliance & any_tier2_appliance
                                    & any_tier3_appliance & any_tier4_appliance]['hhid'].tolist()

    tier_hhid_list = [tier_1_hhids, tier_2_hhids, tier_3_hhids,tier_4_hhids]

    return tier_hhid_list

def strict_assign_tier(hhid, tier_0_hhids, tier_1_hhids, tier_2_hhids,tier_3_hhids, tier_4_hhids,):

    if hhid in (tier_0_hhids):
        return 'tier_0'
    elif hhid in (tier_1_hhids):
        return 'tier_1'
    elif hhid in (tier_2_hhids):
        return 'tier_2'
    elif hhid in (tier_3_hhids):
        return 'tier_3'
    elif hhid in (tier_4_hhids):
        return 'tier_4'
    else:
        return None
    
district_mapping = {11:'nyarugenge',12:'gasabo',13:'kicukiro', 21:'nyanza',22	:'gisagara',23:'nyaruguru',24:'huye',25:'nyamagabe',
                  26:'ruhango',27:'muhanga',28:'kamonyi',31:'karongi',32:'rutsiro',33:'rubavu',34:'nyabihu',35:	'ngororero'
                  ,36:'rusizi',37:'nyamasheke',41:'rulindo',42:'gakenke',43:'musanze',44:'burera',45:'gicumbi',51:'rwamagana'
                  ,52:	'nyagatare',53:	'gatsibo',54:	'kayonza',55:	'kirehe',56:	'ngoma',57:	'bugesera' }
province_mapping = {
    1:'kigali',2:'southern',3:'western',4:'northern',5:'eastern'
}

urban_rural_mapping = {
    1:'urban',2:'rural',3:'peri_urban',4:'semi_urban'
}

def get_HoH_primary_occupation(employ_data, demo_data):

    employ_data = employ_data.rename(columns={
        's6bq3b':'occupation_group',
        's6bq4b':'industry',
        's6bq14':'sector',
        's6bq13a':'years_employed',
        's6bq13b':'months_employed',
        's6cq16':'nature_of_contract',
        's6cq17a':'wage_amount',
        's6cq17b':'wage_unit',
        's6cq18':'in_kind_payments',
        's6cq19a':'value_in_kind_payments',
        's6cq19b':'unit_in_kind_payments',
        's6bq99':'secondary_job',
        's6dq25':'sought_loan_past_year',
        's6dq26':'vup_loan',

    })[['hhid','pid','eid','occupation_group','industry','sector','years_employed','months_employed','nature_of_contract',
        'wage_amount','wage_unit','in_kind_payments','value_in_kind_payments','unit_in_kind_payments',
        'secondary_job','sought_loan_past_year','vup_loan']]

    employment = employ_data.merge(demo_data[['hhid','pid','s1q2']],on=['hhid','pid'])

    HoH_employment = employment[employment.s1q2=='Household head _HH_'].sort_values(['hhid','years_employed'])
    HoH_occupation = HoH_employment.drop_duplicates(subset=['hhid'],keep='last') # keep oldest employment

    # Primary occupations dataset
    merged = pd.concat([HoH_occupation['hhid'], pd.get_dummies(HoH_occupation.occupation_group)], axis='columns')
    temp = HoH_employment.groupby('hhid')['eid'].count().reset_index().rename(columns={'eid':'number_of_reported_occupations'})
    merged = merged.merge(temp, on='hhid')
    HoH_primary_occupations = merged.rename(columns={
    'Skilled agricultural, forestry, and fishery workers':'farming_fishing_forestry',
    'Services and sales workers':'service_workers',
    'Craft and related trades workers':'crafts_and_trades',
    'Elementary occupations':'elementary_workers',
    'Plant and machine operators, and assemblers':'factory_workers',
    'Technical and associate professionals': 'technicians',
    'Clerical support workers':'clerical_work',
    })

    return HoH_primary_occupations


def convert_tier_level_2_numeric(tier):

    if tier== 'tier_0':
        return 0
    elif tier=='tier_1':
        return 1
    elif tier=='tier_2':
        return 2
    elif tier=='tier_3':
        return 3
    elif tier=='tier_4':
        return 4
    else:
        return None
def get_contract_payments(employ_df):
    # nature of contracts
    contract_status = employ_df[['hhid','pid','s6cq16']].dropna()
    contract_status = contract_status.groupby(['hhid','s6cq16']).count().reset_index().rename(columns={'pid':'number_of_members'})
    contract_status = contract_status.pivot(index='hhid',values='number_of_members',columns='s6cq16').reset_index().rename(columns={
        'Casual worker':'Casual_worker',
        'Daily worker':'Daily_worker',
        'Permanent worker':'Permanent_worker',
        'Seasonal worker':'Seasonal_worker',
        'Temporary worker':'Temporary_worker'
    })

    # payment frequency
    payment_freq = employ_df[['hhid','pid','s6cq17b']].dropna()
    payment_freq = payment_freq.groupby(['hhid','s6cq17b']).count().reset_index().rename(columns={'pid':'number_of_members'})
    payment_freq = payment_freq.pivot(index='hhid',values='number_of_members',columns='s6cq17b').reset_index().rename(columns={
        'Day':'daily_payment',
        'Month':'monthly_payment',
        'Week':'weekly_payment',
        'Year':'yearly_payment'
    })
    contract_payments = contract_status.merge(payment_freq, how='outer')

    return contract_payments

def categorize_received_vup(row):
    if row =='No, never' or row =='Currently Eligible but not yet benefiting':
        return 'No_VUP'
    elif row =='Yes in the past  but not now' or row =='Currently VUP beneficiary':
        return 'Yes_VUP'
    else:
        raise Exception('Wrong Input!')
def categorize_small_crop_sales(row):
    if row =='Yes, regularly all' or row =='Yes, regularly part of it' or row =='Yes, ocasionally all' or row =='Yes, ocasionally part of it':
        return 'yes_sell_small_crop'
    elif row =='Never':
        return 'no_sell_small_crop'
    else:
        raise Exception('Wrong Input!')
    
def get_salary_info(employ):

    # nature of contracts
    contract_status = employ[['hhid','pid','s6cq16','s6cq17a']].dropna()
    contract_status = contract_status.pivot_table(index='hhid',values='s6cq17a',columns='s6cq16')
    contract_status['non_permanent_net_salary'] = contract_status[['Casual worker', 'Daily worker', 'Other', 'Seasonal worker', 'Temporary worker']].sum(axis=1)
    contract_status = contract_status.drop(['Casual worker', 'Daily worker', 'Other', 'Seasonal worker', 'Temporary worker'],axis=1).fillna(0)
    contract_status = contract_status.div(contract_status.sum(axis=1), axis=0).reset_index().rename(columns={'Permanent worker':'permanent_worker'})

    # occupations in household
    occupations = employ[['hhid','pid','s6bq3b','s6cq17a']].dropna()
    occupations = occupations.pivot_table(index='hhid',values='s6cq17a',columns='s6bq3b')

    high_skill = ['Managers','Professionals','Technical and associate professionals']
    medium_skill = ['Skilled agricultural, forestry, and fishery workers','Clerical support workers',
                                                        'Craft and related trades workers','Plant and machine operators, and assemblers','Services and sales workers']

    occupations = occupations.rename(columns={'Elementary occupations':'low_skill_occupations'})
    occupations['medium_skill_occupations'] = occupations[medium_skill].sum(axis=1)
    occupations['high_occupations'] = occupations[high_skill].sum(axis=1)
    occupations = occupations.drop(medium_skill+high_skill,axis=1).fillna(0)
    occupations = occupations.div(occupations.sum(axis=1), axis=0).reset_index()

    # wage payment frequency
    wage_unit = employ[['hhid','pid','s6cq17b','s6cq17a']].dropna()
    wage_unit = wage_unit.pivot_table(index='hhid',values='s6cq17a',columns='s6cq17b').fillna(0)
    wage_unit = wage_unit.div(wage_unit.sum(axis=1), axis=0).reset_index()
    wage_unit = wage_unit.rename(columns={
        'Day':'daily_payment',
        'Month':'monthly_payment',
        'Week':'weekly_payment',
        'Year':'yearly_payment',
    })

    # merge data
    HH_salaries =  contract_status.merge(wage_unit, how='outer').merge(occupations,how='outer')

    return HH_salaries
    
# vup_public_works_tmp = pd.read_spss(dir_path+'cs_S9C3_Vup_ubudehe_and_Rssp_schemes.sav') 
# vup_public_works_tmp[['hhid','s9cq1','s9cq2']].s9cq2.value_counts()
# vup_public_works =vup_public_works_tmp[['hhid','s9cq1','s9cq2','s9cq4a','s9cq4b','s9cq4c','s9cq4d','s9cq4e','s9cq4f','s9cq4g','s9cq4h','s9cq4i','s9cq4j','s9cq16','s9cq26','s9cq27','s9cq28',
#                   's9cq29a','s9cq29b','s9cq29c','s9cq29d','s9cq29e','s9cq29f','s9cq29g','s9cq29h','s9cq29i','s9cq29j','s9cq29k','s9cq29l']].rename(columns={
#     's9cq1':'vup_HH_category','s9cq2':'received_income_vup',
# 's9cq4a':'programs_2008','s9cq4b':'programs_2009','s9cq4c':'programs_2010','s9cq4d':'programs_2011','s9cq4e':'programs_2012','s9cq4f':'programs_2013',
# 's9cq4g':'programs_2014','s9cq4h':'programs_2015','s9cq4i':'programs_2016','s9cq4j':'programs_2017','s9cq16':'daily_wage','s9cq26':'pw_amount_last_payment',
# 's9cq27':'pw_amount_last_12_months','s9cq28':'ever_received_vup_access_grant',
#      's9cq29a':'invest_food','s9cq29b':'invest_clothes','s9cq29c':'invest_utensils','s9cq29d':'invest_durable_assets','s9cq29e':'invest_education','s9cq29f':'invest_health',
#      's9cq29g':'invest_animals','s9cq29h':'invest_farm','s9cq29i':'invest_business','s9cq29j':'invest_home_improvements','s9cq29k':'invest_savings',
#      's9cq29l':'invest_others'
#      })
# vup_fs_tmp = pd.read_spss(dir_path+'cs_S9C4_Vup_ubudehe_and_Rssp_schemes.sav') 
# vup_fs_tmp[['hhid','s9cq1','s9cq2']].s9cq2.value_counts()
# vup_fs = vup_fs_tmp[['hhid','s9cq1','s9cq2','s9cq4a','s9cq4b','s9cq4c','s9cq4d','s9cq4e','s9cq4f','s9cq4g','s9cq4h','s9cq4i','s9cq4j','s9c4q33','s9c4q34','s9c4q37','s9c4q38a']].rename(columns={
#     's9cq1':'vup_HH_category','s9cq2':'received_income_vup',
# 's9cq4a':'programs_2008','s9cq4b':'programs_2009','s9cq4c':'programs_2010','s9cq4d':'programs_2011','s9cq4e':'programs_2012','s9cq4f':'programs_2013',
# 's9cq4g':'programs_2014','s9cq4h':'programs_2015','s9cq4i':'programs_2016','s9cq4j':'programs_2017','s9c4q33':'group_size','s9c4q34':'loan_amount',
# 's9c4q37':'independent_amount','s9c4q38a':'loan_primary_use'
#      })