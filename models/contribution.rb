ActiveRecord::Base.establish_connection
class Contribution < ActiveRecord::Base
    has_many :customs
end

class Custom < ActiveRecord::Base
    belongs_to :contribution
end