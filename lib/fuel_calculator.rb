# frozen_string_literal: true

class FuelCalculator
  ALLOWED_GRAVITIES = [
    9.807, # Earth
    1.62,  # Moon
    3.711  # Mars
  ].freeze

  ALLOWED_ACTIONS = [
    :launch,
    :land
  ].freeze

  LAUNCH_FUEL_FACTOR = 0.042
  LAUNCH_FUEL_CONSTANT = 33
  LAND_FUEL_FACTOR = 0.033
  LAND_FUEL_CONSTANT = 42

  def initialize(ship_mass, route)
    @ship_mass = ship_mass
    @route = route
  end

  def perform
    current_mass = @ship_mass
    total_fuel = 0

    # Reverse the roiute to calculate fuel requirements in the correct order.
    # e.g. carry the fuel needed to land when you launch
    @route.each do |action, gravity|
      # avoid malformed data, the goal is to build a calculator for Earth, Moon and Mars only
      raise ArgumentError, "Unknown planet with gravity: #{planet}" unless ALLOWED_GRAVITIES.include? gravity
      # avoid unpermited actions
      raise ArgumentError, "Unknown action: #{action}" unless ALLOWED_ACTIONS.include? action

      # Calculate fuel required for the current step
      fuel = if action == :launch
               calculate_fuel(current_mass, gravity, LAUNCH_FUEL_FACTOR, LAUNCH_FUEL_CONSTANT)
             else
               calculate_fuel(current_mass, gravity, LAND_FUEL_FACTOR, LAND_FUEL_CONSTANT)
             end

      # Add current step fuel to the total spaceship mass
      current_mass += fuel
      # Add current step fuel to the total fuel
      total_fuel += fuel
    end

    total_fuel
  end

  private

  def calculate_fuel(mass, gravity, factor, constant)
    # total step fuel
    fuel = 0
    # Fuel adds weight to the ship, so it requires additional fuel until the additional fuel is 0
    # 40 fuel requires no more fuel
    until mass <= 40
      # redefine mass to be the amount of fuel for the next iteration
      mass = (mass * gravity * factor - constant).to_i
      fuel += mass
    end

    fuel
  end
end


puts FuelCalculator.new(28801, [[:launch, 9.807], [:land, 1.62], [:launch, 1.62], [:land, 9.807]]).perform
puts FuelCalculator.new(14606, [[:launch, 9.807], [:land, 3.711], [:launch, 3.711], [:land, 9.807]]).perform
puts FuelCalculator.new(75432, [[:launch, 9.807], [:land, 1.62], [:launch, 1.62], [:land, 3.711], [:launch, 3.711], [:land, 9.807]]).perform