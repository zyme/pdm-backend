class Provider < ApplicationRecord


  belongs_to :parent , foreign_key: :parent_id, class_name: self.name

  validates_presence_of :name, :end_point

end
