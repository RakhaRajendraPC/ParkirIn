import { Venue, ParkingLot, User, Booking } from "../types";

export const mockUser: User = {
  id: "u-1",
  name: "Dzacky",
  email: "dzacky@example.com",
  phone: "081234567890",
  avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Dzacky",
  vehicles: [
    {
      id: "v-1",
      plateNumber: "B 1234 ABC",
      type: "CAR",
      color: "Hitam",
      isDefault: true,
    },
  ],
};

export const mockVenues: Venue[] = [
  {
    id: "v-1",
    name: "Paris Van Java",
    address: "Jl. Sukajadi No.131-139, Bandung",
    type: "MALL",
    image: "https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?q=80&w=800&auto=format&fit=crop",
    rating: 4.8,
    distance: "2.5 km",
    basePrice: 15000,
    premiumModifier: 10000,
    facilities: ["Covered Parking", "CCTV", "Security", "Valet"],
    operatingHours: "10:00 - 22:00",
  },
  {
    id: "v-2",
    name: "Trans Studio Mall",
    address: "Jl. Gatot Subroto No.289, Bandung",
    type: "MALL",
    image: "https://images.unsplash.com/photo-1555529771-835f59bfc50c?q=80&w=800&auto=format&fit=crop",
    rating: 4.7,
    distance: "5.1 km",
    basePrice: 15000,
    premiumModifier: 15000,
    facilities: ["Covered Parking", "CCTV", "Charging Station"],
    operatingHours: "10:00 - 22:00",
  },
  {
    id: "v-3",
    name: "Bandara Internasional",
    address: "Parkir Inap Terminal 3",
    type: "AIRPORT",
    image: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?q=80&w=800&auto=format&fit=crop",
    rating: 4.9,
    distance: "12 km",
    basePrice: 50000,
    premiumModifier: 20000,
    facilities: ["24/7 Security", "Shuttle Bus", "Covered Parking"],
    operatingHours: "24 Jam",
  },
  {
    id: "v-4",
    name: "Mall Kota Bandung",
    address: "Pusat Kota",
    type: "MALL",
    image: "https://images.unsplash.com/photo-1567684014761-b65e2e59b9eb?q=80&w=800&auto=format&fit=crop",
    rating: 4.5,
    distance: "1.2 km",
    basePrice: 10000,
    premiumModifier: 5000,
    facilities: ["CCTV", "Security"],
    operatingHours: "10:00 - 21:00",
  },
];

// Helper to generate lots
const generateLots = (venueId: string, rows: string[], countPerRow: number) => {
  const lots: ParkingLot[] = [];
  rows.forEach((row) => {
    for (let i = 1; i <= countPerRow; i++) {
      const num = i.toString().padStart(2, "0");
      // Randomly assign some statuses
      const rand = Math.random();
      const status = rand > 0.8 ? "OCCUPIED" : rand > 0.6 ? "RESERVED" : "AVAILABLE";
      // Randomly assign some premium
      const type = rand < 0.2 ? "PREMIUM" : "STANDARD";
      
      lots.push({
        id: `lot-${venueId}-${row}${num}`,
        venueId,
        name: `${row}-${num}`,
        status,
        type,
        location: row === "A" ? "Dekat Lobby Utama" : "Standard Area",
      });
    }
  });
  return lots;
};

export const mockLots: ParkingLot[] = [
  ...generateLots("v-1", ["A", "B", "C"], 20),
  ...generateLots("v-2", ["A", "B"], 20),
  ...generateLots("v-3", ["A", "B", "C", "D"], 20),
  ...generateLots("v-4", ["A", "B", "C"], 15),
];

const airportActiveLots = mockLots.filter((lot) => lot.venueId === "v-3" && ["OCCUPIED", "RESERVED"].includes(lot.status));
const bookingTimes = ["08:00", "09:30", "11:00", "13:00", "15:30", "18:00"];

export const mockBookings: Booking[] = airportActiveLots.map((lot, index) => {
  const user = [mockUser, { ...mockUser, id: "u-2" }, { ...mockUser, id: "u-3" }, { ...mockUser, id: "u-4" }][index % 4];
  const vehicle = user.vehicles[0];
  const [hour, minute] = bookingTimes[index % bookingTimes.length].split(":").map(Number);
  const entry = new Date();
  entry.setHours(hour, minute, 0, 0);
  const durationHours = 2 + (index % 5);
  const plannedExit = new Date(entry.getTime() + durationHours * 60 * 60 * 1000);
  return {
    id: `BK-DEMO-${String(index + 1).padStart(3, "0")}`,
    userId: user.id,
    venueId: "v-3",
    lotId: lot.id,
    vehicleId: vehicle.id,
    status: lot.status === "OCCUPIED" ? "CHECK_IN" : "DIPESAN",
    bookingTime: entry.toISOString(),
    checkInTime: lot.status === "OCCUPIED" ? entry.toISOString() : undefined,
    plannedExitTime: plannedExit.toISOString(),
    durationHours,
    payment: { method: "QRIS", amount: 50000, status: "SUCCESS", timestamp: entry.toISOString() },
    qrCode: `parkirin-demo-${index + 1}`,
    totalPrice: durationHours * 50000,
  };
});
