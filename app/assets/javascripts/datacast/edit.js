Rumali.initDataCastGrid = function (){
  Rumali.plugin = new Rumali.plugins();
  config_data.data = gon.preview_data;
  $("#preview_output_grid").handsontable(config_data);
}