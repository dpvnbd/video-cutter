# README

## Development dependencies
* ruby 2.6.1
* postgres 11
* ffmpeg 
### Generating docs:
`rake rswag:specs:swaggerize`
visit http://localhost:3000/api/docs

## Running in docker
* create .env file from example, add master key
* build and run containers: 
`docker-compose up`
* create and migrate production db and test db (for documentation generator)
`docker exec -it vc_web rails db:create RAILS_ENV=production`
`docker exec -it vc_web rails db:create RAILS_ENV=test`
`docker exec -it vc_web rails db:migrate RAILS_ENV=production`
`docker exec -it vc_web rails db:migrate RAILS_ENV=test`
`docker exec -it vc_web rake rswag:specs:swaggerize RAILS_ENV=test`
visit http://localhost:3000/api/docs
