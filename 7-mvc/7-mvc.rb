require 'rack/handler/puma'
require 'rack'
require 'active_record'
require 'pry'
require 'action_controller'
require 'action_dispatch'

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "secrets.sqlite3")

class CreateSecretTable < ActiveRecord::Migration[7.1]
  def up
    create_table :secrets do |t|
      t.string :pen_name
      t.string :secret

      t.timestamps
    end
  end
end

CreateSecretTable.new.migrate(:up) unless ActiveRecord::Base.connection.table_exists?('secrets')

# create AR model for secret
class Secret < ActiveRecord::Base
  validates :pen_name, presence: true
  validates :secret, presence: true
end

# Seed data
if Secret.all.blank?
  Secret.create(pen_name: 'xXx_SW4G_xXx', secret: 'I have a crush on my college course mate')
  Secret.create(pen_name: 'confused_me', secret: "I don't know what I am doing in life")
  Secret.create(pen_name: 'H4CKER', secret: 'I want to hack a bank but idk how')
end

# This is to ensure ActionController reads views from root
ActionController::Base.prepend_view_path('.')

router = ActionDispatch::Routing::RouteSet.new

router.draw do
  resources :secrets, only: [:index, :create]

  match '*path', via: :all, to: 'secrets#all_paths'
end

class SecretsController < ActionController::Base
  def index
    @secrets = Secret.all
  end
  
  def create
    Secret.create(pen_name: params['pen-name'], secret: params['secret'])
    redirect_to '/secrets'
  end

  def all_paths
    render(plain: "✅ Received a #{request.request_method} request to #{request.path}!")
  end
end
# binding.pry

Rack::Handler::Puma.run(router, Port: 1337, Verbose: true)