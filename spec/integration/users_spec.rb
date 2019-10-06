require 'swagger_helper'

RSpec.describe 'Users' do
  path '/users' do
    post 'Creates a user' do
      tags 'Users'
      security []

      response '201', 'user created' do
        run_test!
      end
    end
  end
end