require "sinatra/base"
require "rack-flash"
require "feature"
require "feature/dashboard/helpers"

module Feature
  class Dashboard < Sinatra::Base

    dir = File.dirname(File.expand_path(__FILE__))

    set(:views, "#{dir}/dashboard/views")
    set(:public_folder, "#{dir}/dashboard/public")

    enable(:sessions)
    use(Rack::Flash)

    before do
      @features = ::Feature.features
    end

    # Features

    get "/" do
      erb(:index)
    end

    post "/:id/enable" do
      id = params[:id].to_sym
      flash.now[:notice] = "#{id} enabled" if Feature(id).enable
      erb :index
    end

    post "/:id/disable" do
      id = params[:id].to_sym
      flash.now[:notice] = "#{id} disabled" if Feature(id).disable
      erb(:index)
    end

    # Groups

    get "/group/:id" do
      set_group_variables
      erb(:group)
    end

    post "/group/:id/members" do
      set_group_variables
      member = params[:member]

      if member.length == 0
        flash[:error] = "No member ID"
        return redirect to("/group/#{@group}")
      end

      if ::Feature.add_to_group(@group, member)
        flash[:notice] = "#{member} added"
      end
      redirect to("/group/#{@group}")
    end

    post "/group/:id/member/:member/destroy" do
      set_group
      member = params[:member]

      if ::Feature.remove_from_group(@group, member)
        flash[:notice] = "#{member} removed"
      end
      redirect to("/group/#{@group}")
    end

    private

    def set_group_variables
      @group = params[:id].to_sym
      @title = "group / #{@group}"
      @members = ::Feature.get_group_members(@group)
    end
  end
end