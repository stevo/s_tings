module STingsHelper
  def settings_field_for(key,val)
    return case val.class.name
    when 'Fixnum' then settings_text_field(key,val,"Fixnum")
    when 'Float' then settings_text_field(key,val,"Float")
    when 'String' then val.include?("\n") ? settings_text_area(key,val) : key.include?('password') ? settings_password_field(key,val) : settings_text_field(key,val)
    when 'TrueClass','FalseClass' then settings_check_box(key,val)
    end
  end

  def settings_text_area(key,val,var_type="String")
    text_area_tag "setting_values[#{key}_#{var_type}]", val
  end

  def settings_text_field(key,val,var_type="String")
    text_field_tag "setting_values[#{key}_#{var_type}]", val, :size => 50
  end

  def settings_password_field(key,val,var_type="String")
    password_field_tag "setting_values[#{key}_#{var_type}]", val, :size => 50
  end

  def settings_check_box(key,val)
    check_box "setting_values", "#{key}_Boolean",{:checked => val}, true, false
  end

end

