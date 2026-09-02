"use client";

import { useState } from "react";
import { usePathname } from "next/navigation";
import { useParkirin } from "@/context/ParkirinContext";
import { Card, CardContent } from "@/components/ui/core";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Radio, Camera, CheckCircle2 } from "lucide-react";

const data = [
  { time: '08:00', occupancy: 20 },
  { time: '10:00', occupancy: 45 },
  { time: '12:00', occupancy: 85 },
  { time: '14:00', occupancy: 95 },
  { time: '16:00', occupancy: 70 },
  { time: '18:00', occupancy: 80 },
  { time: '20:00', occupancy: 90 },
  { time: '22:00', occupancy: 40 },
];

const TERMINALS = [
  {
    id: 1,
    name: "Terminal 1",
    capacity: 450,
    occupancy: 72,
    zones: ["Zona A (Short-term)", "Zona B (Long-term)", "Drop-off"],
    features: ["Sensor ultrasonik", "CCTV 24/7", "EV Charging"],
    avgWaitTime: "2-3 min",
  },
  {
    id: 2,
    name: "Terminal 2",
    capacity: 520,
    occupancy: 68,
    zones: ["Zona A (Valet)", "Zona B (Self-park)", "Zona C (Inap)"],
    features: ["Navigasi GPS", "Reserve slot", "Mobile app"],
    avgWaitTime: "1-2 min",
  },
  {
    id: 3,
    name: "Terminal 3",
    capacity: 380,
    occupancy: 85,
    zones: ["Zona A (Premium)", "Zona B (Economy)", "Drop-off"],
    features: ["Priority reserve", "Premium amenities", "Concierge"],
    avgWaitTime: "3-5 min",
  },
];

const CCTV_STREAM = "https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4";

const CCTV_ZONES = [
  { zone: "Entry Gate", cameras: 6, view: "Entry & Exit lanes", stream: CCTV_STREAM },
  { zone: "Zona A (Slots)", cameras: 8, view: "Parking area coverage", stream: CCTV_STREAM },
  { zone: "Zona B (Slots)", cameras: 7, view: "Parking area coverage", stream: CCTV_STREAM },
  { zone: "Drop-off Zone", cameras: 5, view: "Vehicle drop-off area", stream: CCTV_STREAM },
];

export default function Page() {
  return <PartnerDashboardComponent />;
}

