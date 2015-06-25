class Core::DataStoresController < ApplicationController

  before_action :sudo_project_member!, only: [:new, :upload, :update, :destroy]
  before_action :sudo_public!, only: [:index, :show, :index_all, :csv]
  before_action :set_token, only: [:show, :destroy,:csv]
 #------------------------------------------------------------------------------------------------------------------
  # CRUD

  def new
    @data_store = Core::DataStore.new
    @data_store_pull = Core::DataStorePull.new
  end

  def upload
    if !params[:core_data_store]
      @data_store = Core::DataStore.new
      @data_store_pull = Core::DataStorePull.new
      flash.now.alert("Please upload file.")
      render :new
    else
      r = Core::DataStore.upload_tmp_file(params[:core_data_store][:file])
      if r[1].present?
        alert_message = r[1]
      else
        @data_store = Core::DataStore.upload_or_create_file(r[0].file.path, r[0].filename, @core_project.id, params[:first_row_header] ? true : false, r[2], @alknfalkfnalkfnadlfkna)
      end
      if @data_store
        begin
          Nestful.get REST_API_ENDPOINT + "#{@account.slug}/#{@core_project.slug}/#{@data_store.slug}/grid/analyse_datatypes", {:token => @alknfalkfnalkfnadlfkna}, :format => :json
        rescue
        end
        redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store), notice: t("c.s")
      else
        @validator = Csvlint::Validator.new( File.new(r[0].file.path), {"header" => params[:first_row_header], "delimiter" => r[2]} )
        @data_store = Core::DataStore.new
        @data_store_pull = Core::DataStorePull.new
        flash.now[:alert] = alert_message || "Failed to upload"
        render :new
      end
    end
  end

  def destroy
    is_deletable = @data_store.check_dependent_destroy?
    if is_deletable[:is_deletable]
      begin
        Nestful.post REST_API_ENDPOINT + "#{@account.slug}/#{@core_project.slug}/#{@data_store.slug}/grid/delete", {:token => @alknfalkfnalkfnadlfkna}, :format => :json
        if @data_store.cdn_published_url.present? #PUBLISH TO CDN Functionality
          @data_store.update_attributes(marked_to_be_deleted: "true")
          Core::S3File::DestroyWorker.perform_async("DataStore", @data_store.id)
          notice = t("d.m")
        else
          @data_store.destroy
          notice = t("d.s")
        end
        redirect_to _account_project_path(@core_project.account, @core_project), notice: notice
      rescue => e
        redirect_to _account_project_path(@core_project.account, @core_project), alert: e.to_s
      end
    else
      redirect_to _account_project_path(@core_project.account, @core_project,d: is_deletable[:dependent_to_destroy],d_id: @data_store.id)
    end
  end

  #------------------------------------------------------------------------------------------------------------------
  # OTHER

  def csv
    s = "/tmp/#{SecureRandom.hex(24)}.csv"
    @data_store.generate_file_in_tmp(s,@alknfalkfnalkfnadlfkna)
    send_data IO.read(s), :type => "application/vnd.ms-excel", :filename => "#{@data_store.slug}.csv", :stream => false
    File.delete(s)
  end
  #------------------------------------------------------------------------------------------------------------------

  private

  def set_token
    @alknfalkfnalkfnadlfkna = @account.core_tokens.where(core_project_id: @core_project.id).first.api_token
    gon.token = @alknfalkfnalkfnadlfkna
  end

  def set_data_store
    if params[:data_id].present?
      @data_store = @core_project.data_stores.friendly.find(params[:data_id])
    else
      @data_store = @core_project.data_stores.friendly.find(params[:id])
    end
    @core_projects = current_account.core_projects.where("id <> ?", @data_store.core_project_id)  if current_account.present?
    @parent = @data_store.clone_parent  if @data_store.clone_parent_id.present?
  end

  def core_data_store_params
    params.require(:core_data_store).permit(:core_project_id, :name, :table_name, :account_id, :db_connection_id)
  end

end
