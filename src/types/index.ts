export type Role = "USER" | "PARTNER" | "GATE" | "ADMIN";

export type VehicleType = "CAR" | "MOTORCYCLE";

export interface Vehicle {
  id: string;
  plateNumber: string;
  type: VehicleType;
  color: string;
  isDefault: boolean;
}

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  avatar?: string;
  vehicles: Vehicle[];
  status?: "ACTIVE" | "INACTIVE";
}

export type VenueType = "MALL" | "AIRPORT" | "OFFICE";

export interface Venue {
  id: string;
  name: string;
  address: string;
  type: VenueType;
  image: string;
  rating: number;
  distance: string;
  basePrice: number;
  premiumModifier: number;
  facilities: string[];
  operatingHours: string;
}

export type LotStatus = "AVAILABLE" | "OCCUPIED" | "RESERVED";
export type LotType = "STANDARD" | "PREMIUM";

export interface ParkingLot {
  id: string;
  venueId: string;
  name: string; // e.g. "A-023"
  status: LotStatus;
  type: LotType;
  location: string;
}

export type BookingStatus = 
  | "MENUNGGU_PEMBAYARAN"
  | "DIPESAN"
  | "CHECK_IN"
  | "CHECK_OUT"
  | "DIBATALKAN"
  | "KEDALUWARSA";

export interface Payment {
  method: string;
  amount: number;
  status: "PENDING" | "SUCCESS" | "FAILED";
  timestamp: string;
}

export interface Booking {
  id: string;
  userId: string;
  venueId: string;
  lotId: string;
  vehicleId: string;
  status: BookingStatus;
  bookingTime: string; // ISO String
  checkInTime?: string;
  checkOutTime?: string;
  plannedExitTime?: string;
  durationHours?: number;
  payment: Payment;
  qrCode: string;
  totalPrice: number;
}
