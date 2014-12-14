class Show < ActiveRecord::Base
  has_many :actors
  has_many :episodes
end
