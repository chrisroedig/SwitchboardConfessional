class Call < ActiveRecord::Base
  attr_accessible :rec_length, :rec_url
  belongs_to :caller
end
