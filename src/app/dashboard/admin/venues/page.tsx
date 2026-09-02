"use client";

import { useState, useMemo } from "react";
import { useParkirin } from "@/context/ParkirinContext";
import { Card, CardContent, Badge, Button, Modal, Input } from "@/components/ui/core";
import { MapPin, Edit, Search, Navigation } from "lucide-react";

const AIRPORT_MAP_ZONES = [
  {
    id: "all",
    label: "Seluruh Parkir Inap",
    description: "Area parkir inap dan seluruh terminal",
    url: "https://www.openstreetmap.org/export/embed.html?bbox=106.644%2C-6.132%2C106.675%2C-6.108&layer=mapnik&marker=-6.125%2C106.656",
  },
  {
    id: "terminal-1",
    label: "Terminal 1",
    description: "Area parkir Terminal 1",
    url: "https://www.openstreetmap.org/export/embed.html?bbox=106.644%2C-6.136%2C106.659%2C-6.122&layer=mapnik&marker=-6.130%2C106.651",
  },
  {
    id: "terminal-2",
    label: "Terminal 2",
    description: "Area parkir Terminal 2",
    url: "https://www.openstreetmap.org/export/embed.html?bbox=106.648%2C-6.127%2C106.668%2C-6.112&layer=mapnik&marker=-6.120%2C106.658",
  },
  {
    id: "terminal-3",
    label: "Terminal 3",
    description: "Area parkir Terminal 3",
    url: "https://www.openstreetmap.org/export/embed.html?bbox=106.649%2C-6.132%2C106.670%2C-6.115&layer=mapnik&marker=-6.125%2C106.656",
  },
];

