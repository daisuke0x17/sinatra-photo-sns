ActiveRecord::Base.establish_connection
class Contribution < ActiveRecord::Base
    has_many :customs
    belongs_to :user
end

class Custom < ActiveRecord::Base
    belongs_to :contribution
end