export function PartnerDashboardComponent({ monitoringOnly = false }: { monitoringOnly?: boolean }) {
  const { lots } = useParkirin();
  const pathname = usePathname();
  const isMonitoringPage = monitoringOnly || pathname === "/dashboard/partner/monitoring";
  const [activeTerminal, setActiveTerminal] = useState(0);
  const [selectedSensorZone, setSelectedSensorZone] = useState(0);
  const [selectedCctvZone, setSelectedCctvZone] = useState(0);

  const venueLots = lots.filter(l => l.venueId === "v-3");
  
  const total = venueLots.length;
  const available = venueLots.filter(l => l.status === "AVAILABLE").length;
  const occupied = venueLots.filter(l => l.status === "OCCUPIED").length;
  const reserved = venueLots.filter(l => l.status === "RESERVED").length;

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white tracking-tight">{isMonitoringPage ? "Monitoring Sensor & CCTV" : "Overview"}</h1>
        <p className="text-slate-400 mt-1">{isMonitoringPage ? "Pantau perangkat IoT dan kamera seluruh terminal bandara." : "Ringkasan ketersediaan, pendapatan, dan status operasional parkir bandara."}</p>
      </div>

      {/* OVERVIEW TAB */}
      {!isMonitoringPage && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <StatCard title="Total Lot" value={total} color="border-slate-700" text="text-slate-100" />
            <StatCard title="Available" value={available} color="border-blue-500/50" text="text-blue-400" />
            <StatCard title="Occupied" value={occupied} color="border-red-500/50" text="text-red-400" />
            <StatCard title="Reserved" value={reserved} color="border-yellow-500/50" text="text-yellow-400" />
          </div>

          <Card className="bg-slate-900 border-slate-800">
            <div className="p-6 border-b border-slate-800">
              <h2 className="text-lg font-bold text-white">Parking Occupancy Today</h2>
            </div>
            <CardContent className="p-6 h-[400px]">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={data}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                  <XAxis dataKey="time" stroke="#94a3b8" />
                  <YAxis stroke="#94a3b8" />
                  <Tooltip 
                    contentStyle={{ backgroundColor: '#0f172a', borderColor: '#1e293b', color: '#f8fafc' }}
                    itemStyle={{ color: '#34d399' }}
                  />
                  <Line type="monotone" dataKey="occupancy" stroke="#10b981" strokeWidth={3} dot={{ r: 4, fill: '#10b981', strokeWidth: 2, stroke: '#0f172a' }} />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </>
      )}

      {/* SENSOR & CCTV TAB */}
      {isMonitoringPage && (
        <>
          <div className="mb-8">
            <h2 className="text-2xl font-bold text-white mb-6">Sensor & CCTV Deployment Infrastructure</h2>
            
            {/* Terminal Tabs */}
            <div className="flex gap-3 mb-8 flex-wrap">
              {TERMINALS.map((term, idx) => (
                <button
                  key={term.id}
                  onClick={() => setActiveTerminal(idx)}
                  className={`px-6 py-3 rounded-xl text-sm font-bold transition-all ${
                    activeTerminal === idx
                      ? "bg-cyan-600 text-white shadow-lg shadow-cyan-600/25"
                      : "bg-slate-800/50 text-slate-400 hover:bg-slate-800 hover:text-white border border-slate-700/50"
                  }`}
                >
                  {term.name}
                </button>
              ))}
            </div>

            {/* Sensor Coverage & CCTV Grid */}
            <div className="grid lg:grid-cols-2 gap-8">
              {/* Sensor Coverage */}
              <Card className="bg-slate-900 border-slate-800">
                <CardContent className="p-8">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-600 to-blue-600 flex items-center justify-center text-white">
                      <Radio className="h-6 w-6" />
                    </div>
                    <div>
                      <h3 className="text-lg font-bold text-white">Sensor Ultrasonik Slot</h3>
                      <p className="text-xs text-slate-500">Real-time Occupancy Detection</p>
                    </div>
                  </div>

                  <div className="space-y-4">
                    {/* Sensor Stats */}
                    <div className="grid grid-cols-2 gap-3 mb-6">
                      {[
                        { label: "Total Sensor", value: "156", color: "text-blue-400" },
                        { label: "Active", value: "154", color: "text-emerald-400" },
                        { label: "Accuracy", value: "99.5%", color: "text-cyan-400" },
                        { label: "Response Time", value: "<100ms", color: "text-indigo-400" },
                      ].map((stat) => (
                        <div key={stat.label} className="bg-slate-800/60 rounded-lg p-3">
                          <p className={`text-lg font-bold ${stat.color}`}>{stat.value}</p>
                          <p className="text-[10px] text-slate-500">{stat.label}</p>
                        </div>
                      ))}
                    </div>

                    {/* Zones */}
                    <div className="border-t border-slate-700/50 pt-4">
                      <p className="text-sm font-bold text-slate-300 mb-3">Zona Parkir & Sensor Coverage:</p>
                      <div className="space-y-3">
                        {TERMINALS[activeTerminal].zones.map((zone, index) => (
                          <button
                            type="button"
                            key={zone}
                            onClick={() => setSelectedSensorZone(index)}
                            className={`w-full flex items-start gap-3 p-3 rounded-lg text-left transition-all ${
                              selectedSensorZone === index
                                ? "bg-cyan-500/10 border border-cyan-500/40 shadow-lg shadow-cyan-500/10"
                                : "bg-slate-800/40 border border-slate-700/30 hover:border-cyan-500/30"
                            }`}
                          >
                            <div className="w-2 h-2 rounded-full bg-emerald-500 mt-1.5 flex-shrink-0" />
                            <div className="flex-1">
                              <p className="text-sm font-semibold text-slate-200">{zone}</p>
                              <p className="text-xs text-slate-500">52 sensor ultrasonik + LoRaWAN gateway</p>
                            </div>
                            <div className="text-xs bg-emerald-500/20 text-emerald-400 px-2 py-1 rounded">
                              Online
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>

                    <div className="mt-5 rounded-xl border border-cyan-500/30 bg-cyan-500/5 p-4">
                      <p className="text-[10px] uppercase tracking-[0.2em] text-cyan-300 mb-2">Selected Sensor Zone</p>
                      <h4 className="text-lg font-bold text-white mb-1">{TERMINALS[activeTerminal].zones[selectedSensorZone]}</h4>
                      <p className="text-sm text-slate-300">52 sensor aktif • 99.5% akurasi • update setiap 500ms</p>
                    </div>

                    {/* Features */}
                    <div className="border-t border-slate-700/50 pt-4 mt-4">
                      <p className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Capabilities:</p>
                      <ul className="space-y-1.5 text-xs text-slate-400">
                        <li className="flex items-center gap-2">
                          <CheckCircle2 className="h-3 w-3 text-emerald-400" />
                          Deteksi kehadiran kendaraan real-time
                        </li>
                        <li className="flex items-center gap-2">
                          <CheckCircle2 className="h-3 w-3 text-emerald-400" />
                          Cloud sync setiap 500ms
                        </li>
                        <li className="flex items-center gap-2">
                          <CheckCircle2 className="h-3 w-3 text-emerald-400" />
                          Backup baterai 7 hari
                        </li>
                      </ul>
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* CCTV Coverage */}
              <Card className="bg-slate-900 border-slate-800">
                <CardContent className="p-8">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-red-600 to-pink-600 flex items-center justify-center text-white">
                      <Camera className="h-6 w-6" />
                    </div>
                    <div>
                      <h3 className="text-lg font-bold text-white">CCTV Monitoring System</h3>
                      <p className="text-xs text-slate-500">24/7 Video Surveillance</p>
                    </div>
                  </div>

                  <div className="space-y-4">
                    {/* CCTV Stats */}
                    <div className="grid grid-cols-2 gap-3 mb-6">
                      {[
                        { label: "Total Kamera", value: "48", color: "text-red-400" },
                        { label: "Resolution", value: "2-4MP", color: "text-pink-400" },
                        { label: "Coverage", value: "100%", color: "text-rose-400" },
                        { label: "Recording", value: "30 Days", color: "text-orange-400" },
                      ].map((stat) => (
                        <div key={stat.label} className="bg-slate-800/60 rounded-lg p-3">
                          <p className={`text-lg font-bold ${stat.color}`}>{stat.value}</p>
                          <p className="text-[10px] text-slate-500">{stat.label}</p>
                        </div>
                      ))}
                    </div>

                    {/* Camera Zones */}
                    <div className="border-t border-slate-700/50 pt-4">
                      <p className="text-sm font-bold text-slate-300 mb-3">Cakupan Kamera per Zona:</p>
                      <div className="space-y-3">
                        {CCTV_ZONES.map((area, index) => (
                          <button
                            type="button"
                            key={area.zone}
                            onClick={() => setSelectedCctvZone(index)}
                            className={`w-full flex items-start gap-3 p-3 rounded-lg text-left transition-all ${
                              selectedCctvZone === index
                                ? "bg-red-500/10 border border-red-500/40 shadow-lg shadow-red-500/10"
                                : "bg-slate-800/40 border border-slate-700/30 hover:border-red-500/30"
                            }`}
                          >
                            <div className="w-2 h-2 rounded-full bg-red-500 mt-1.5 flex-shrink-0" />
                            <div className="flex-1">
                              <p className="text-sm font-semibold text-slate-200">{area.zone}</p>
                              <p className="text-xs text-slate-500">{area.cameras} kamera • {area.view}</p>
                            </div>
                            <div className="text-xs bg-red-500/20 text-red-400 px-2 py-1 rounded">
                              LIVE
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>

                    <div className="mt-5 rounded-xl border border-red-500/30 bg-red-500/5 p-4">
                      <p className="text-[10px] uppercase tracking-[0.2em] text-red-300 mb-2">Selected CCTV Zone</p>
                      <h4 className="text-lg font-bold text-white mb-3">{CCTV_ZONES[selectedCctvZone].zone}</h4>
                      <CctvVideo src={CCTV_ZONES[selectedCctvZone].stream} />
                      <p className="text-sm text-slate-300 mt-3">
                        Live stream 24/7 • motion detection aktif • playback 30 hari
                      </p>
                    </div>

                    {/* Features */}
                    <div className="border-t border-slate-700/50 pt-4 mt-4">
                      <p className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Features:</p>
                      <ul className="space-y-1.5 text-xs text-slate-400">
                        <li className="flex items-center gap-2">
                          <CheckCircle2 className="h-3 w-3 text-red-400" />
                          Night vision & infrared IR
                        </li>
                        <li className="flex items-center gap-2">
                          <CheckCircle2 className="h-3 w-3 text-red-400" />
                          Wide-angle 90-180° view
                        </li>
                        <li className="flex items-center gap-2">
                          <CheckCircle2 className="h-3 w-3 text-red-400" />
                          Cloud streaming & playback
                        </li>
                      </ul>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

function StatCard({ title, value, color, text }: { title: string; value: number; color: string, text: string }) {
  return (
    <Card className={`bg-slate-900 border ${color}`}>
      <CardContent className="p-6">
        <p className="text-sm font-medium text-slate-400 mb-2 uppercase tracking-wider">{title}</p>
        <p className={`text-4xl font-black ${text}`}>{value}</p>
      </CardContent>
    </Card>
  );
}

function CctvVideo({ src }: { src: string }) {
  const [hasError, setHasError] = useState(false);

  return (
    <div className="relative overflow-hidden rounded-lg border border-slate-700 bg-slate-950">
      <video
        key={src}
        src={src}
        autoPlay
        muted
        loop
        playsInline
        onError={() => setHasError(true)}
        className="h-52 w-full object-cover bg-slate-950"
      />
      {hasError && (
        <div className="absolute inset-0 flex items-center justify-center bg-slate-950 px-4 text-center text-xs text-red-300">
          Stream CCTV tidak dapat dimuat. Periksa koneksi atau URL stream.
        </div>
      )}
    </div>
  );
}
