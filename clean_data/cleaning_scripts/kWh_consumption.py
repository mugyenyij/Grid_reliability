import pandas as pd
import numpy as np
def electricity_consumption(year,y):
    '''
    Compute consumption for corresponding electricity expenditure

    '''
    kWhs = 0
    if year == 2016:
        kWhs = y/182
        
    elif year == 2017:

        if y>7705:
            kWhs = (y-7705)/189
            kWhs = kWhs + 50
        elif 1335<y<=7705:
            kWhs = (y-1335)/182
            kWhs = kWhs +15
        elif y<=1335:
            kWhs = (y)/89
        else:
            raise(f'{y} is an Invalid consumption expenditure input!')
    else:
        raise(f'{year} is not a valid year input')
    return kWhs
def appliance_groups(cnt):
    '''
    appliance ownership groups
    '''
    if cnt ==0:
        return '0'
    elif cnt == 1:
        return '1'
    elif cnt ==2 :
        return '2'
    elif cnt ==3:
        return '3'
    elif cnt ==4:
        return '4'
    else:
        return '>5'
def group_mean_difference(appliance_names,appliance_names_dict,appliances_xtcs):
    """
    Create features dataframe to be used in regression analysis where the difference between the appliance group mean and the hh is obtained
    """
    final_df = pd.DataFrame([])
    for appliance_name in appliance_names:
        df = appliances_xtcs[appliance_names_dict[appliance_name]+[f'{appliance_name}_grp']].copy()
        if 'log_monthly_expenses_qsel' in appliance_names_dict[appliance_name]:
            df['log_monthly_expenses_qsel'] = df['log_monthly_expenses_qsel'].replace(-np.inf, np.nan)

        df_grpd = df.groupby([f'{appliance_name}_grp']).mean().reset_index().drop(columns='hhid').add_suffix('_grp_mean').rename(columns={f'{appliance_name}_grp_grp_mean':f'{appliance_name}_grp'})
        temp_df = df.merge(df_grpd,how='left').set_index('hhid')
        cols = df.drop(columns=['hhid',f'{appliance_name}_grp']).columns.tolist()
        for col in cols:
            temp_df[f'{col}_{appliance_name}_diff'] = temp_df[f'{col}']-temp_df[f'{col}_grp_mean']
        lst = temp_df.columns.tolist()
        _ = temp_df[[s for s in lst if '_diff' in s]].reset_index()
        tmp_diff_df = appliances_xtcs[['hhid',f'{appliance_name}']].merge(_)
        tmp_diff_df = tmp_diff_df.set_index('hhid')
        appl_series_df = tmp_diff_df[f'{appliance_name}']
        appl_df = tmp_diff_df.drop(columns=f'{appliance_name}').multiply(appl_series_df,axis='index')
        # appl_df[f'{appliance_name}'] = appl_series_df
        appl_df.insert(loc=0, column=f'{appliance_name}', value=appl_series_df)
        # appl_df = appl_df.reset_index()
        final_df = pd.concat([final_df, appl_df],axis=1)
    
    return final_df
def group_mean(appliance_names,appliance_names_dict,appliances_xtcs):
    """
    Create features dataframe to be used in regression analysis where the difference between the appliance group mean and the hh is obtained
    """
    final_df = pd.DataFrame([])
    for appliance_name in appliance_names:
        df = appliances_xtcs[appliance_names_dict[appliance_name]+[f'{appliance_name}_grp']].copy()
        if 'log_monthly_expenses_qsel' in appliance_names_dict[appliance_name]:
            df['log_monthly_expenses_qsel'] = df['log_monthly_expenses_qsel'].replace(-np.inf, np.nan)

        df_grpd = df.groupby([f'{appliance_name}_grp']).mean().reset_index().drop(columns='hhid').add_suffix('_grp_mean').rename(columns={f'{appliance_name}_grp_grp_mean':f'{appliance_name}_grp'})
        temp_df = df.merge(df_grpd,how='left').set_index('hhid')
        cols = df.drop(columns=['hhid',f'{appliance_name}_grp']).columns.tolist()
        for col in cols:
            temp_df[f'{col}_{appliance_name}_diff'] = temp_df[f'{col}']-temp_df[f'{col}_grp_mean']
        lst = temp_df.columns.tolist()
        _ = temp_df[[s for s in lst if '_diff' in s]].reset_index()
        tmp_diff_df = appliances_xtcs[['hhid',f'{appliance_name}']].merge(_)
        tmp_diff_df = tmp_diff_df.set_index('hhid')
        appl_series_df = tmp_diff_df[f'{appliance_name}']
        appl_df = tmp_diff_df.drop(columns=f'{appliance_name}').multiply(appl_series_df,axis='index')
        # appl_df[f'{appliance_name}'] = appl_series_df
        appl_df.insert(loc=0, column=f'{appliance_name}', value=appl_series_df)
        # appl_df = appl_df.reset_index()
        final_df = pd.concat([final_df, appl_df],axis=1)
    
    return final_df