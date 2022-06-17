require "bundler/setup"
Bundler.require
require "sinatra/reloader" if development?
require "open-uri"
require "sinatra/json"
require "./models/contribution.rb"
require "./models/user.rb"

enable :sessions

before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV["CLOUD_NAME"]
    config.api_key = ENV["CLOUDINARY_API_KEY"]
    config.api_secret = ENV["CLOUDINARY_API_SECRET"]
  end
end

# ここからログイン
get "/login" do
  erb :login
end
  
get '/signin' do
  erb :sign_in
end

get '/signup' do
  erb :sign_up
end

post '/signin' do
  user = User.find_by(mail: params[:mail])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end
  
post '/signup' do
  user = User.create(mail: params[:mail], password: params[:password],
                      password_confirmation: params[:password_confirmation])
  if user.persisted?
    session[:user] = user.id
  end
  redirect '/'
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end
# ここまでログイン


get "/" do
  if session[:user].nil?
        redirect "/login"
  end
  @contents = Contribution.all.order("id desc")
  if params[:keyword]
    # keyword = params[:keyword]
    # contributions = Contribution.arel_table
    # @contents = contributions.where(contributions[:bike_type].matches('%' + keyword + '%'))
    # @contents = Contribution.where('bike_type like ?','%' + keyword + '%')
    if params[:keyword]
      f = '%' + params[:keyword] + '%'
      bike_table = Contribution.arel_table
      @contents = Contribution.where((bike_table[:bike_type].matches(f)).or(bike_table[:model_year].matches(f)))
    end
  end
  erb :index
end

get "/post" do
  erb :post
end

get "/view/:id" do
  @content = Contribution.find(params[:id])
  erb :view
end

post "/new" do
  img_url = ""
  if params[:file]
    img = params[:file]
    tempfile = img[:tempfile]
    upload = Cloudinary::Uploader.upload(tempfile.path)
    img_url = upload["url"]
  end

  Contribution.create({
    bike_type: params[:bike_type],
    model_year: params[:model_year],
    bike_img: img_url,
    custom_part: params[:custom_part],
    custom_brand: params[:custom_brand],
    custom_url: params[:custom_url],
    my_favo: params[:my_favo],
  })

  redirect "/"
end

post "/good/:id" do
  content = Contribution.find(params[:id])
  good = content.good
  content.update({
    good: good + 1,
  })
  
  content.good.to_s
end


post "/renew/:id" do
  content = Contribution.find(params[:id])
  content.update({
    name: params[:user_name],
    body: params[:body],
  })
  redirect "/"
end
