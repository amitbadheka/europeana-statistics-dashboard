require 'rails_helper'

RSpec.describe DatacastsHelper, type: :helper do

  describe 'generate datacast status html indicator', type: :helper do
    it 'should return a html string with class signal sig-green' do
      datacast = Core::Datacast.first
      indicator = signal_datacast_status(datacast)
      expect(indicator).to eq("<div class='signal sig-green'></div>")
    end
  end
end