# README

## Development dependencies
* ruby 2.6.1
* postgres 11
* ffmpeg 4
### Generating docs:

`rake rswag:specs:swaggerize`

visit http://localhost:3000/api/docs

## Running in docker
* create .env file from example, add master key to it
* build and run containers: 

    `docker-compose up`
    
    To run it in background:
    
    `docker-compose up -d`
* create and migrate production db and test db (for documentation generator)
    
    `docker exec -it vc_web rails db:create RAILS_ENV=production`
    
    `docker exec -it vc_web rails db:create`
    
    `docker exec -it vc_web rails db:migrate RAILS_ENV=production`
    
    `docker exec -it vc_web rails db:migrate`
* run specs

    `docker exec -it vc_web rspec`
* generate the docs

    `docker exec -it vc_web rake rswag:specs:swaggerize RAILS_ENV=test`

* visit http://localhost:3000/api/docs
* stop containers:

    `docker-compose down`

You can use the API in Swagger UI through "Try it out" button:
* create a user
* copy api_key from response and paste it in the "Authorize" window
* upload a video specifying the file and timestamps
* list all uploads or show returned upload by id to check the processing status and output link