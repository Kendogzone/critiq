class Product < ActiveRecord::Base
	belongs_to :user, :foreign_key => "user_id"
  validates :name, presence: true
  validates :description, presence: true
  has_many :likes, :as => :likeable
	has_many :feature_groups
  has_many :bounties
  has_many :comments, :as => :commentable, dependent: :destroy
	has_one :product_pic, class_name: "ImageAsset", foreign_key: "attachable_id", :as => :attachable, :autosave => true
  accepts_nested_attributes_for :product_pic, :allow_destroy => true
	has_many :pictures, class_name: "ImageAsset", foreign_key: "attachable_id", :as => :attachable, :autosave => true
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  accepts_nested_attributes_for :feature_groups, :allow_destroy => true
  accepts_nested_attributes_for :comments, :allow_destroy => true
  attr_accessible :name, :description, :rating, :likes, :pictures, :active, :pictures_attributes, :product_pic, :product_pic_attricbutes, :feature_groups, likes: [:product_id, :user_id]
  after_update :save_everything

  def liked?(id, type)
    if get_likes(id, type).length > 0
      return true
    end
    return false
  end

  def profile_pic
    if !self.product_pic.nil? and !self.product_pic.attachment.nil?
      return self.product_pic
    elsif !self.pictures.last.nil? and !self.pictures.last.attachment.nil?
      return self.pictures.last 
    elsif !self.pictures.first.nil? and !self.pictures.first.attachment.nil?
      return self.pictures.first
    else
      return nil  
    end
  end

  private

    def get_likes(id, type)
      return Likes.where(:user_id => self.id, :likeable_type => type, :likeable_id => id)
    end

    def save_everything
    	self.product_pic = self.pictures.last
      self.product_pic.save
      self.pictures.each do |asset| 
      	asset.product_id = self.id
        asset.save!
      end 
      self.feature_groups.each do |f|
      	f.product = self
      	f.save!
      end
    end 

    def has_pictures?
    	!self.picture.empty?
    end
end
