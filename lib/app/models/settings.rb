class Settings < ActiveRecord::Base
  class SettingNotFound < RuntimeError;
  end

  DEFAULTS_PATH = File.join(RAILS_ROOT, 'config', 'settings_defaults.rb').freeze
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].freeze

  #get or set a variable with the variable as the called method
  def self.method_missing(method, *args)
    method_name = method.to_s
    super(method, *args)

  rescue NoMethodError
    #set a value for a variable
    if method_name =~ /=$/
      var_name = method_name.gsub('=', '')
      value = args.first
      self[var_name] = value
      #retrieve a value
    else
      self[method_name]
    end
  end

  #retrieve all settings as a hash
  def self.all
    vars = find(:all, :select => 'var, value')

    result = {}
    vars.select{|v| v.var.include?(RAILS_ENV)}.each do |record|
      result[record.var.gsub("#{RAILS_ENV}_", "")] = record.value
    end

    #we reverse_merge (the original is more important) result with get_defaults (we need to stringify keys to reverse_merge work properly),
    #and in the end we do not care if hash is accessed either thru string or symbol
    result.reverse_merge(get_defaults.stringify_keys).with_indifferent_access
  end

  def self.destroy(var_name)
    var_name = for_environment(var_name)
    if self[var_name]
      object(var_name).destroy
      true
    else
      raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
    end
  end

  def self.get_defaults
    Rails.cache.fetch("SettingsDefaults") do
      return {} unless File.exist?(DEFAULTS_PATH)
      load DEFAULTS_PATH
      SettingsDefaults::DEFAULTS
    end
  end


  def self.for_environment(str)
    "#{RAILS_ENV}_#{str}"
  end

  def self.update_setting(k, v)
    arr = k.split('_')
    var_type = arr.last
    var_name = arr[0..-2]*'_'
    value = format_value(v, var_type)
    self[var_name] = value
  end


  def self.format_value(val, format)
    return case format
      when "String" then
        val.to_s
      when "Float" then
        val.to_f
      when "Fixnum" then
        val.to_i
      when "Boolean" then
        TRUE_VALUES.include?(val)
    end
  end


  # -----------------------------------------------------
  # --------------- { GETTERS / SETTERS } ---------------
  # -----------------------------------------------------

  #retrieve a setting value by [] notation
  def self.[](var_name)
    get_defaults unless const_defined?("DEFAULTS")
    return object_value(var_name) unless object_value(var_name).nil?
    return defaults_value(var_name) || nil
  end

  #set a setting value by [] notation
  def self.[]=(var_name, value)
    var_name = for_environment(var_name)
    record = object(var_name) || Settings.new(:var => var_name)
    record.value = value
    record.save
  end

  def value
    YAML::load(self[:value])
  end

  #set the value field, YAML encoded
  def value=(new_value)
    self[:value] = new_value.to_yaml
  end

  def self.object_value(var_name)
    (var = object(for_environment(var_name))) ? var.value : nil
  end

  private

  def self.defaults_value(var_name)
    get_defaults[var_name.to_sym]
  end

  #retrieve the actual Setting record
  def self.object(var_name)
    Settings.find_by_var(var_name.to_s)
  end
end