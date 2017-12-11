$ ->
  $("#user_profile_attributes_city").geocomplete().bind "geocode:result", (event, result) ->
    city = ''
    result.address_components.forEach (component) ->
      if component.types.indexOf('locality') > -1
        city = component.long_name
      return
    if city == ''
      city = result.address_components[0].long_name

    formatted_address_array = result.formatted_address.split(",")
    $(this).val(city || result.name || formatted_address_array[0])
