module MongoBrowser
  class Application < Sinatra::Base
    set :root, File.join(File.dirname(__FILE__), "../../app")

    set :mongodb_host, ENV['MONGODB_HOST'] || 'localhost'
    set :mongodb_port, ENV['MONGODB_PORT'] || 27017

    use MongoBrowser::SprocketsSinatraMiddleware, :root => settings.root, :path => "assets"

    get "/" do
      @databases = connection.database_info
      erb :"index"
    end

    get "/databases/:db_name" do
      database = connection.db(params[:db_name])
      @collections = database.collections
      @stats = database.stats

      erb :"databases/show"
    end

    get "/databases/:db_name/collections/:collection_name" do
      database = connection.db(params[:db_name])
      collection = database.collection(params[:collection_name])
      @documents = collection.find()
      @stats = collection.stats

      erb :"collections/show"
    end

    get "/server_info" do
      @server_info = connection.server_info
      erb :"server_info"
    end

    private

    def connection
      @connection ||= Mongo::Connection.new(settings.mongodb_host, settings.mongodb_port)
    end
  end
end
