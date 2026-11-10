def name_provinces(province):
    if province=='Amajyaruguru':
        return 'Northern'
    elif province=='Amajyepfo':
        return 'Southern'
    elif province=='Iburasirazuba':
        return 'Eastern'
    elif province=='Iburengerazuba':
        return 'Western'
    elif province=='Umujyi wa Kigali':
        return 'Kigali'
    else:
        raise Exception('Wrong Province name')
    
def purchase_categories(purchase):
    if purchase == 500:
        return "500 payments"
    elif purchase == 1000:
            return "1000 payments"
    elif purchase == 2000:
            return "2000 payments"
    else:
        return 'rest'  

appliance_list = ['Radio_present','Mobile_phones_present','TV_present','satellite_dish_present','dvd_player_present','decoder_present','music_syst_present',
                                 'computer_present','cooker_present','laundry_mach_present','electric_fan_present','fridge_present','hotplate_present','still_camera_present','video_camera_present','printer_present']