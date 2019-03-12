require_relative "spec_helper"

describe "Reservation instantiation" do
  it "is an instance of Reservation " do
    trip = Reservation.new("Kathy", 5, "dec 15, 2019", "dec 20, 2019")
    expect(trip).must_be_kind_of Reservation
  end

  it "raises an argument error if the checkout date is before the check in date" do
    expect { Reservation.new("Quinn", 5, "dec 20, 2019", "dec 15, 2019") }.must_raise ArgumentError
  end
end

describe "total_cost method" do
  it "Calculates the total cost of the reservation" do
    trip = Reservation.new("Merrick", 5, "dec 15, 2019", "dec 20, 2019")
    expect(trip.reservation_cost).must_equal 1000
  end

  describe "all_rooms method" do
    it "Lists all rooms in the hotel" do
      trip = Reservation.new("Chris", 5, "dec 15, 2019", "dec 20, 2019")
      expect(trip.all_rooms.length).must_equal 20
    end
  end
end