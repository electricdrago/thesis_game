class User < ApplicationRecord

  validates :name, presence: true, length: {maximum: 20},
              uniqueness: {case_sensitive: false}
  before_save {self.name = name.downcase}
  has_secure_password
end
