"use client";

import { useEffect, useState } from "react";
import { useParkirin } from "@/context/ParkirinContext";
import { Card, CardContent, Button, Input } from "@/components/ui/core";
import { Save, TrendingUp } from "lucide-react";

const AIRPORT_VENUE_ID = "v-3";
const TERMINALS = ["Terminal 1", "Terminal 2", "Terminal 3"];

export default function PartnerPricing() {
  const { venues, bookings, updateLotPrice } = useParkirin();
  const venue = venues.find(v => v.id === AIRPORT_VENUE_ID);
  const [prices, setPrices] = useState<Record<string, { base: number; premium: number }>>(() =>
    Object.fromEntries(TERMINALS.map((terminal) => [terminal, { base: venue?.basePrice || 0, premium: venue?.premiumModifier || 0 }]))
  );
  const [savedTerminal, setSavedTerminal] = useState("");

  useEffect(() => {
    const storedPrices = localStorage.getItem("parkirin_airport_terminal_prices");
    if (storedPrices) setPrices(JSON.parse(storedPrices));
  }, []);

  const airportRevenue = bookings
    .filter((booking) => booking.venueId === AIRPORT_VENUE_ID)
    .reduce((total, booking) => total + booking.totalPrice, 0);

  const handleSave = (e: React.FormEvent, terminal: string) => {
    e.preventDefault();
    const price = prices[terminal];
    localStorage.setItem("parkirin_airport_terminal_prices", JSON.stringify(prices));
    updateLotPrice(AIRPORT_VENUE_ID, price.base, price.premium);
    setSavedTerminal(terminal);
    setTimeout(() => setSavedTerminal(""), 3000);
  };

  if (!venue) return null;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white tracking-tight">Pricing Management</h1>
        <p className="text-slate-400 text-sm mt-1">Atur harga setiap terminal parkir inap dan pantau pemasukan bandara.</p>
      </div>

      <Card className="border-emerald-500/30 bg-emerald-500/5">
        <CardContent className="flex items-center gap-4 p-6">
          <TrendingUp className="h-8 w-8 text-emerald-400" />
          <div><p className="text-xs uppercase tracking-wider text-slate-400">Pemasukan Parkir Bandara</p><p className="text-2xl font-black text-emerald-400">Rp {airportRevenue.toLocaleString("id-ID")}</p><p className="text-xs text-slate-500">Total dari transaksi Terminal 1-3</p></div>
        </CardContent>
      </Card>

      <div className="grid gap-6 lg:grid-cols-3">
        {TERMINALS.map((terminal) => (
          <Card key={terminal} className="bg-slate-900 border-slate-800">
            <CardContent className="p-6">
          <div className="mb-6 pb-6 border-b border-slate-800">
            <h2 className="text-lg font-bold text-white mb-2">{terminal}</h2>
            <div className="flex gap-4">
              <span className="px-3 py-1 rounded bg-slate-800 text-slate-300 text-sm font-medium border border-slate-700">Type: {venue.type}</span>
              <span className="px-3 py-1 rounded bg-blue-900/30 text-blue-400 text-sm font-medium border border-blue-900/50">Flat Rate</span>
            </div>
          </div>

          <form onSubmit={(event) => handleSave(event, terminal)} className="space-y-6">
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Base Price (Rp)</label>
              <Input 
                type="number" 
                value={prices[terminal].base}
                onChange={(e) => setPrices({ ...prices, [terminal]: { ...prices[terminal], base: Number(e.target.value) } })}
                className="bg-slate-950 border-slate-700 text-white focus:ring-blue-500"
              />
              <p className="text-xs text-slate-500">Harga dasar untuk Standard Lot.</p>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Premium Modifier (+ Rp)</label>
              <Input 
                type="number" 
                value={prices[terminal].premium}
                onChange={(e) => setPrices({ ...prices, [terminal]: { ...prices[terminal], premium: Number(e.target.value) } })}
                className="bg-slate-950 border-slate-700 text-white focus:ring-blue-500"
              />
              <p className="text-xs text-slate-500">Biaya tambahan yang dikenakan untuk Premium Lot.</p>
            </div>

            <div className="flex items-center gap-4">
              <Button type="submit" className="bg-blue-600 hover:bg-blue-700 flex items-center gap-2">
                <Save className="h-4 w-4" /> Save Changes
              </Button>
              {savedTerminal === terminal && <span className="text-sm font-medium text-green-400">Harga berhasil diperbarui!</span>}
            </div>
          </form>
        </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
