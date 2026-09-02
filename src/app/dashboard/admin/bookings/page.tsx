"use client";

import { useState, useMemo } from "react";
import { useParkirin } from "@/context/ParkirinContext";
import { Card, Badge, Button } from "@/components/ui/core";
import { Search, Download, CalendarDays, Clock, MapPin, CheckCircle2, XCircle } from "lucide-react";

export default function AdminBookings() {
  const { bookings, users, venues, lots } = useParkirin();
  const [searchTerm, setSearchTerm] = useState("");
  const [filterStatus, setFilterStatus] = useState("ALL");

  const enrichedBookings = useMemo(() => {
    return bookings.map(b => {
      const user = users.find(u => u.id === b.userId);
      const venue = venues.find(v => v.id === b.venueId);
      const vehicle = user?.vehicles.find(v => v.id === b.vehicleId);
      const lot = lots.find(l => l.id === b.lotId);
      return { ...b, user, venue, vehicle, lot };
    });
  }, [bookings, users, venues, lots]);

  const filteredBookings = useMemo(() => {
    let result = enrichedBookings;
    if (filterStatus !== "ALL") {
      result = result.filter(b => b.status === filterStatus);
    }
    if (searchTerm) {
      const lower = searchTerm.toLowerCase();
      result = result.filter(
        b =>
          b.id.toLowerCase().includes(lower) ||
          b.venue?.name.toLowerCase().includes(lower) ||
          b.vehicle?.plateNumber.toLowerCase().includes(lower) ||
          b.user?.name.toLowerCase().includes(lower)
      );
    }
    return result;
  }, [enrichedBookings, searchTerm, filterStatus]);

  const handleExportCSV = () => {
    if (filteredBookings.length === 0) return;
    
    const headers = ["ID Booking", "Waktu", "Pengguna", "Plat Nomor", "Lokasi", "Lot", "Status", "Total (Rp)"];
    const rows = filteredBookings.map(b => [
      b.id,
      new Date(b.bookingTime).toLocaleString("id-ID"),
      b.user?.name || "-",
      b.vehicle?.plateNumber || "-",
      b.venue?.name || "-",
      b.lot?.name || "-",
      b.status,
      b.totalPrice
    ]);

    const csvContent = [
      headers.join(","),
      ...rows.map(row => row.map(v => `"${v}"`).join(","))
    ].join("\n");

    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", `parkirin_transaksi_${new Date().toISOString().split("T")[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "DIPESAN": return <Badge variant="warning" className="bg-amber-500/20 text-amber-400">Dipesan</Badge>;
      case "CHECK_IN": return <Badge variant="default" className="bg-blue-500/20 text-blue-400">Check In</Badge>;
      case "CHECK_OUT": return <Badge variant="success" className="bg-emerald-500/20 text-emerald-400">Selesai</Badge>;
      case "DIBATALKAN": return <Badge variant="danger" className="bg-red-500/20 text-red-400">Dibatalkan</Badge>;
      default: return <Badge variant="outline" className="text-slate-400">{status}</Badge>;
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-white tracking-tight">Transaksi</h1>
          <p className="text-slate-400 mt-1">Pantau seluruh transaksi pemesanan parkir di platform.</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={handleExportCSV} className="border-slate-700 text-slate-300 hover:bg-slate-800 flex items-center gap-2">
            <Download className="h-4 w-4" /> Export CSV
          </Button>
        </div>
      </div>

      <div className="flex flex-col sm:flex-row gap-4 mb-4">
        <div className="flex-1 flex items-center gap-2 bg-slate-900 border border-slate-800 p-2 rounded-lg">
          <Search className="h-5 w-5 text-slate-500 ml-2" />
          <input 
            type="text" 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Cari berdasarkan ID, Plat Nomor, atau Nama Pengguna/Lokasi..." 
            className="bg-transparent border-none focus:outline-none focus:ring-0 text-slate-200 w-full placeholder-slate-500"
          />
        </div>
        <select 
          value={filterStatus} 
          onChange={(e) => setFilterStatus(e.target.value)}
          className="bg-slate-900 border border-slate-800 rounded-lg p-2 text-slate-300 focus:outline-none focus:ring-1 focus:ring-blue-500"
        >
          <option value="ALL">Semua Status</option>
          <option value="DIPESAN">Dipesan</option>
          <option value="CHECK_IN">Check In</option>
          <option value="CHECK_OUT">Selesai</option>
          <option value="DIBATALKAN">Dibatalkan</option>
        </select>
      </div>

      <Card className="bg-slate-900 border-slate-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="bg-slate-950/50 text-slate-400 uppercase font-semibold text-xs border-b border-slate-800">
              <tr>
                <th className="px-6 py-4">ID Transaksi & Waktu</th>
                <th className="px-6 py-4">Pengguna</th>
                <th className="px-6 py-4">Kendaraan</th>
                <th className="px-6 py-4">Lokasi & Lot</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Total</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/50">
              {filteredBookings.length > 0 ? filteredBookings.map((booking) => (
                <tr key={booking.id} className="hover:bg-slate-800/20 transition-colors">
                  <td className="px-6 py-4">
                    <p className="font-mono text-slate-300 font-medium">{booking.id}</p>
                    <p className="text-xs text-slate-500 flex items-center gap-1 mt-1">
                      <CalendarDays className="h-3 w-3" /> {new Date(booking.bookingTime).toLocaleString('id-ID')}
                    </p>
                  </td>
                  <td className="px-6 py-4">
                    <p className="font-medium text-slate-200">{booking.user?.name || "Unknown"}</p>
                  </td>
                  <td className="px-6 py-4">
                    <Badge variant="outline" className="bg-slate-800 border-slate-700 text-slate-300 font-mono">
                      {booking.vehicle?.plateNumber || "Unknown"}
                    </Badge>
                  </td>
                  <td className="px-6 py-4">
                    <p className="font-medium text-slate-200 flex items-center gap-1">
                      <MapPin className="h-3 w-3 text-slate-400" /> {booking.venue?.name || "Unknown"}
                    </p>
                    <p className="text-xs text-slate-500 mt-1">Lot: {booking.lot?.name || "Unknown"}</p>
                  </td>
                  <td className="px-6 py-4">
                    {getStatusBadge(booking.status)}
                  </td>
                  <td className="px-6 py-4 text-right">
                    <p className="font-medium text-white">Rp {booking.totalPrice.toLocaleString('id-ID')}</p>
                    <p className="text-xs text-slate-500 mt-1">{booking.payment.method}</p>
                  </td>
                </tr>
              )) : (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-500">
                    Tidak ada transaksi yang ditemukan.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
