class Show < ActiveRecord::Base
  has_many :actors, dependent: :destroy
  has_many :episodes, dependent: :destroy
end
