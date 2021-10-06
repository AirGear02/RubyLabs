require 'json'

class Car
  attr_accessor :id, :brand, :model, :year, :price, :distance, :location, :was_in_accident, :img_url
  def initialize(id, brand, model, year, price, distance, location, accident, img_url)
    @id              = id
    @brand           = brand
    @model           = model
    @year            = year
    @price           = price
    @distance        = distance
    @location        = location
    @was_in_accident = accident
    @img_url         = img_url
  end

  def as_json(*options)
    {
      :id              => @id,
      :brand           => @brand,
      :model           => @model,
      :year            => @year,
      :price           => @price,
      :distance        => @distance,
      :location        => @location,
      :was_in_accident => @was_in_accident,
      :img_url         => @img_url
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  def values
      [@id, @brand, @model, @year, @price, @distance, @location, @was_in_accident, @img_url]
  end
end