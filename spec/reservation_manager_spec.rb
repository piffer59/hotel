require_relative "spec_helper"

require "awesome_print"
require "date"
require "minitest/skip_dsl"

describe "manager" do
  let (:manager) {
    Hotel::ReservationManager.new
  }
  let (:block1) {
    manager.make_block(5, "march 19, 2019", "march 23, 2019", 1)
  }
  let (:reservation1) {
    manager.make_reservation("march 15, 2019", "march 20, 2019")
  }
  let (:reservation2) {
    manager.make_reservation("march 17, 2019", "march 22, 2019")
  }
  let (:block2) {
    manager.make_block(4, "march 21, 2019", "march 25, 2019", 2)
  }

  describe "Reservation_manager instantiation" do
    it "is an instance of Reservation Manager" do
      expect(manager).must_be_kind_of Hotel::ReservationManager
    end
  end

  describe "all_rooms method" do
    it "can list all rooms in the hotel" do
      expect(manager.all_rooms.length).must_equal 20
    end
  end

  describe "make_reservation method" do
    it "can make a new reservation" do
      expect(reservation1.length).must_equal 1
      expect(reservation1[0].status).must_equal "reserved"
    end

    it "raises an ArgumentError when there are no available rooms" do
      expect {
        (Hotel::ReservationManager::MAX_ROOMS + 1).times do
          manager.make_reservation("march 15, 2019", "march 20, 2019")
        end
      }.must_raise ArgumentError
    end
  end

  describe "reservations_by_date method" do
    it "can list all the reservations for a specified date range" do
      #clarify dee's comments about writing these reservations out or using a helper method
      reservation1
      reservation2
      start_date = "march 14, 2019"
      end_date = "march 16, 2019"
      list_reservations = manager.reservations_by_date(start_date, end_date)

      expect(list_reservations.length).must_equal 1
    end

    it "returns an empty array when there are no reservations for a specified date range" do
      reservation1
      reservation2
      start_date = "April 1, 2019"
      end_date = "April 7, 2019"
      list_reservations = manager.reservations_by_date(start_date, end_date)
      expect(list_reservations).must_be_empty
    end
  end

  describe "available_rooms method" do
    it "can return available rooms for a specified date range, end_date overlap" do
      reservation1
      reservation2
      block1
      block2
      start_date = "march 14, 2019"
      end_date = "march 20, 2019"
      vacant_rooms = manager.available_rooms(start_date, end_date)
      expect(vacant_rooms.length).must_equal 13
    end

    it "can return available rooms for a specified date range, full range unavail" do
      reservation1
      reservation2
      block1

      start_date = "march 17, 2019"
      end_date = "march 20, 2019"
      vacant_rooms = manager.available_rooms(start_date, end_date)
      expect(vacant_rooms.length).must_equal 13
    end

    it "can return available rooms for a specified date range, start_date unavail" do
      reservation1
      reservation2
      block1
      block2

      start_date = "march 20, 2019"
      end_date = "march 25, 2019"
      vacant_rooms = manager.available_rooms(start_date, end_date)
      expect(vacant_rooms.length).must_equal 10
    end

    it "can return an empty array when no rooms are available for a specified date range" do
      Hotel::ReservationManager::MAX_ROOMS.times do
        manager.make_reservation("march 15, 2019", "march 20, 2019")
      end

      start_date = "march 15, 2019"
      end_date = "march 16, 2019"
      vacant_rooms = manager.available_rooms(start_date, end_date)
      expect(vacant_rooms).must_be_empty
    end

    it "includes all rooms if no reservations" do
      start_date = "march 14, 2019"
      end_date = "march 16, 2019"
      vacant_rooms = manager.available_rooms(start_date, end_date)
      expect(vacant_rooms.length).must_equal 20
    end

    it "does not include the booked rooms" do
      reservation1
      reservation2
      start_date = "march 14, 2019"
      end_date = "march 16, 2019"
      vacant_rooms = manager.available_rooms(start_date, end_date)
      expect(vacant_rooms.length).must_equal 19
    end
  end

  describe "make_block method" do
    it "Can reserve a block of 5 rooms from available rooms" do
      reservation1
      reservation2
      new_block = manager.make_block(5, "march 15, 2019", "march 20, 2019", 1)
      vacant_rooms = manager.available_rooms("march 15, 2019", "march 20, 2019")

      block = new_block.select { |room| room.status == "blocked" }

      expect(block.length).must_equal 5
      expect(vacant_rooms.length).must_equal 13
    end

    it "Will not show blocked rooms as available" do
      reservation1
      reservation2
      manager.make_block(4, "march 19, 2019", "march 23, 2019", 1)

      vacant_rooms = manager.available_rooms("march 19, 2019", "march 20, 2019")
      expect(vacant_rooms.length).must_equal 14
    end

    it "Raises and argument error for room blocks with more than 5 rooms" do
      expect { manager.make_block(6, "march 19, 2019", "march 23, 2019", 1) }.must_raise ArgumentError
    end
  end

  describe "check_block_availability method" do
    it "Will show rooms still available in a specified block" do
      block1
      block2
      id = 1
      avail_rooms = manager.check_block_availability(id)
      expect(avail_rooms.length).must_equal 5
    end

    it "Will not show rooms that have been turned into reservations" do
      block1
      id = 1
      reserved_room = manager.reserve_block_room(id)
      avail_rooms = manager.check_block_availability(id)
      expect(avail_rooms.length).must_equal 4
    end
  end

  describe "reserve_block_room method" do
    it "can reserve a room in a specified block by changing the room's status from 'blocked' to 'reserved'" do
      block1
      expect(block1.length).must_equal 5

      id = 1
      manager.reserve_block_room(id)
      expect(block1[0].status).must_equal "reserved"
    end
  end
end
