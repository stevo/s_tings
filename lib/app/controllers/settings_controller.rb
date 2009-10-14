class SettingsController < ApplicationController
  unloadable

  def index
    @settings = Dictionary[*Settings.all.sort.flatten]
  end

  def update_all
    params[:setting_values].each{|k, v|Settings.update_setting(k, v)}
    flash[:notice] = "Settings saved"
    redirect_to settings_path
  end

  def destroy
    Settings[params[:id]] = Settings::get_defaults[params[:id].to_sym]
    redirect_to settings_path
  end
end