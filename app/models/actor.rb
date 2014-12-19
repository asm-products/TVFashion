class Actor < ActiveRecord::Base
  belongs_to :show
  has_many :outfits
end
