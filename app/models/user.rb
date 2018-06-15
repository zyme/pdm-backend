# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :profiles
  validates :first_name, :last_name, presence: true
  # def after_create
  #    Profile.new({name: first_name + " " + last_name,
  #                first_name: first_name,
  #                last_name: last_name,
  #                user_id: id}).save
  # end
end
