# require 'rest-client'
require 'geokit'
module API
  module V1
    class HtcsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :app, desc: '跟APP全局配置相关的接口' do
        desc "获取配置"
        get :configs do
          { code: 0, message: 'ok', data: {  } }
        end # end configs
        
        desc "获取微信JSSDK配置数据"
        params do
          requires :url, type: String, desc: '需要签名的url'
        end
        get :wx_config do
          url = (params[:url].start_with?('http://') or params[:url].start_with?('https://')) ? params[:url] : SiteConfig.send(params[:url])
          json = Wechat::Sign.sign_package(url)
          { code: 0, message: 'ok', data: json }
        end # end get
        
      end # end resource 
      
      resource :shops, desc: "门店相关接口" do
        desc "获取附近的门店"
        params do
          optional :uid, type: String, desc: '会员ID'
          optional :loc, type: String, desc: '经纬度，例如：lng,lat'
        end
        get :nearby do
          @shops = Shop.where(opened: true).order('sort desc')
          if params[:loc].blank?
            loc = client_loc_from_ip
            if loc
              lng,lat = loc
              origin = [lat, lng]
            else
              origin = nil
            end
          else
            loc = params[:loc].split(',')
            if loc.length > 1
              origin = [loc[1], loc[0]]
            else
              origin = nil
            end
          end
          return render_error(4004, '未获取到位置信息') if origin.blank?
          
          @shops = @shops.by_distance(origin: origin)
          render_json(@shops, API::V1::Entities::Shop)
        end # end get nearby
      end # end resource
      
    end
  end
end