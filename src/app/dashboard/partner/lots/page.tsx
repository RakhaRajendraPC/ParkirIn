"use client";

import { useState } from "react";
import { useParkirin } from "@/context/ParkirinContext";
import { Card, CardContent, Button, Badge, Modal, Input } from "@/components/ui/core";
import { Edit2, Plus, MapPin, Car } from "lucide-react";
import { LotStatus, ParkingLot } from "@/types";

const AIRPORT_VENUE_ID = "v-3";
const TERMINALS = [
  { id: "T1", label: "Terminal 1", floors: ["Lantai 1"] },
  { id: "T2", label: "Terminal 2", floors: ["Lantai 1"] },
  { id: "T3", label: "Terminal 3", floors: ["Lantai 1", "Lantai 2", "Lantai 3", "Lantai 4"] },
];

export default function PartnerLots() {
  const { lots, bookings, users, updateLotStatus, addLot, updateLot } = useParkirin();
  const venueLots = lots.filter(l => l.venueId === AIRPORT_VENUE_ID);
  const [filter, setFilter] = useState("ALL");
  const [selectedTerminal, setSelectedTerminal] = useState("ALL");
  const [selectedFloor, setSelectedFloor] = useState(0);
  const [selectedLotId, setSelectedLotId] = useState<string | null>(null);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingLot, setEditingLot] = useState<ParkingLot | null>(null);
  
  // Form State
  const [formData, setFormData] = useState({
    name: "",
    location: "",
    type: "STANDARD",
  });

  const getTerminalIndex = (lot: ParkingLot) => {
    const lotIndex = venueLots.indexOf(lot);
    return lotIndex < 27 ? 0 : lotIndex < 54 ? 1 : 2;
  };
  const selectedTerminalIndex = TERMINALS.findIndex((terminal) => terminal.id === selectedTerminal);
  const terminalLots = selectedTerminalIndex >= 0
    ? venueLots.filter((lot) => getTerminalIndex(lot) === selectedTerminalIndex)
    : venueLots;
  const filteredLots = terminalLots.filter(l => filter === "ALL" || l.status === filter);
  const selectedTerminalConfig = selectedTerminalIndex >= 0 ? TERMINALS[selectedTerminalIndex] : null;
  const floorCount = selectedTerminalConfig?.floors.length || 1;
  const lotsPerFloor = Math.ceil(terminalLots.length / floorCount);
  const floorLots = selectedTerminalIndex >= 0
    ? terminalLots.slice(selectedFloor * lotsPerFloor, (selectedFloor + 1) * lotsPerFloor)
    : terminalLots;
  const selectedLot = venueLots.find((lot) => lot.id === selectedLotId);
  const selectedBooking = selectedLot
    ? bookings.find((booking) => booking.lotId === selectedLot.id && ["DIPESAN", "CHECK_IN"].includes(booking.status))
    : undefined;
  const selectedUser = selectedBooking ? users.find((user) => user.id === selectedBooking.userId) : undefined;
  const selectedVehicle = selectedBooking && selectedUser
    ? selectedUser.vehicles.find((vehicle) => vehicle.id === selectedBooking.vehicleId)
    : undefined;

  const getTerminalForLot = (lot: ParkingLot) =>
    TERMINALS[getTerminalIndex(lot)]?.label || "Parkir Inap";

  const handleOpenModal = (lot?: ParkingLot) => {
    if (lot) {
      setEditingLot(lot);
      setFormData({ name: lot.name, location: lot.location, type: lot.type });
    } else {
      setEditingLot(null);
      setFormData({ name: "", location: "", type: "STANDARD" });
    }
    setIsModalOpen(true);
  };

  const handleSave = () => {
    if (editingLot) {
      updateLot(editingLot.id, { 
        name: formData.name, 
        location: formData.location, 
        type: formData.type as "STANDARD" | "PREMIUM" 
      });
    } else {
      addLot({
        id: `lot-${Date.now()}`,
        venueId: AIRPORT_VENUE_ID,
        name: formData.name,
        type: formData.type as "STANDARD" | "PREMIUM",
        status: "AVAILABLE",
        location: formData.location,
      });
    }
    setIsModalOpen(false);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-tight">Parking Lots Management</h1>
          <p className="text-slate-400 text-sm mt-1">Mapping status lot parkir inap Terminal 1 sampai Terminal 3.</p>
        </div>
        <Button onClick={() => handleOpenModal()} className="bg-blue-600 hover:bg-blue-700 text-white flex items-center gap-2">
          <Plus className="h-4 w-4" /> Add Lot
        </Button>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        {TERMINALS.map((terminal) => {
          const terminalIndex = TERMINALS.indexOf(terminal);
          const terminalLotCount = venueLots.filter((lot) => getTerminalIndex(lot) === terminalIndex);
          const available = terminalLotCount.filter((lot) => lot.status === "AVAILABLE").length;
          return (
            <button
              type="button"
              key={terminal.id}
              onClick={() => { setSelectedTerminal(terminal.id); setSelectedFloor(0); setSelectedLotId(null); }}
              className={`rounded-xl border p-5 text-left transition-colors ${selectedTerminal === terminal.id ? "border-blue-500 bg-blue-500/10" : "border-slate-800 bg-slate-900 hover:border-slate-700"}`}
            >
              <div className="mb-4 flex items-center justify-between">
                <span className="font-bold text-white">{terminal.label}</span>
                <MapPin className="h-4 w-4 text-blue-400" />
              </div>
              <p className="mb-3 text-[11px] text-slate-500">{terminal.floors.length} lantai parkir • {terminal.floors.join(" • ")}</p>
              <div className="mb-2 flex justify-between text-xs text-slate-400"><span>Slot tersedia</span><strong className="text-emerald-400">{available} / {terminalLotCount.length}</strong></div>
              <div className="h-2 overflow-hidden rounded-full bg-slate-800"><div className="h-full bg-emerald-500" style={{ width: `${(available / (terminalLotCount.length || 1)) * 100}%` }} /></div>
            </button>
          );
        })}
      </div>

      <div className="flex flex-wrap gap-2">
        <button type="button" onClick={() => setSelectedTerminal("ALL")} className={`rounded-lg px-4 py-2 text-sm font-semibold ${selectedTerminal === "ALL" ? "bg-blue-600 text-white" : "bg-slate-800 text-slate-400"}`}>Semua Terminal</button>
      </div>

      {selectedTerminalConfig && <div className="flex flex-wrap gap-2 rounded-xl border border-slate-800 bg-slate-900 p-4">
        <span className="mr-2 self-center text-xs font-semibold uppercase tracking-wider text-slate-500">Pilih lantai:</span>
        {selectedTerminalConfig.floors.map((floor, index) => <button type="button" key={floor} onClick={() => setSelectedFloor(index)} className={`rounded-lg px-4 py-2 text-sm font-semibold ${selectedFloor === index ? "bg-blue-600 text-white" : "bg-slate-800 text-slate-400 hover:text-white"}`}>{floor}</button>)}
      </div>}

      <ParkingMap
        title={selectedTerminal === "ALL" ? "Denah Seluruh Parkir Inap" : selectedTerminalConfig?.label || "Denah Parkir"}
        floor={selectedTerminalConfig?.floors[selectedFloor] || "Semua lantai"}
        lots={floorLots}
        selectedLotId={selectedLotId}
        onSelectLot={setSelectedLotId}
      />

      <VehicleDetails
        lot={selectedLot}
        booking={selectedBooking}
        vehicle={selectedVehicle}
      />

      <Card className="bg-slate-900 border-slate-800">
        <div className="p-4 border-b border-slate-800 flex gap-2 overflow-x-auto">
          {["ALL", "AVAILABLE", "OCCUPIED", "RESERVED"].map(f => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${filter === f ? "bg-slate-800 text-white" : "text-slate-400 hover:bg-slate-800/50"}`}
            >
              {f}
            </button>
          ))}
        </div>
        <CardContent className="p-0 overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="bg-slate-950/50 text-slate-400 uppercase font-semibold text-xs">
              <tr>
                <th className="px-6 py-4">Lot ID</th>
                <th className="px-6 py-4">Location</th>
                <th className="px-6 py-4">Terminal</th>
                <th className="px-6 py-4">Type</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {filteredLots.map(lot => (
                <tr key={lot.id} className="hover:bg-slate-800/50 transition-colors">
                  <td className="px-6 py-4 font-bold text-white">{lot.name}</td>
                  <td className="px-6 py-4">{lot.location}</td>
                  <td className="px-6 py-4 text-slate-400">{getTerminalForLot(lot)}</td>
                  <td className="px-6 py-4">
                    <Badge variant={lot.type === "PREMIUM" ? "outline" : "default"} className={lot.type === "PREMIUM" ? "border-purple-500 text-purple-400" : "bg-slate-800 text-slate-300"}>
                      {lot.type}
                    </Badge>
                  </td>
                  <td className="px-6 py-4">
                    <select 
                      className="bg-slate-950 border border-slate-700 text-slate-300 rounded px-2 py-1 text-xs font-semibold focus:ring-blue-500 focus:border-blue-500"
                      value={lot.status}
                      onChange={(e) => updateLotStatus(lot.id, e.target.value as LotStatus)}
                    >
                      <option value="AVAILABLE">AVAILABLE</option>
                      <option value="OCCUPIED">OCCUPIED</option>
                      <option value="RESERVED">RESERVED</option>
                    </select>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <Button onClick={() => handleOpenModal(lot)} variant="ghost" size="sm" className="text-slate-400 hover:text-white hover:bg-slate-700">
                      <Edit2 className="h-4 w-4" />
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </CardContent>
      </Card>

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingLot ? "Edit Parking Lot" : "Add New Parking Lot"}
      >
        <div className="space-y-4">
          <div className="space-y-2">
            <label className="text-sm font-medium text-slate-300">Name / Block</label>
            <Input
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g. Block A1"
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-slate-300">Location Details</label>
            <Input
              value={formData.location}
              onChange={(e) => setFormData({ ...formData, location: e.target.value })}
              placeholder="e.g. Basement 1, Near Elevator"
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-slate-300">Lot Type</label>
            <select
              value={formData.type}
              onChange={(e) => setFormData({ ...formData, type: e.target.value })}
              className="w-full bg-slate-950 border border-slate-800 text-white rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="STANDARD">STANDARD</option>
              <option value="PREMIUM">PREMIUM</option>
            </select>
          </div>
          
          <div className="flex gap-3 pt-4 border-t border-slate-800">
            <Button variant="outline" className="flex-1" onClick={() => setIsModalOpen(false)}>Cancel</Button>
            <Button onClick={handleSave} className="flex-1 bg-blue-600 hover:bg-blue-700">Save Lot</Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

function ParkingMap({ title, floor, lots, selectedLotId, onSelectLot }: { title: string; floor: string; lots: ParkingLot[]; selectedLotId: string | null; onSelectLot: (id: string | null) => void }) {
  const statusStyles: Record<LotStatus, { bay: string; icon: string; label: string }> = {
    AVAILABLE: { bay: "border-emerald-500/60 bg-emerald-500/10", icon: "text-emerald-400", label: "KOSONG" },
    OCCUPIED: { bay: "border-red-500/70 bg-red-500/20", icon: "text-red-300", label: "TERISI" },
    RESERVED: { bay: "border-amber-500/70 bg-amber-500/20", icon: "text-amber-300", label: "BOOKED" },
  };
  const bays = Array.from({ length: 20 }, (_, index) => lots[index] || null);
  const leftBays = bays.filter((_, index) => index % 2 === 0);
  const rightBays = bays.filter((_, index) => index % 2 === 1);

  return (
    <Card className="overflow-hidden border-slate-700 bg-slate-900 shadow-xl shadow-black/20">
      <div className="flex flex-col gap-4 border-b border-slate-800 p-6 lg:flex-row lg:items-center lg:justify-between">
        <div><div className="mb-2 flex items-center gap-3"><span className="rounded-md bg-blue-500/15 px-2 py-1 text-[10px] font-bold tracking-widest text-blue-300">PARKING PLAN</span><span className="text-xs text-slate-500">Parkir mobil • {lots.length} slot terdaftar</span></div><h2 className="text-xl font-bold text-white">{title}</h2><p className="mt-1 text-sm text-slate-400">{floor} • Layout gedung parkir bertingkat</p></div>
        <div className="flex flex-wrap gap-3 rounded-lg border border-slate-700 bg-slate-950/60 px-4 py-3 text-[11px] font-semibold text-slate-400"><span><i className="mr-1.5 inline-block h-2.5 w-2.5 rounded-sm bg-emerald-400" />Kosong</span><span><i className="mr-1.5 inline-block h-2.5 w-2.5 rounded-sm bg-red-400" />Terpakai</span><span><i className="mr-1.5 inline-block h-2.5 w-2.5 rounded-sm bg-amber-400" />Reserved</span></div>
      </div>
      <div className="overflow-x-auto bg-slate-950 p-5">
        <div className="min-w-[760px] rounded-xl border border-slate-800 bg-slate-900/40 p-5">
          <div className="mb-5 flex items-center justify-between rounded-lg border border-blue-500/30 bg-blue-500/5 px-5 py-3"><span className="rounded-md bg-blue-500 px-3 py-2 text-[10px] font-bold tracking-widest text-white">MASUK</span><div className="flex items-center gap-2 text-[10px] font-bold tracking-[0.25em] text-slate-500"><span>↓</span> JALUR UTAMA <span>↓</span></div><span className="rounded-md bg-slate-700 px-3 py-2 text-[10px] font-bold tracking-widest text-slate-300">KELUAR</span></div>
          <div className="mb-3 grid grid-cols-[1fr_74px_1fr] gap-4 text-center text-[10px] font-bold uppercase tracking-widest text-slate-500"><span>BLOK A</span><span>JALUR</span><span>BLOK B</span></div>
          <div className="grid grid-cols-[1fr_74px_1fr] gap-4">
            <div className="grid grid-cols-5 gap-2">{leftBays.map((lot, index) => <ParkingBay key={lot?.id || `empty-a-${index}`} lot={lot} statusStyles={statusStyles} selected={lot?.id === selectedLotId} onSelect={onSelectLot} />)}</div>
            <div className="flex min-h-[250px] items-center justify-center rounded-lg border-x-2 border-dashed border-slate-700 bg-slate-950/90"><span className="[writing-mode:vertical-rl] text-[10px] font-bold tracking-[0.3em] text-slate-500">ARAH KENDARAAN</span></div>
            <div className="grid grid-cols-5 gap-2">{rightBays.map((lot, index) => <ParkingBay key={lot?.id || `empty-b-${index}`} lot={lot} statusStyles={statusStyles} mirrored selected={lot?.id === selectedLotId} onSelect={onSelectLot} />)}</div>
          </div>
          <div className="mt-5 flex items-center justify-center gap-3 border-t border-dashed border-slate-700 pt-3 text-[10px] font-semibold uppercase tracking-[0.2em] text-slate-600"><span>Ramp / akses lantai</span><span>•</span><span>Parkir mobil standar & premium</span></div>
        </div>
      </div>
    </Card>
  );
}

function ParkingBay({ lot, statusStyles, mirrored = false, selected = false, onSelect }: { lot: ParkingLot | null; statusStyles: Record<LotStatus, { bay: string; icon: string; label: string }>; mirrored?: boolean; selected?: boolean; onSelect: (id: string | null) => void }) {
  if (!lot) return <div className="flex min-h-24 items-center justify-center rounded border border-dashed border-slate-700 bg-slate-950/40 text-[9px] text-slate-700">-</div>;
  const style = statusStyles[lot.status];
  return <button type="button" title={`${lot.name} - ${lot.status}. Klik untuk melihat kendaraan`} onClick={() => onSelect(lot.id)} className={`relative flex min-h-24 flex-col items-center justify-between rounded border p-2 text-left shadow-sm transition-all hover:-translate-y-0.5 hover:border-white ${style.bay} ${selected ? "ring-2 ring-white ring-offset-2 ring-offset-slate-950" : ""}`}><Car className={`mx-auto h-8 w-8 ${style.icon} ${mirrored ? "rotate-180" : ""}`} strokeWidth={1.5} /><span className="w-full text-center text-[10px] font-bold tracking-wide text-slate-200">{lot.name}</span><span className={`w-full text-center text-[8px] font-bold ${style.icon}`}>{style.label}</span></button>;
}

function formatTime(value?: string) {
  return value ? new Date(value).toLocaleTimeString("id-ID", { hour: "2-digit", minute: "2-digit" }) : "Belum tercatat";
}

function formatDateTime(value?: string) {
  return value ? new Date(value).toLocaleString("id-ID", { dateStyle: "medium", timeStyle: "short" }) : "Belum tercatat";
}

function VehicleDetails({ lot, booking, vehicle }: { lot?: ParkingLot; booking?: { id: string; status: string; bookingTime: string; checkInTime?: string; plannedExitTime?: string; durationHours?: number }; vehicle?: { plateNumber: string; type: string; color: string } }) {
  return (
    <Card className="border-slate-800 bg-slate-900">
      <CardContent className="p-6">
        {!lot ? <p className="text-sm text-slate-500">Klik ikon mobil pada denah untuk melihat data kendaraan.</p> : !booking || !vehicle ? <div><p className="text-xs font-bold uppercase tracking-wider text-slate-500">{lot.name}</p><h3 className="mt-1 text-lg font-bold text-white">Belum ada kendaraan</h3><p className="mt-1 text-sm text-slate-400">Slot ini berstatus {lot.status.toLowerCase()} dan belum memiliki booking aktif.</p></div> : <div><div className="flex flex-col justify-between gap-3 sm:flex-row sm:items-start"><div><p className="text-xs font-bold uppercase tracking-wider text-blue-400">Detail Kendaraan • {lot.name}</p><h3 className="mt-1 text-xl font-bold text-white">{vehicle.plateNumber}</h3></div><span className="w-fit rounded-full bg-emerald-500/10 px-3 py-1 text-xs font-bold text-emerald-400">{booking.status}</span></div><div className="mt-5 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4"><div className="rounded-lg border border-slate-800 bg-slate-950 p-4"><p className="text-xs text-slate-500">Jenis kendaraan</p><p className="mt-1 font-semibold text-white">{vehicle.type === "CAR" ? "Mobil" : "Sepeda motor"}</p></div><div className="rounded-lg border border-slate-800 bg-slate-950 p-4"><p className="text-xs text-slate-500">Warna kendaraan</p><p className="mt-1 font-semibold text-white">{vehicle.color}</p></div><div className="rounded-lg border border-slate-800 bg-slate-950 p-4"><p className="text-xs text-slate-500">ID booking</p><p className="mt-1 font-semibold text-white">{booking.id}</p></div><div className="rounded-lg border border-slate-800 bg-slate-950 p-4"><p className="text-xs text-slate-500">Waktu booking</p><p className="mt-1 font-semibold text-white">{formatDateTime(booking.bookingTime)}</p></div><div className="rounded-lg border border-slate-800 bg-slate-950 p-4"><p className="text-xs text-slate-500">Jam masuk</p><p className="mt-1 font-semibold text-white">{formatTime(booking.checkInTime)}</p></div><div className="rounded-lg border border-slate-800 bg-slate-950 p-4"><p className="text-xs text-slate-500">Rencana keluar</p><p className="mt-1 font-semibold text-white">{formatTime(booking.plannedExitTime)}</p></div><div className="rounded-lg border border-slate-800 bg-slate-950 p-4"><p className="text-xs text-slate-500">Durasi booking</p><p className="mt-1 font-semibold text-white">{booking.durationHours || 0} jam</p></div></div></div>}
      </CardContent>
    </Card>
  );
}