export default function AdminVenues() {
  const { venues, lots, updateVenue } = useParkirin();
  const [searchTerm, setSearchTerm] = useState("");
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [currentVenue, setCurrentVenue] = useState<any>(null);
  const [selectedMapZone, setSelectedMapZone] = useState("all");

  // Form State
  const [formData, setFormData] = useState({
    name: "",
    address: "",
    type: "MALL",
    basePrice: 10000,
    premiumModifier: 5000,
  });

  const getVenueStats = (venueId: string) => {
    const venueLots = lots.filter(l => l.venueId === venueId);
    const total = venueLots.length;
    const available = venueLots.filter(l => l.status === "AVAILABLE").length;
    return { total, available };
  };

  const filteredVenues = useMemo(() => {
    if (!searchTerm) return venues;
    const lower = searchTerm.toLowerCase();
    return venues.filter(v => v.name.toLowerCase().includes(lower) || v.type.toLowerCase().includes(lower));
  }, [venues, searchTerm]);

  const handleOpenEdit = (venue: any) => {
    setCurrentVenue(venue);
    setFormData({
      name: venue.name,
      address: venue.address,
      type: venue.type,
      basePrice: venue.basePrice,
      premiumModifier: venue.premiumModifier,
    });
    setIsEditModalOpen(true);
  };

  const handleSaveEdit = (e: React.FormEvent) => {
    e.preventDefault();
    if (currentVenue) {
      updateVenue(currentVenue.id, {
        name: formData.name,
        address: formData.address,
        type: formData.type as any,
        basePrice: Number(formData.basePrice),
        premiumModifier: Number(formData.premiumModifier),
      });
      setIsEditModalOpen(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-white tracking-tight">Manajemen Lokasi</h1>
          <p className="text-slate-400 mt-1">Kelola seluruh lokasi parkir partner di platform Inapandara.</p>
        </div>
      </div>

      <Card className="bg-slate-900 border-slate-800 overflow-hidden">
        <div className="flex items-center justify-between gap-4 border-b border-slate-800 p-5">
          <div>
            <div className="flex items-center gap-2">
              <Navigation className="h-4 w-4 text-blue-400" />
              <h2 className="font-semibold text-white">Peta Area Parkir Bandara</h2>
            </div>
            <p className="mt-1 text-xs text-slate-500">Terminal 1, Terminal 2, Terminal 3, dan parkir inap</p>
          </div>
          <span className="rounded-full bg-emerald-500/10 px-3 py-1 text-xs font-medium text-emerald-400">Lokasi aktif</span>
        </div>
        <div className="flex flex-wrap gap-2 border-b border-slate-800 p-4">
          {AIRPORT_MAP_ZONES.map((zone) => (
            <button
              key={zone.id}
              type="button"
              onClick={() => setSelectedMapZone(zone.id)}
              className={`rounded-lg border px-3 py-2 text-xs font-semibold transition-colors ${
                selectedMapZone === zone.id
                  ? "border-blue-500 bg-blue-500/15 text-blue-300"
                  : "border-slate-700 bg-slate-950/40 text-slate-400 hover:border-blue-500/50 hover:text-slate-200"
              }`}
            >
              {zone.label}
            </button>
          ))}
        </div>
        <iframe
          title={`Peta ${AIRPORT_MAP_ZONES.find((zone) => zone.id === selectedMapZone)?.label}`}
          src={AIRPORT_MAP_ZONES.find((zone) => zone.id === selectedMapZone)?.url}
          className="h-64 w-full border-0 grayscale-[20%]"
          loading="eager"
          referrerPolicy="no-referrer-when-downgrade"
        />
        <p className="border-t border-slate-800 px-5 py-3 text-xs text-slate-500">
          {AIRPORT_MAP_ZONES.find((zone) => zone.id === selectedMapZone)?.description}
        </p>
      </Card>

      <div className="flex items-center gap-2 mb-4 bg-slate-900 border border-slate-800 p-2 rounded-lg">
        <Search className="h-5 w-5 text-slate-500 ml-2" />
        <input 
          type="text" 
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Cari area terminal..." 
          className="bg-transparent border-none focus:outline-none focus:ring-0 text-slate-200 w-full placeholder-slate-500"
        />
      </div>

      <Card className="bg-slate-900 border-slate-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="bg-slate-950/50 text-slate-400 uppercase font-semibold text-xs border-b border-slate-800">
              <tr>
                <th className="px-6 py-4">Nama Lokasi</th>
                <th className="px-6 py-4">Tipe</th>
                <th className="px-6 py-4">Harga Dasar</th>
                <th className="px-6 py-4">Kapasitas (Tersedia/Total)</th>
                <th className="px-6 py-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/50">
              {filteredVenues.length > 0 ? filteredVenues.map((venue) => {
                const stats = getVenueStats(venue.id);
                return (
                  <tr key={venue.id} className="hover:bg-slate-800/20 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg overflow-hidden shrink-0 border border-slate-700">
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img src={venue.image} alt={venue.name} className="w-full h-full object-cover" />
                        </div>
                        <div>
                          <p className="font-bold text-slate-200">{venue.name}</p>
                          <p className="text-xs text-slate-500 flex items-center gap-1 mt-0.5">
                            <MapPin className="h-3 w-3" /> {venue.distance}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <Badge variant={venue.type === "MALL" ? "default" : venue.type === "AIRPORT" ? "warning" : "success"} className={
                        venue.type === "MALL" ? "bg-blue-500/20 text-blue-400" : 
                        venue.type === "AIRPORT" ? "bg-orange-500/20 text-orange-400" : 
                        "bg-emerald-500/20 text-emerald-400"
                      }>
                        {venue.type}
                      </Badge>
                    </td>
                    <td className="px-6 py-4">
                      <p className="font-medium text-slate-300">Rp {venue.basePrice.toLocaleString('id-ID')}</p>
                      <p className="text-xs text-slate-500">+{venue.premiumModifier.toLocaleString('id-ID')} Premium</p>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <div className="w-full max-w-[100px] h-2 bg-slate-800 rounded-full overflow-hidden">
                          <div 
                            className="h-full bg-blue-500" 
                            style={{ width: `${(stats.available / (stats.total || 1)) * 100}%` }}
                          />
                        </div>
                        <span className="text-xs font-medium text-slate-400">
                          <span className="text-blue-400">{stats.available}</span> / {stats.total}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button 
                          onClick={() => handleOpenEdit(venue)}
                          className="p-2 text-slate-400 hover:text-emerald-400 hover:bg-emerald-400/10 rounded-lg transition-colors"
                        >
                          <Edit className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              }) : (
                <tr>
                  <td colSpan={5} className="px-6 py-12 text-center text-slate-500">
                    Tidak ada lokasi yang ditemukan.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>

      <Modal isOpen={isEditModalOpen} onClose={() => setIsEditModalOpen(false)} title="Edit Lokasi">
        <form onSubmit={handleSaveEdit} className="space-y-4">
          <div>
            <label className="text-sm font-medium text-slate-300 mb-1 block">Nama Lokasi</label>
            <Input required value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} className="bg-slate-950 border-slate-800 text-white" />
          </div>
          <div>
            <label className="text-sm font-medium text-slate-300 mb-1 block">Alamat</label>
            <Input required value={formData.address} onChange={e => setFormData({...formData, address: e.target.value})} className="bg-slate-950 border-slate-800 text-white" />
          </div>
          <div>
            <label className="text-sm font-medium text-slate-300 mb-1 block">Tipe</label>
            <select value={formData.type} onChange={e => setFormData({...formData, type: e.target.value})} className="w-full bg-slate-950 border border-slate-800 rounded-md p-2 text-white">
              <option value="MALL">Mall</option>
              <option value="AIRPORT">Bandara</option>
              <option value="OFFICE">Perkantoran</option>
            </select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-sm font-medium text-slate-300 mb-1 block">Harga Dasar (Rp)</label>
              <Input type="number" required value={formData.basePrice} onChange={e => setFormData({...formData, basePrice: parseInt(e.target.value) || 0})} className="bg-slate-950 border-slate-800 text-white" />
            </div>
            <div>
              <label className="text-sm font-medium text-slate-300 mb-1 block">Modifier Premium</label>
              <Input type="number" required value={formData.premiumModifier} onChange={e => setFormData({...formData, premiumModifier: parseInt(e.target.value) || 0})} className="bg-slate-950 border-slate-800 text-white" />
            </div>
          </div>
          <div className="pt-4 flex justify-end gap-2 border-t border-slate-800">
            <Button type="button" variant="ghost" onClick={() => setIsEditModalOpen(false)} className="text-slate-300">Batal</Button>
            <Button type="submit">Simpan Perubahan</Button>
          </div>
        </form>
      </Modal>

    </div>
  );
}
