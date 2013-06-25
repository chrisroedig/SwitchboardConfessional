#grab env specific redis config from yaml
redis_hash = YAML.load(File.read('./config/redis.yml'))[Rails.env]
#symbolize the keys
redis_hash = redis_hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
#assign to rails config
Rails.application.config.redis = redis_hash

# setup the application-wide redis client
$redis = Redis.new(Rails.application.config.redis)

