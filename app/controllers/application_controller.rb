class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :detect_domain, :set_universal_objects, :set_current_user_to_session
  before_action :configure_devise_params, if: :devise_controller?
  before_filter :log_session
  after_filter  :after_filter_set
  include ERB::Util

  #------------------------------------------------------------------------------------------------------------------

  private

  def detect_domain
    @is_not_rumi = (request.domain != "localhost" and request.domain != "rumi.io")
  end

  def set_current_user_to_session
    Thread.current[:i] = current_account.id if current_account.present?
  end

  # LOCKING this method. Do not change.
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  def set_universal_objects
    if params[:account_id].present?
      begin
        @account = Account.friendly.find(h params[:account_id])
        begin
          if controller_name == "projects" and params[:id].present?
            @core_project = @account.core_projects.where(account_id: @account.id, slug:"#{h params[:id]}").first
            raise "no project found" if @core_project.nil?
          elsif params[:project_id].present?
            @core_project = @account.core_projects.where(account_id: @account.id, slug:"#{h params[:project_id]}").first
            raise "no project found" if @core_project.nil?
          elsif params[:core_project_id].present?
            @core_project = @account.core_projects.where(account_id: @account.id, slug:"#{h params[:core_project_id]}").first
            raise "no project found" if @core_project.nil?
          end
        rescue
          redirect_to root_url, alert: t("set_universal_objects.no_such_project")
        end
      rescue
        redirect_to root_url, alert: t("set_universal_objects.no_such_account_1")
      end
    elsif (controller_name == "accounts" or controller_name == "params") and params[:id].present?
      begin
        @account = Account.friendly.find("#{h params[:id]}")
      rescue
        redirect_to root_url, alert: t("set_universal_objects.no_such_account_2")
      end
    end
    if @account.blank?
      @account = current_account  if controller_name == "projects" and action_name == "new"
    end
    gon.scopejs = "scopejs_#{controller_name}_#{action_name}"
    @about_report = Impl::Report.where(slug: "about").first
    @is_beta = true
  end

  # LOCKING this method. Do not change.
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  def sudo_account!
    authenticate_account!
  end

  # LOCKING this method. Do not change.
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  def sudo_organisation_owner!
    authenticate_account!
    redirect_to root_url, alert: t("pd.sudo_organisation_owner!") if current_account.sudo_organisation_owner(@account)
    @sudo = Constants::SUDO_111
  end

  # LOCKING this method. Do not change.
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  def sudo_project_member!(redirect_to_show = false)
    authenticate_account! unless redirect_to_show
    if @core_project.present?
      @sudo = current_account.sudo_project_member(@core_project.account, @core_project.id) if current_account.present?
      redirect_to root_url, alert: t("pd.sudo_project_member!") if @sudo.blank? and !redirect_to_show
    end
  end

  # LOCKING this method. Do not change.
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  def sudo_project_owner!
    authenticate_account!
    if @core_project.present?
      redirect_to root_url, alert: t("pd.sudo_project_owner!")  if current_account.sudo_project_owner(@core_project.id)
      @sudo = Constants::SUDO_111
    end
  end

  # LOCKING this method. Do not change.
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  def sudo_admin!
    authenticate_account!
    redirect_to root_url, alert: t("pd.sudo_admin!") if !current_account.is_admin?
    @sudo = Constants::SUDO_111
  end

  # LOCKING this method. Do not change.
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  def sudo_public!
    if @core_project.present?
      @sudo = nil
      @sudo = current_account.sudo_project_member(@core_project.account, @core_project.id)    if account_signed_in?
      if @sudo.blank?
        if !@core_project.is_public and action_name != "embed"
          redirect_to root_url, alert: t("pd.sudo_public!")
        else
          @sudo = Constants::SUDO_001
        end
      end
    else
      @sudo = Constants::SUDO_001
    end
  end

  #------------------------------------------------------------------------------------------------------------------

  def set_ref_plan_tokens
    true
  end

  #------------------------------------------------------------------------------------------------------------------

  protected

  def log_session
    if controller_name == "vizs" and (action_name == "embed" or action_name == "show")
      session_id = session.present? ? session.id : nil
      account_id = current_account.present? ? current_account.id : nil
      Thread.current[:s] = Core::SessionImpl.log_viz(session_id, account_id , request.env["REMOTE_ADDR"].to_s, request.env["HTTP_USER_AGENT"].to_s,params[:id])
    elsif current_account.present?
      Thread.current[:s] = Core::SessionImpl.log(session.id, current_account.id, request.env["REMOTE_ADDR"].to_s, request.env["HTTP_USER_AGENT"].to_s)
    end
  end

  # Enable DEVISE forms to accept username.
  def configure_devise_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:username, :email, :password)}
    devise_parameter_sanitizer.for(:sign_in) {|u| u.permit(:username, :password)}
    devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:password, :current_password, :password_confirmation)}
  end

  #------------------------------------------------------------------------------------------------------------------

  private

  # LOCKING this method. Do not change.
  # Module: Access-Control
  # Author: Ritvvij Parrikh

  def after_sign_in_path_for(resource)
    _account_project_path(resource, resource.core_projects.first)
  end

  def after_filter_set
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end

end
