"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { Role, User, Venue, ParkingLot, Booking, BookingStatus, LotStatus } from "../types";
import { mockUser, mockVenues, mockLots, mockBookings } from "../data/mock";

interface ParkirinContextType {
  role: Role;
  setRole: (role: Role) => void;
  user: User | null;
  setUser: (user: User | null) => void;
  users: User[];
  updateUserStatus: (id: string, status: "ACTIVE" | "INACTIVE") => void;
  venues: Venue[];
  addVenue: (venue: Venue) => void;
  updateVenue: (id: string, updates: Partial<Venue>) => void;
  lots: ParkingLot[];
  bookings: Booking[];
  addBooking: (booking: Booking) => void;
  updateBookingStatus: (id: string, status: BookingStatus) => void;
  updateLotStatus: (id: string, status: LotStatus) => void;
  updateLotPrice: (venueId: string, basePrice: number, premium: number) => void;
  addLot: (lot: ParkingLot) => void;
  updateLot: (id: string, updates: Partial<ParkingLot>) => void;
  cancelBooking: (id: string) => void;
}

const ParkirinContext = createContext<ParkirinContextType | undefined>(undefined);

export function ParkirinProvider({ children }: { children: React.ReactNode }) {
  const [isClient, setIsClient] = useState(false);
  
  // Default states
  const [role, setRoleState] = useState<Role>("USER");
  const [user, setUserState] = useState<User | null>(null);
  const [users, setUsers] = useState<User[]>([
    { ...mockUser, id: "u-1", name: "Dzacky", email: "dzacky@example.com", status: "ACTIVE" as any },
    { ...mockUser, id: "u-2", name: "Budi Santoso", email: "budi.s@example.com", status: "ACTIVE" as any },
    { ...mockUser, id: "u-3", name: "Siti Rahma", email: "siti.r@example.com", status: "INACTIVE" as any },
    { ...mockUser, id: "u-4", name: "Andi Wijaya", email: "andi.w@example.com", status: "ACTIVE" as any },
  ]);
  const [venues, setVenues] = useState<Venue[]>(mockVenues);
  const [lots, setLots] = useState<ParkingLot[]>(mockLots);
  const [bookings, setBookings] = useState<Booking[]>(mockBookings);

  // Load from localStorage on mount
  useEffect(() => {
    setIsClient(true);
    const storedRole = localStorage.getItem("parkirin_role") as Role;
    if (storedRole) setRoleState(storedRole);

    const storedUser = localStorage.getItem("parkirin_user");
    if (storedUser) setUserState(JSON.parse(storedUser));
    else setUserState(mockUser); // auto login with mock for demo
    
    const storedUsers = localStorage.getItem("parkirin_users");
    if (storedUsers) setUsers(JSON.parse(storedUsers));

    const storedLots = localStorage.getItem("parkirin_lots");
    if (storedLots) setLots(JSON.parse(storedLots));

    const storedBookings = localStorage.getItem("parkirin_bookings");
    const parsedBookings: Booking[] = storedBookings ? JSON.parse(storedBookings) : [];
    const activeAirportLots = (storedLots ? JSON.parse(storedLots) : mockLots).filter(
      (lot: ParkingLot) => lot.venueId === "v-3" && ["OCCUPIED", "RESERVED"].includes(lot.status)
    );
    const activeBookingStatuses = ["DIPESAN", "CHECK_IN"];
    const existingBookingLotIds = new Set(
      parsedBookings.filter((booking) => activeBookingStatuses.includes(booking.status)).map((booking) => booking.lotId)
    );
    const missingBookings = activeAirportLots
      .filter((lot: ParkingLot) => !existingBookingLotIds.has(lot.id))
      .map((lot: ParkingLot, index: number) => {
        const template = mockBookings[index % mockBookings.length];
        return { ...template, id: `BK-SYNC-${lot.id}`, lotId: lot.id, status: lot.status === "OCCUPIED" ? "CHECK_IN" : "DIPESAN" };
      });
    setBookings(parsedBookings.length > 0 ? [...missingBookings, ...parsedBookings] : mockBookings);

    const storedVenues = localStorage.getItem("parkirin_venues");
    if (storedVenues) setVenues(JSON.parse(storedVenues));
  }, []);

  // Save to localStorage whenever state changes
  useEffect(() => {
    if (!isClient) return;
    localStorage.setItem("parkirin_role", role);
    localStorage.setItem("parkirin_user", JSON.stringify(user));
    localStorage.setItem("parkirin_users", JSON.stringify(users));
    localStorage.setItem("parkirin_lots", JSON.stringify(lots));
    localStorage.setItem("parkirin_bookings", JSON.stringify(bookings));
    localStorage.setItem("parkirin_venues", JSON.stringify(venues));
  }, [role, user, users, lots, bookings, venues, isClient]);

  const setRole = (r: Role) => setRoleState(r);
  const setUser = (u: User | null) => setUserState(u);

  const updateUserStatus = (id: string, status: "ACTIVE" | "INACTIVE") => {
    setUsers(prev => prev.map(u => u.id === id ? { ...u, status: status as any } : u));
  };

  const addVenue = (v: Venue) => setVenues(prev => [...prev, v]);
  
  const updateVenue = (id: string, updates: Partial<Venue>) => {
    setVenues(prev => prev.map(v => v.id === id ? { ...v, ...updates } : v));
  };

  const addBooking = (b: Booking) => setBookings(prev => [b, ...prev]);

  const updateBookingStatus = (id: string, status: BookingStatus) => {
    setBookings((prev) =>
      prev.map((b) => {
        if (b.id === id) {
          const now = new Date().toISOString();
          let updates = { status };
          if (status === "CHECK_IN") updates = { ...updates, checkInTime: now } as any;
          if (status === "CHECK_OUT") updates = { ...updates, checkOutTime: now } as any;
          return { ...b, ...updates };
        }
        return b;
      })
    );
  };

  const updateLotStatus = (id: string, status: LotStatus) => {
    setLots((prev) =>
      prev.map((l) => (l.id === id ? { ...l, status } : l))
    );
  };

  const addLot = (l: ParkingLot) => setLots(prev => [...prev, l]);
  
  const updateLot = (id: string, updates: Partial<ParkingLot>) => {
    setLots(prev => prev.map(l => l.id === id ? { ...l, ...updates } : l));
  };

  const updateLotPrice = (venueId: string, basePrice: number, premium: number) => {
    setVenues((prev) =>
      prev.map((v) =>
        v.id === venueId ? { ...v, basePrice, premiumModifier: premium } : v
      )
    );
  };

  const cancelBooking = (id: string) => {
    const booking = bookings.find((b) => b.id === id);
    if (booking) {
      updateBookingStatus(id, "DIBATALKAN");
      updateLotStatus(booking.lotId, "AVAILABLE");
    }
  };

  if (!isClient) return null; // prevent hydration mismatch

  return (
    <ParkirinContext.Provider
      value={{
        role,
        setRole,
        user,
        setUser,
        users,
        updateUserStatus,
        venues,
        addVenue,
        updateVenue,
        lots,
        bookings,
        addBooking,
        updateBookingStatus,
        updateLotStatus,
        updateLotPrice,
        addLot,
        updateLot,
        cancelBooking,
      }}
    >
      {children}
    </ParkirinContext.Provider>
  );
}

export function useParkirin() {
  const context = useContext(ParkirinContext);
  if (context === undefined) {
    throw new Error("useParkirin must be used within a ParkirinProvider");
  }
  return context;
}
