#grab env specific node config from yaml
node_hash = YAML.load(File.read('./config/node.yml'))[Rails.env]
#symbolize the keys
node_hash = node_hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
#assign to rails config
Rails.application.config.node = node_hash