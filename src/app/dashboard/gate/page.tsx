"use client";

import { useState } from "react";
import { useParkirin } from "@/context/ParkirinContext";
import { Card, CardContent, Button, Input, Badge } from "@/components/ui/core";
import { ScanLine, CheckCircle2, XCircle, Loader2 } from "lucide-react";
import { Booking } from "@/types";

export default function GateDashboard() {
  const { bookings, updateBookingStatus, updateLotStatus, users, lots } = useParkirin();
  const [scanValue, setScanValue] = useState("");
  const [scannedBooking, setScannedBooking] = useState<Booking | null>(null);
  const [scanResult, setScanResult] = useState<"IDLE" | "SCANNING" | "VALID" | "INVALID" | "SUCCESS">("IDLE");
  const [invalidReason, setInvalidReason] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  const handleSimulateScan = (e: React.FormEvent) => {
    e.preventDefault();
    if (!scanValue) return;

    setScanResult("SCANNING");
    
    setTimeout(() => {
      const booking = bookings.find(b => b.id === scanValue);
      if (booking) {
        if (booking.status === "DIPESAN") {
          setScannedBooking(booking);
          setScanResult("VALID");
        } else if (booking.status === "CHECK_IN") {
          setScannedBooking(booking);
          setScanResult("VALID");
        } else {
          setScanResult("INVALID");
          setInvalidReason(`Booking status is ${booking.status}`);
        }
      } else {
        setScanResult("INVALID");
        setInvalidReason("QR Code tidak ditemukan di database.");
      }
    }, 1500);
  };

  const handleConfirmAction = () => {
    if (!scannedBooking) return;
    
    if (scannedBooking.status === "DIPESAN") {
      updateBookingStatus(scannedBooking.id, "CHECK_IN");
      updateLotStatus(scannedBooking.lotId, "OCCUPIED");
      setSuccessMessage("Check-in berhasil. Palang pintu terbuka.");
    } else if (scannedBooking.status === "CHECK_IN") {
      updateBookingStatus(scannedBooking.id, "CHECK_OUT");
      updateLotStatus(scannedBooking.lotId, "AVAILABLE");
      setSuccessMessage("Check-out berhasil. Palang pintu terbuka.");
    }
    
    setScanResult("SUCCESS");
    setTimeout(() => {
      handleReset();
    }, 3000);
  };

  const handleReset = () => {
    setScanValue("");
    setScannedBooking(null);
    setScanResult("IDLE");
    setInvalidReason("");
    setSuccessMessage("");
  };

  const getVehiclePlate = (booking: Booking) => {
    const user = users.find(u => u.id === booking.userId);
    if (!user) return "N/A";
    const vehicle = user.vehicles.find(v => v.id === booking.vehicleId);
    return vehicle ? vehicle.plateNumber : "N/A";
  };

  const getLotName = (lotId: string) => {
    const lot = lots.find(l => l.id === lotId);
    return lot ? lot.name : lotId;
  };

  return (
    <div className="flex-1 flex items-center justify-center">
      <div className="w-full max-w-lg space-y-6">
        
        {scanResult === "IDLE" && (
          <Card className="bg-slate-900 border-slate-800 text-center py-12 px-6">
            <div className="w-24 h-24 bg-slate-800 rounded-full flex items-center justify-center mx-auto mb-6">
              <ScanLine className="h-12 w-12 text-blue-500" />
            </div>
            <h2 className="text-2xl font-bold text-white mb-2">Siap Memindai</h2>
            <p className="text-slate-400 mb-8">Arahkan QR Code ke scanner, atau masukkan ID Booking untuk simulasi.</p>
            
            <form onSubmit={handleSimulateScan} className="flex gap-2">
              <Input 
                value={scanValue} 
                onChange={(e) => setScanValue(e.target.value)}
                placeholder="Simulasi scan: Masukkan ID Booking (cth: BK-...)" 
                className="bg-slate-950 border-slate-700 text-white h-12"
              />
              <Button type="submit" className="h-12 bg-blue-600 hover:bg-blue-700">Scan</Button>
            </form>
          </Card>
        )}

        {scanResult === "SCANNING" && (
          <Card className="bg-slate-900 border-slate-800 text-center py-20 px-6">
            <Loader2 className="h-16 w-16 text-blue-500 animate-spin mx-auto mb-6" />
            <h2 className="text-xl font-bold text-white">Memvalidasi QR Code...</h2>
            <p className="text-slate-400">Mohon tunggu sebentar.</p>
          </Card>
        )}

        {scanResult === "VALID" && scannedBooking && (
          <Card className="bg-slate-900 border-blue-500/50 shadow-lg shadow-blue-900/20">
            <CardContent className="p-8 text-center">
              <CheckCircle2 className="h-20 w-20 text-blue-500 mx-auto mb-4" />
              <h2 className="text-2xl font-bold text-white mb-2">QR VALID</h2>
              <p className="text-slate-400 mb-6">Data reservasi ditemukan dan valid.</p>
              
              <div className="bg-slate-950 rounded-xl p-4 border border-slate-800 text-left space-y-3 mb-8">
                <div className="flex justify-between">
                  <span className="text-slate-500">Booking ID</span>
                  <span className="text-white font-mono">{scannedBooking.id}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Aksi</span>
                  <span className="text-white font-bold">
                    {scannedBooking.status === "DIPESAN" ? "CHECK-IN MASUK" : "CHECK-OUT KELUAR"}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Kendaraan</span>
                  <span className="text-white font-mono">{getVehiclePlate(scannedBooking)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Lot Parkir</span>
                  <span className="text-blue-400 font-bold text-lg">{getLotName(scannedBooking.lotId)}</span>
                </div>
              </div>

              <div className="flex gap-4">
                <Button variant="outline" className="flex-1 border-slate-700 text-slate-300 hover:bg-slate-800" onClick={handleReset}>Batal</Button>
                <Button className="flex-1 bg-blue-600 hover:bg-blue-700 h-12 text-lg" onClick={handleConfirmAction}>
                  Konfirmasi {scannedBooking.status === "DIPESAN" ? "Check-in" : "Check-out"}
                </Button>
              </div>
            </CardContent>
          </Card>
        )}

        {scanResult === "INVALID" && (
          <Card className="bg-slate-900 border-red-500/50 shadow-lg shadow-red-900/20">
            <CardContent className="p-8 text-center">
              <XCircle className="h-20 w-20 text-red-500 mx-auto mb-4" />
              <h2 className="text-2xl font-bold text-white mb-2">QR INVALID</h2>
              <p className="text-slate-400 mb-6">{invalidReason}</p>
              
              <Button variant="outline" className="w-full border-slate-700 text-slate-300 hover:bg-slate-800" onClick={handleReset}>
                Kembali ke Scanner
              </Button>
            </CardContent>
          </Card>
        )}

        {scanResult === "SUCCESS" && (
          <Card className="bg-slate-900 border-green-500/50 shadow-lg shadow-green-900/20">
            <CardContent className="p-8 text-center">
              <CheckCircle2 className="h-24 w-24 text-green-500 mx-auto mb-4" />
              <h2 className="text-2xl font-bold text-white mb-2">{successMessage}</h2>
              <p className="text-slate-400">Silakan melintas.</p>
            </CardContent>
          </Card>
        )}

      </div>
    </div>
  );
}
