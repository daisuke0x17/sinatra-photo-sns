require "bundler/setup"
Bundler.require
require "sinatra/reloader" if development?
require "open-uri"
require "sinatra/json"
require "./models/contribution.rb"

before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV["CLOUD_NAME"]
    config.api_key = ENV["CLOUDINARY_API_KEY"]
    config.api_secret = ENV["CLOUDINARY_API_SECRET"]
  end
end

get "/" do
  @contents = Contribution.all.order("id desc")
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
  redirect "/"
end


post "/renew/:id" do
  content = Contribution.find(params[:id])
  content.update({
    name: params[:user_name],
    body: params[:body],
  })
  redirect "/"
end
