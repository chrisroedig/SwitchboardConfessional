class Caller < ActiveRecord::Base
  attr_accessible :last_call_at, :number
  has_many :calls, :dependent => :destroy
end
