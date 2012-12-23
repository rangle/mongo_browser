require "grape"

class MongoBrowser::Application
  class Api < Grape::API
    format :json

    include MongoBrowser::Models

    helpers do
      def server
        @server ||= Server.current
      end
    end

    resource :databases do
      desc "Get a list of all databases for the current server"
      get do
        server.databases.map do |db|
          {
              id:    db.id,
              name:  db.name,
              size:  db.size,
              count: db.count
          }
        end
      end

      segment "/:db_name" do
        params do
          requires :db_name, :type => String, :desc => "Database name."
        end

        desc "Deletes a database with the given name"
        delete do
          database = server.database(params[:db_name])
          database.drop!
          { success: true }
        end

        desc "Get stats for the given database"
        get "/stats" do
          database = server.database(params[:db_name])
          database.stats
        end

        resources :collections do
          desc "Get a list of all collections for the given database"
          get do
            database = server.database(params[:db_name])
            database.collections.map do |collection|
              {
                  dbName: collection.db_name,
                  name:   collection.name,
                  size:   collection.size
              }
            end
          end

          segment "/:collection_name" do
            params do
              requires :collection_name, :type => String, :desc => "Collection name."
            end

            desc "Get stats for a collection with the given name"
            get "/stats" do
              collection = server.database(params[:db_name]).collection(params[:collection_name])
              collection.stats
            end

            desc "Drop a collection with the given name"
            delete do
              collection = server.database(params[:db_name]).collection(params[:collection_name])
              collection.drop!
              { success: true }
            end

            resources :documents do
              get do
                collection = server.database(params[:db_name]).collection(params[:collection_name])
                documents, pagination = collection.documents_with_pagination(params[:page])

                documents.map! do |doc|
                  {
                      id: doc.id.to_s,
                      data: doc.data
                  }
                end

                {
                    documents:  documents,
                    size:       pagination.size,
                    page:       pagination.current_page,
                    totalPages: pagination.total_pages
                }
              end

              segment "/:id" do
                params do
                  requires :id, :type => String, :desc => "Document id."
                end

                delete do
                  collection = server.database(params[:db_name]).collection(params[:collection_name])
                  document = collection.find(params[:id])
                  collection.remove!(document)
                  { success: true }
                end
              end
            end
          end
        end
      end
    end

    desc "Returns info about the server"
    get "/server_info" do
      server.info
    end

    desc "Returns application version"
    get "/version" do
      {
          version: MongoBrowser::VERSION,
          environment: ENV["RACK_ENV"]
      }
    end
  end
end
