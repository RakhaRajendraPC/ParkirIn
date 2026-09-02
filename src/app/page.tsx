"use client";

import { useState, useEffect, useRef } from "react";
import Link from "next/link";
import Image from "next/image";
import {
  Plane,
  Navigation,
  Video,
  Ticket,
  Wifi,
  Camera,
  Shield,
  Monitor,
  Radio,
  Cpu,
  ChevronRight,
  ArrowRight,
  Activity,
  BarChart3,
  Bell,
  Clock,
  Car,
  CircleParking,
  Eye,
  Gauge,
  Lock,
  Zap,
  CheckCircle2,
  Signal,
  MonitorPlay,
  MapPin,
  Smartphone,
  TrendingUp,
  Layers,
  AlertCircle,
} from "lucide-react";
import { Button } from "@/components/ui/core";

/* ─────────────────────── Scroll Reveal Hook ─────────────────────── */
function useReveal() {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      ([e]) => { if (e.isIntersecting) { setVisible(true); obs.disconnect(); } },
      { threshold: 0.15 }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, []);
  return { ref, visible };
}

function Reveal({ children, className = "", delay = 0 }: { children: React.ReactNode; className?: string; delay?: number }) {
  const { ref, visible } = useReveal();
  return (
    <div
      ref={ref}
      className={className}
      style={{
        opacity: visible ? 1 : 0,
        transform: visible ? "translateY(0)" : "translateY(40px)",
        transition: `opacity 0.7s ease ${delay}s, transform 0.7s ease ${delay}s`,
      }}
    >
      {children}
    </div>
  );
}

/* ─────────────────────── Animated Counter ─────────────────────── */
function Counter({ target, suffix = "" }: { target: number; suffix?: string }) {
  const [count, setCount] = useState(0);
  const { ref, visible } = useReveal();
  useEffect(() => {
    if (!visible) return;
    let start = 0;
    const step = Math.max(1, Math.ceil(target / 60));
    const id = setInterval(() => {
      start += step;
      if (start >= target) { setCount(target); clearInterval(id); }
      else setCount(start);
    }, 25);
    return () => clearInterval(id);
  }, [visible, target]);
  return <span ref={ref}>{count}{suffix}</span>;
}

/* ─────────────────────── Parking Slot Data ─────────────────────── */
const SLOTS = [
  { id: "A01", status: "occupied" }, { id: "A02", status: "empty" }, { id: "A03", status: "occupied" },
  { id: "A04", status: "reserved" }, { id: "A05", status: "empty" }, { id: "A06", status: "occupied" },
  { id: "A07", status: "empty" }, { id: "A08", status: "occupied" }, { id: "A09", status: "empty" },
  { id: "A10", status: "occupied" }, { id: "A11", status: "reserved" }, { id: "A12", status: "empty" },
  { id: "A13", status: "occupied" }, { id: "A14", status: "empty" }, { id: "A15", status: "occupied" },
  { id: "A16", status: "empty" },
] as const;

const STATUS_MAP = {
  occupied: { label: "Terisi", color: "bg-red-500", ring: "ring-red-500/30", text: "text-red-400" },
  empty:    { label: "Kosong", color: "bg-emerald-500", ring: "ring-emerald-500/30", text: "text-emerald-400" },
  reserved: { label: "Reserved", color: "bg-amber-500", ring: "ring-amber-500/30", text: "text-amber-400" },
} as const;

/* ─────────────────────── CCTV Data ─────────────────────── */
const CCTV_FEEDS = [
  { name: "Zona A — Entry Gate", cam: "CAM-01", status: "online", resolution: "2MP FHD", angle: "180°" },
  { name: "Zona B — Floor 2", cam: "CAM-02", status: "online", resolution: "2MP FHD", angle: "90°" },
  { name: "Terminal 3 — Lot C", cam: "CAM-03", status: "online", resolution: "4MP HD", angle: "120°" },
  { name: "Drop-off Zone", cam: "CAM-04", status: "online", resolution: "2MP FHD", angle: "180°" },
];

/* ─────────────────────── Terminal Data ─────────────────────── */
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

/* ─────────────────────── How it Works Data ─────────────────────── */
const HOW_IT_WORKS = [
  {
    step: 1,
    icon: <Smartphone className="h-8 w-8" />,
    title: "Buka Aplikasi",
    desc: "Masuk ke aplikasi PARKIRIN dengan akun bandara Anda atau nomor boarding pass.",
  },
  {
    step: 2,
    icon: <MapPin className="h-8 w-8" />,
    title: "Pilih Terminal & Tipe Parkir",
    desc: "Tentukan lokasi parkir (Terminal 1/2/3) dan durasi parkir (short/long-term, inap).",
  },
  {
    step: 3,
    icon: <CheckCircle2 className="h-8 w-8" />,
    title: "Reserve Slot",
    desc: "Sistem menggunakan sensor IoT untuk reserve slot kosong terbaik untuk Anda secara real-time.",
  },
  {
    step: 4,
    icon: <Navigation className="h-8 w-8" />,
    title: "Navigasi ke Slot",
    desc: "GPS dalam aplikasi memandu Anda langsung ke slot yang sudah direserve dengan presisi tinggi.",
  },
  {
    step: 5,
    icon: <Video className="h-8 w-8" />,
    title: "Pantau Kendaraan",
    desc: "Akses live CCTV 24/7 untuk memantau kondisi kendaraan Anda kapan saja dari dashboard.",
  },
  {
    step: 6,
    icon: <CheckCircle2 className="h-8 w-8" />,
    title: "Check-out Otomatis",
    desc: "Sistem mendeteksi perjalanan Anda via boarding pass. Pembayaran otomatis saat check-out.",
  },
];

/* ─────────────────────── MAIN PAGE ─────────────────────── */
export default function LandingPage() {
  const [activeTerminal, setActiveTerminal] = useState(2); // 0-indexed
  const [time, setTime] = useState("");
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);
  const [selectedCctv, setSelectedCctv] = useState(0);

  useEffect(() => {
    const tick = () => setTime(new Date().toLocaleTimeString("id-ID", { hour: "2-digit", minute: "2-digit", second: "2-digit" }));
    tick();
    const id = setInterval(tick, 1000);
    return () => clearInterval(id);
  }, []);

  const currentTerminal = TERMINALS[activeTerminal];

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 overflow-x-hidden">
      {/* ──────── CSS Keyframes ──────── */}
      <style>{`
        @keyframes float { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-18px)} }
        @keyframes glow-pulse { 0%,100%{box-shadow:0 0 20px 0 rgba(59,130,246,.3)} 50%{box-shadow:0 0 40px 8px rgba(59,130,246,.5)} }
        @keyframes gradient-x { 0%{background-position:0% 50%} 50%{background-position:100% 50%} 100%{background-position:0% 50%} }
        @keyframes slot-pulse { 0%,100%{opacity:1} 50%{opacity:.6} }
        @keyframes scan-line { 0%{top:-2px} 100%{top:100%} }
        @keyframes orbit { 0%{transform:rotate(0deg) translateX(120px) rotate(0deg)} 100%{transform:rotate(360deg) translateX(120px) rotate(-360deg)} }
        .float { animation: float 6s ease-in-out infinite }
        .glow-btn { animation: glow-pulse 3s ease-in-out infinite }
        .gradient-bg { background-size:200% 200%; animation: gradient-x 8s ease infinite }
        .slot-pulse { animation: slot-pulse 2s ease-in-out infinite }
        .scan-line { animation: scan-line 3s linear infinite }
      `}</style>

      {/* ══════════════════════ HEADER ══════════════════════ */}
      <header className="fixed top-0 inset-x-0 z-50 border-b border-white/5">
        <div className="backdrop-blur-xl bg-slate-950/70">
          <div className="max-w-7xl mx-auto px-4 md:px-6 h-16 md:h-20 flex items-center justify-between">
            <div className="flex items-center gap-2 md:gap-3">
              <Image src="/logo.png" alt="Inapandara Logo" width={500} height={130} className="h-12 md:h-32 w-auto brightness-0 invert" priority />
            </div>
            <nav className="hidden md:flex items-center gap-8">
              {["Fitur", "Teknologi", "Dashboard"].map((t) => (
                <a key={t} href={`#${t.toLowerCase()}`} className="text-sm font-medium text-slate-400 hover:text-white transition-colors">
                  {t}
                </a>
              ))}
            </nav>
            <Link href="/login">
              <Button className="bg-blue-600 hover:bg-blue-500 text-white px-4 md:px-6 py-2 md:py-2.5 text-sm md:text-base rounded-lg">
                Masuk
              </Button>
            </Link>
          </div>
        </div>
      </header>

      {/* ══════════════════════ HERO ══════════════════════ */}
      <section className="relative pt-28 md:pt-36 pb-16 md:pb-24 md:pt-44 md:pb-32 overflow-hidden">
        {/* Animated BG Orbs */}
        <div className="absolute inset-0 -z-10">
          <div className="absolute top-20 left-1/4 w-[500px] h-[500px] rounded-full bg-blue-600/10 blur-[120px]" />
          <div className="absolute bottom-10 right-1/4 w-[400px] h-[400px] rounded-full bg-cyan-500/10 blur-[100px]" />
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full bg-indigo-500/5 blur-[140px]" />
        </div>
        {/* Grid overlay */}
        <div className="absolute inset-0 -z-10 opacity-[0.03]" style={{ backgroundImage: "linear-gradient(rgba(255,255,255,.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.1) 1px, transparent 1px)", backgroundSize: "60px 60px" }} />

        <div className="max-w-7xl mx-auto px-4 md:px-6">
          <div className="grid lg:grid-cols-2 gap-8 md:gap-16 items-center">
            {/* Left - Copy */}
            <Reveal>
              <div className="inline-flex items-center gap-2 px-3 md:px-4 py-2 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs md:text-sm font-semibold mb-6 md:mb-8">
                <Shield className="h-3 w-3 md:h-4 md:w-4" />
                Smart Airport Parking System
              </div>
              <h1 className="text-2xl md:text-5xl lg:text-6xl font-extrabold leading-tight tracking-tight mb-4 md:mb-6">
                <span className="bg-gradient-to-r from-white via-slate-200 to-slate-400 bg-clip-text text-transparent">
                  Reservasi & Pantau{" "}
                </span>
                <br />
                <span className="bg-gradient-to-r from-blue-400 to-cyan-400 bg-clip-text text-transparent">
                  Kendaraan Anda
                </span>
                <br />
                <span className="bg-gradient-to-r from-white via-slate-200 to-slate-400 bg-clip-text text-transparent">
                  Real-Time
                </span>
              </h1>
              <p className="text-base md:text-lg text-slate-400 max-w-xl mb-6 md:mb-10 leading-relaxed">
                Sistem parkir bandara cerdas dengan sensor ultrasonik per-slot dan monitoring CCTV 24/7. 
                Reservasi dari rumah, navigasi presisi ke slot kosong, pantau kendaraan kapan saja.
              </p>
              <div className="flex flex-col sm:flex-row gap-3 md:gap-4">
                <Link href="/login">
                  <button className="glow-btn inline-flex items-center justify-center gap-2 px-6 md:px-8 py-3 md:py-4 bg-gradient-to-r from-blue-600 to-cyan-500 text-white font-bold rounded-xl text-sm md:text-lg hover:from-blue-500 hover:to-cyan-400 transition-all">
                    Cek Availability
                    <ArrowRight className="h-4 w-4 md:h-5 md:w-5" />
                  </button>
                </Link>
                <Link href="/login">
                  <button className="inline-flex items-center justify-center gap-2 px-6 md:px-8 py-3 md:py-4 border border-slate-700 text-slate-300 font-medium rounded-xl text-sm md:text-lg hover:bg-slate-800/50 hover:border-slate-600 transition-all">
                    <Monitor className="h-4 w-4 md:h-5 md:w-5" />
                    Dashboard Demo
                  </button>
                </Link>
              </div>
            </Reveal>

            {/* Right - Floating Dashboard Mockup */}
            <Reveal delay={0.3}>
              <div className="float relative hidden md:block">
                <div className="relative rounded-2xl border border-slate-800 bg-slate-900/80 backdrop-blur-sm p-6 shadow-2xl shadow-blue-500/5">
                  {/* Mini Dashboard Header */}
                  <div className="flex items-center justify-between mb-5">
                    <div className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full bg-red-500" />
                      <div className="w-3 h-3 rounded-full bg-amber-500" />
                      <div className="w-3 h-3 rounded-full bg-emerald-500" />
                    </div>
                    <span className="text-xs text-slate-500 font-mono">parkirin-dashboard v2.0</span>
                  </div>
                  {/* Slot Grid Preview */}
                  <div className="grid grid-cols-8 gap-1.5 mb-4">
                    {["e","o","o","e","r","e","o","e","o","e","o","o","e","e","r","o","e","o","e","e","o","e","o","o"].map((s, i) => (
                      <div key={i} className={`h-6 rounded-sm ${s === "o" ? "bg-red-500/60" : s === "e" ? "bg-emerald-500/60" : "bg-amber-500/60"} ${s === "e" ? "slot-pulse" : ""}`} />
                    ))}
                  </div>
                  {/* Mini Stats */}
                  <div className="grid grid-cols-3 gap-3">
                    {[
                      { label: "Terisi", value: "62%", color: "text-red-400" },
                      { label: "Kosong", value: "29%", color: "text-emerald-400" },
                      { label: "Reserved", value: "9%", color: "text-amber-400" },
                    ].map((s) => (
                      <div key={s.label} className="bg-slate-800/60 rounded-lg p-3 text-center">
                        <p className={`text-lg font-bold ${s.color}`}>{s.value}</p>
                        <p className="text-[10px] text-slate-500 uppercase tracking-wider">{s.label}</p>
                      </div>
                    ))}
                  </div>
                </div>
                {/* Decorative glow */}
                <div className="absolute -inset-4 rounded-3xl bg-gradient-to-r from-blue-500/10 to-cyan-500/10 blur-xl -z-10" />
              </div>
            </Reveal>
          </div>
        </div>
      </section>

      {/* ══════════════════════ STATS BAR ══════════════════════ */}
      <section className="relative border-y border-slate-800/50">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600/5 via-transparent to-cyan-600/5" />
        <div className="max-w-7xl mx-auto px-4 md:px-6 py-6 md:py-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-8">
            {[
              { value: 500, suffix: "+", label: "Slot Aktif", icon: <CircleParking className="h-4 w-4 md:h-5 md:w-5 text-blue-400" /> },
              { value: 24, suffix: "/7", label: "Monitoring", icon: <Eye className="h-4 w-4 md:h-5 md:w-5 text-cyan-400" /> },
              { value: 3, suffix: "", label: "Terminal", icon: <Plane className="h-4 w-4 md:h-5 md:w-5 text-indigo-400" /> },
              { value: 99, suffix: ".8%", label: "Uptime", icon: <Activity className="h-4 w-4 md:h-5 md:w-5 text-emerald-400" /> },
            ].map((s, i) => (
              <Reveal key={s.label} delay={i * 0.1}>
                <div className="flex items-center gap-3 md:gap-4">
                  <div className="w-10 h-10 md:w-12 md:h-12 rounded-xl bg-slate-800/80 border border-slate-700/50 flex items-center justify-center flex-shrink-0">
                    {s.icon}
                  </div>
                  <div>
                    <p className="text-lg md:text-3xl font-extrabold text-white">
                      <Counter target={s.value} suffix={s.suffix} />
                    </p>
                    <p className="text-[9px] md:text-xs text-slate-500 uppercase tracking-wider font-medium">{s.label}</p>
                  </div>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ══════════════════════ FITUR UTAMA ══════════════════════ */}
      <section id="fitur" className="py-24 md:py-32">
        <div className="max-w-7xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-16">
              <p className="text-sm font-bold text-blue-400 uppercase tracking-widest mb-3">Fitur Utama</p>
              <h2 className="text-3xl md:text-5xl font-extrabold mb-4">
                <span className="bg-gradient-to-r from-white to-slate-400 bg-clip-text text-transparent">
                  Solusi Parkir Bandara Terdepan
                </span>
              </h2>
              <p className="text-slate-400 max-w-2xl mx-auto text-lg">
                Teknologi sensor IoT dan AI terintegrasi untuk pengalaman parkir bandara yang aman, efisien, dan termonitor penuh.
              </p>
            </div>
          </Reveal>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              {
                icon: <Plane className="h-7 w-7" />,
                title: "Reservasi Parkir Inap",
                desc: "Pesan slot parkir jangka panjang sebelum keberangkatan. Terhubung langsung dengan jadwal penerbangan Anda.",
                gradient: "from-blue-500 to-indigo-500",
              },
              {
                icon: <Navigation className="h-7 w-7" />,
                title: "Navigasi Presisi Slot",
                desc: "Sensor ultrasonik memandu Anda langsung ke slot kosong terdekat dengan navigasi real-time di dalam area parkir.",
                gradient: "from-cyan-500 to-blue-500",
              },
              {
                icon: <Video className="h-7 w-7" />,
                title: "Monitoring CCTV 24/7",
                desc: "Pantau kendaraan Anda kapan saja melalui CCTV HD yang terpasang di setiap zona dan slot parkir bandara.",
                gradient: "from-indigo-500 to-purple-500",
              },
              {
                icon: <Ticket className="h-7 w-7" />,
                title: "Integrasi Boarding Pass",
                desc: "Hubungkan tiket boarding pass dengan reservasi parkir. Check-in parkir otomatis saat Anda tiba di bandara.",
                gradient: "from-emerald-500 to-cyan-500",
              },
            ].map((f, i) => (
              <Reveal key={f.title} delay={i * 0.1}>
                <div className="group relative h-full">
                  {/* Gradient border on hover */}
                  <div className={`absolute -inset-[1px] rounded-2xl bg-gradient-to-b ${f.gradient} opacity-0 group-hover:opacity-100 transition-opacity duration-500 blur-[1px]`} />
                  <div className="relative h-full rounded-2xl bg-slate-900 border border-slate-800 p-8 hover:bg-slate-900/80 transition-all duration-500 flex flex-col">
                    <div className={`w-14 h-14 rounded-xl bg-gradient-to-br ${f.gradient} flex items-center justify-center text-white mb-6 shadow-lg`}>
                      {f.icon}
                    </div>
                    <h3 className="text-lg font-bold text-white mb-3">{f.title}</h3>
                    <p className="text-sm text-slate-400 leading-relaxed flex-1">{f.desc}</p>
                    <div className="mt-6 flex items-center gap-2 text-sm font-medium text-blue-400 group-hover:text-blue-300 transition-colors">
                      Pelajari <ChevronRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
                    </div>
                  </div>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ══════════════════════ REAL-TIME SENSOR ══════════════════════ */}
      <section id="teknologi" className="py-24 md:py-32 relative">
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-blue-950/10 to-transparent -z-10" />
        <div className="max-w-7xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-4">
              <p className="text-sm font-bold text-cyan-400 uppercase tracking-widest mb-3">IoT Sensor Network</p>
              <h2 className="text-3xl md:text-5xl font-extrabold mb-4">
                <span className="bg-gradient-to-r from-white to-slate-400 bg-clip-text text-transparent">
                  Real-time Parking Slot Sensor
                </span>
              </h2>
              <p className="text-slate-400 max-w-2xl mx-auto text-lg">
                Pantau status setiap slot parkir secara real-time dengan sensor ultrasonik presisi tinggi
              </p>
            </div>
          </Reveal>

          {/* Terminal Tabs */}
          <Reveal delay={0.1}>
            <div className="flex justify-center gap-2 mb-12 mt-8">
              {["Terminal 1", "Terminal 2", "Terminal 3"].map((t, i) => (
                <button
                  key={t}
                  onClick={() => setActiveTerminal(i)}
                  className={`px-6 py-3 rounded-xl text-sm font-bold transition-all ${
                    activeTerminal === i
                      ? "bg-blue-600 text-white shadow-lg shadow-blue-600/25"
                      : "bg-slate-800/50 text-slate-400 hover:bg-slate-800 hover:text-white border border-slate-700/50"
                  }`}
                >
                  {t}
                </button>
              ))}
            </div>
          </Reveal>

          <div className="grid lg:grid-cols-3 gap-8">
            {/* Slot Grid */}
            <Reveal delay={0.2} className="lg:col-span-2">
              <div className="rounded-2xl border border-slate-800 bg-slate-900/60 backdrop-blur-sm p-8">
                <div className="flex items-center justify-between mb-6">
                  <div>
                    <h3 className="text-lg font-bold text-white">{TERMINALS[activeTerminal].name} — Zona A</h3>
                    <p className="text-sm text-slate-500">Kapasitas {TERMINALS[activeTerminal].capacity} Slot • Occupancy {TERMINALS[activeTerminal].occupancy}%</p>
                  </div>
                  <div className="flex items-center gap-2 text-xs text-slate-400">
                    <Signal className="h-4 w-4 text-emerald-400" />
                    <span className="font-mono">{time}</span>
                  </div>
                </div>

                {/* Parking Grid - Enhanced with click interaction */}
                <div className="grid grid-cols-4 md:grid-cols-8 gap-3 mb-6">
                  {SLOTS.map((slot, i) => {
                    const s = STATUS_MAP[slot.status];
                    const isSelected = selectedSlot === slot.id;
                    return (
                      <div
                        key={slot.id}
                        onClick={() => setSelectedSlot(isSelected ? null : slot.id)}
                        className={`relative rounded-xl border transition-all group cursor-pointer ${
                          isSelected
                            ? `bg-slate-800 border-${s.color.split("-")[1]}-400 ring-2 ring-${s.color.split("-")[1]}-500/30`
                            : "border-slate-700/50 bg-slate-800/40 hover:bg-slate-800/80"
                        }`}
                      >
                        <div className="p-3 text-center">
                          <div className={`w-4 h-4 rounded-full ${s.color} mx-auto mb-2 ring-4 ${s.ring} ${slot.status === "empty" ? "slot-pulse" : ""}`} />
                          <p className="text-xs font-bold text-slate-300">{slot.id}</p>
                          <p className={`text-[10px] font-medium ${s.text} mt-0.5`}>{s.label}</p>
                          {slot.status === "occupied" && (
                            <Car className="absolute top-1 right-1 h-3 w-3 text-slate-600" />
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>

                {/* Selected Slot Details */}
                {selectedSlot && (
                  <Reveal>
                    <div className="rounded-lg bg-slate-800/60 border border-slate-700/50 p-4 mb-4">
                      <div className="flex items-center justify-between mb-3">
                        <h4 className="font-bold text-white">Detail Slot {selectedSlot}</h4>
                        <button
                          onClick={() => setSelectedSlot(null)}
                          className="text-slate-500 hover:text-slate-400"
                        >
                          ✕
                        </button>
                      </div>
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-slate-500">Status:</span>
                          <span className="font-semibold text-slate-300">{STATUS_MAP[SLOTS.find(s => s.id === selectedSlot)?.status || "empty"].label}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-slate-500">Sensor ID:</span>
                          <span className="font-mono text-slate-400">SEN-{activeTerminal + 1}-{selectedSlot}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-slate-500">Last Update:</span>
                          <span className="font-mono text-slate-400">{time}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-slate-500">Signal:</span>
                          <span className="text-emerald-400">● Excellent</span>
                        </div>
                      </div>
                    </div>
                  </Reveal>
                )}

                {/* Legend */}
                <div className="flex items-center gap-6 pt-4 border-t border-slate-800">
                  {Object.entries(STATUS_MAP).map(([key, val]) => (
                    <div key={key} className="flex items-center gap-2">
                      <div className={`w-3 h-3 rounded-full ${val.color}`} />
                      <span className="text-xs text-slate-400">{val.label}</span>
                    </div>
                  ))}
                </div>
              </div>
            </Reveal>

            {/* Side Stats - Enhanced with terminal info */}
            <Reveal delay={0.4}>
              <div className="space-y-6">
                {/* Terminal Features Card */}
                <div className="rounded-2xl border border-slate-800 bg-slate-900/60 backdrop-blur-sm p-6">
                  <p className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-4">Terminal Features</p>
                  <div className="space-y-3">
                    {currentTerminal.features.map((feature) => (
                      <div key={feature} className="flex items-start gap-3">
                        <CheckCircle2 className="h-4 w-4 text-emerald-400 flex-shrink-0 mt-0.5" />
                        <span className="text-sm text-slate-300">{feature}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Occupancy Card */}
                <div className="rounded-2xl border border-slate-800 bg-slate-900/60 backdrop-blur-sm p-6">
                  <p className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-4">Occupancy Rate</p>
                  <div className="relative w-36 h-36 mx-auto mb-4">
                    <svg className="w-full h-full -rotate-90" viewBox="0 0 120 120">
                      <circle cx="60" cy="60" r="50" stroke="currentColor" className="text-slate-800" strokeWidth="10" fill="none" />
                      <circle cx="60" cy="60" r="50" stroke="url(#grad)" strokeWidth="10" fill="none" strokeLinecap="round"
                        strokeDasharray={`${62.8 * 3.14} ${100 * 3.14}`} />
                      <defs>
                        <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="0%">
                          <stop offset="0%" stopColor="#3b82f6" />
                          <stop offset="100%" stopColor="#06b6d4" />
                        </linearGradient>
                      </defs>
                    </svg>
                    <div className="absolute inset-0 flex items-center justify-center">
                      <span className="text-3xl font-extrabold text-white">62<span className="text-lg text-slate-400">%</span></span>
                    </div>
                  </div>
                </div>

                {/* Stats List */}
                <div className="rounded-2xl border border-slate-800 bg-slate-900/60 backdrop-blur-sm p-6 space-y-4">
                  {[
                    { label: "Total Slots", value: "156", icon: <CircleParking className="h-4 w-4 text-blue-400" /> },
                    { label: "Terisi", value: "98", icon: <Car className="h-4 w-4 text-red-400" /> },
                    { label: "Kosong", value: "45", icon: <CheckCircle2 className="h-4 w-4 text-emerald-400" /> },
                    { label: "Reserved", value: "13", icon: <Lock className="h-4 w-4 text-amber-400" /> },
                  ].map((item) => (
                    <div key={item.label} className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        {item.icon}
                        <span className="text-sm text-slate-400">{item.label}</span>
                      </div>
                      <span className="text-lg font-bold text-white">{item.value}</span>
                    </div>
                  ))}
                </div>
              </div>
            </Reveal>
          </div>
        </div>
      </section>

      {/* ══════════════════════ HOW IT WORKS FLOW ══════════════════════ */}
      <section className="py-24 md:py-32 relative">
        <div className="absolute inset-0 bg-gradient-to-b from-emerald-950/10 via-transparent to-transparent -z-10" />
        <div className="max-w-7xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-20">
              <p className="text-sm font-bold text-emerald-400 uppercase tracking-widest mb-3">Cara Kerja Sistem</p>
              <h2 className="text-3xl md:text-5xl font-extrabold mb-4">
                <span className="bg-gradient-to-r from-white to-slate-400 bg-clip-text text-transparent">
                  6 Langkah Mudah Gunakan PARKIRIN
                </span>
              </h2>
              <p className="text-slate-400 max-w-2xl mx-auto text-lg">
                Dari pembukaan aplikasi hingga check-out otomatis, semuanya dirancang untuk kemudahan maksimal.
              </p>
            </div>
          </Reveal>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {HOW_IT_WORKS.map((item, i) => (
              <Reveal key={item.step} delay={i * 0.08}>
                <div className="relative">
                  {/* Step Number Badge */}
                  <div className="absolute -top-6 -left-4 w-14 h-14 rounded-full bg-gradient-to-br from-emerald-500 to-cyan-500 flex items-center justify-center text-white font-extrabold text-xl shadow-lg">
                    {item.step}
                  </div>
                  
                  {/* Card */}
                  <div className="rounded-2xl border border-slate-800 bg-slate-900/40 backdrop-blur-sm p-8 h-full pt-12 hover:bg-slate-900/60 transition-all hover:border-slate-700">
                    <div className="text-emerald-400 mb-4">
                      {item.icon}
                    </div>
                    <h3 className="text-lg font-bold text-white mb-3">{item.title}</h3>
                    <p className="text-sm text-slate-400 leading-relaxed">{item.desc}</p>
                  </div>

                  {/* Connector Line (hidden on last) */}
                  {i < HOW_IT_WORKS.length - 1 && (
                    <div className="hidden lg:block absolute top-24 -right-4 w-8 h-0.5 bg-gradient-to-r from-emerald-500/40 to-transparent" />
                  )}
                </div>
              </Reveal>
            ))}
          </div>

          {/* Additional CTA */}
          <Reveal delay={0.6}>
            <div className="mt-16 text-center">
              <p className="text-slate-400 mb-6">Proses yang cepat, transparan, dan aman untuk pengalaman parkir bandara terbaik.</p>
              <Link href="/login">
                <button className="inline-flex items-center gap-2 px-8 py-4 bg-gradient-to-r from-emerald-600 to-cyan-500 text-white font-bold rounded-xl text-lg hover:from-emerald-500 hover:to-cyan-400 transition-all shadow-lg shadow-emerald-600/20">
                  Coba Sekarang Gratis
                  <ArrowRight className="h-5 w-5" />
                </button>
              </Link>
            </div>
          </Reveal>
        </div>
      </section>

      {/* ══════════════════════ CCTV MONITORING ══════════════════════ */}
      <section className="py-24 md:py-32">
        <div className="max-w-7xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-16">
              <p className="text-sm font-bold text-indigo-400 uppercase tracking-widest mb-3">Surveillance System</p>
              <h2 className="text-3xl md:text-5xl font-extrabold mb-4">
                <span className="bg-gradient-to-r from-white to-slate-400 bg-clip-text text-transparent">
                  CCTV Monitoring Terintegrasi
                </span>
              </h2>
              <p className="text-slate-400 max-w-2xl mx-auto text-lg">
                Pengawasan 24/7 dengan kamera HD di setiap zona parkir. Pantau keamanan kendaraan Anda dari mana saja.
              </p>
            </div>
          </Reveal>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {CCTV_FEEDS.map((feed, i) => (
              <Reveal key={feed.cam} delay={i * 0.1}>
                <div 
                  onClick={() => setSelectedCctv(i)}
                  className={`group rounded-2xl border transition-all cursor-pointer overflow-hidden hover:border-slate-600 ${
                    selectedCctv === i 
                      ? "bg-slate-900 border-cyan-500/50 ring-2 ring-cyan-500/20" 
                      : "bg-slate-900/60 border-slate-800 hover:bg-slate-900/70"
                  }`}
                >
                  {/* Camera Feed Placeholder */}
                  <div className="relative aspect-video bg-slate-950 overflow-hidden group-hover:bg-slate-900/50 transition-colors">
                    {/* Scan effect */}
                    <div className="absolute inset-0 bg-gradient-to-b from-transparent via-blue-500/5 to-transparent scan-line" />
                    {/* Grid overlay */}
                    <div className="absolute inset-0 opacity-10" style={{ backgroundImage: "linear-gradient(rgba(255,255,255,.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.1) 1px, transparent 1px)", backgroundSize: "20px 20px" }} />
                    {/* Camera icon */}
                    <div className="absolute inset-0 flex items-center justify-center">
                      <Camera className="h-12 w-12 text-slate-700 group-hover:text-slate-600 transition-colors" />
                    </div>
                    {/* LIVE badge */}
                    <div className="absolute top-3 left-3 flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-red-600/90 backdrop-blur-sm">
                      <div className="w-2 h-2 rounded-full bg-white slot-pulse" />
                      <span className="text-[10px] font-bold text-white tracking-wider">LIVE</span>
                    </div>
                    {/* Timestamp */}
                    <div className="absolute bottom-3 right-3 px-2 py-1 rounded bg-black/60 backdrop-blur-sm">
                      <span className="text-[10px] text-slate-300 font-mono">{time}</span>
                    </div>
                    {/* Camera ID */}
                    <div className="absolute top-3 right-3 px-2 py-1 rounded bg-black/60 backdrop-blur-sm">
                      <span className="text-[10px] text-slate-400 font-mono">{feed.cam}</span>
                    </div>
                  </div>
                  {/* Info */}
                  <div className="p-4">
                    <p className="text-sm font-bold text-white mb-2">{feed.name}</p>
                    <div className="space-y-1.5">
                      <div className="flex items-center justify-between text-[10px]">
                        <span className="text-slate-500">Resolution:</span>
                        <span className="text-slate-400 font-mono">{feed.resolution}</span>
                      </div>
                      <div className="flex items-center justify-between text-[10px]">
                        <span className="text-slate-500">View Angle:</span>
                        <span className="text-slate-400 font-mono">{feed.angle}</span>
                      </div>
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-1.5">
                          <div className="w-2 h-2 rounded-full bg-emerald-500 slot-pulse" />
                          <span className="text-[10px] text-emerald-400 font-medium uppercase">Online</span>
                        </div>
                        <span className="text-[10px] text-slate-500">24/7</span>
                      </div>
                    </div>
                  </div>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ══════════════════════ PARTNER & HARDWARE ══════════════════════ */}
      <section className="py-24 md:py-32 relative">
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-indigo-950/10 to-transparent -z-10" />
        <div className="max-w-7xl mx-auto px-6">
          <Reveal>
            <div className="text-center mb-16">
              <p className="text-sm font-bold text-purple-400 uppercase tracking-widest mb-3">Hardware Ecosystem</p>
              <h2 className="text-3xl md:text-5xl font-extrabold mb-4">
                <span className="bg-gradient-to-r from-white to-slate-400 bg-clip-text text-transparent">
                  Teknologi & Hardware Partner
                </span>
              </h2>
              <p className="text-slate-400 max-w-2xl mx-auto text-lg">
                Ekosistem hardware terintegrasi untuk sistem parkir bandara yang andal dan presisi.
              </p>
            </div>
          </Reveal>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              {
                icon: <Radio className="h-8 w-8" />,
                title: "Sensor Ultrasonik Slot",
                desc: "Deteksi kehadiran kendaraan per-slot dengan akurasi 99.5%. Terhubung ke cloud via LoRaWAN.",
                gradient: "from-blue-600 to-cyan-600",
              },
              {
                icon: <MonitorPlay className="h-8 w-8" />,
                title: "IP Camera CCTV HD",
                desc: "Kamera 2MP+ dengan night vision dan wide-angle 180°. Streaming real-time ke dashboard.",
                gradient: "from-indigo-600 to-blue-600",
              },
              {
                icon: <Gauge className="h-8 w-8" />,
                title: "Barrier Gate Controller",
                desc: "Palang otomatis dengan pembaca QR, RFID, dan plate recognition. Buka/tutup < 1.5 detik.",
                gradient: "from-purple-600 to-indigo-600",
              },
              {
                icon: <Zap className="h-8 w-8" />,
                title: "LED Display Signage",
                desc: "Papan informasi digital di setiap zona menampilkan ketersediaan slot real-time dan arah navigasi.",
                gradient: "from-cyan-600 to-emerald-600",
              },
            ].map((hw, i) => (
              <Reveal key={hw.title} delay={i * 0.1}>
                <div className="group rounded-2xl border border-slate-800 bg-slate-900/40 backdrop-blur-sm p-8 text-center hover:bg-slate-900/70 transition-all h-full flex flex-col items-center">
                  <div className={`w-20 h-20 rounded-2xl bg-gradient-to-br ${hw.gradient} flex items-center justify-center text-white mb-6 shadow-xl group-hover:scale-110 transition-transform`}>
                    {hw.icon}
                  </div>
                  <h3 className="text-lg font-bold text-white mb-3">{hw.title}</h3>
                  <p className="text-sm text-slate-400 leading-relaxed">{hw.desc}</p>
                </div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* ══════════════════════ DASHBOARD PREVIEW ══════════════════════ */}
      <section id="dashboard" className="py-24 md:py-32">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            {/* Left - Copy */}
            <Reveal>
              <p className="text-sm font-bold text-blue-400 uppercase tracking-widest mb-3">Admin Dashboard</p>
              <h2 className="text-3xl md:text-5xl font-extrabold mb-6">
                <span className="bg-gradient-to-r from-white to-slate-400 bg-clip-text text-transparent">
                  Dashboard Pengelola Parkir Bandara
                </span>
              </h2>
              <p className="text-lg text-slate-400 mb-8 leading-relaxed">
                Antarmuka pemantauan lengkap untuk pengelola parkir bandara. Lihat occupancy, kelola sensor, 
                pantau CCTV, dan analisa pendapatan dalam satu dashboard terpadu.
              </p>
              <ul className="space-y-4 mb-10">
                {[
                  "Monitoring occupancy real-time per terminal",
                  "Manajemen sensor & kamera CCTV",
                  "Laporan pendapatan & analytics",
                  "Notifikasi keamanan otomatis",
                ].map((item) => (
                  <li key={item} className="flex items-center gap-3">
                    <div className="w-6 h-6 rounded-full bg-blue-500/20 flex items-center justify-center flex-shrink-0">
                      <CheckCircle2 className="h-4 w-4 text-blue-400" />
                    </div>
                    <span className="text-slate-300">{item}</span>
                  </li>
                ))}
              </ul>
              <Link href="/login">
                <button className="inline-flex items-center gap-2 px-8 py-4 bg-gradient-to-r from-blue-600 to-cyan-500 text-white font-bold rounded-xl text-lg hover:from-blue-500 hover:to-cyan-400 transition-all shadow-lg shadow-blue-600/20">
                  Akses Dashboard
                  <ArrowRight className="h-5 w-5" />
                </button>
              </Link>
            </Reveal>

            {/* Right - Dashboard Mockup */}
            <Reveal delay={0.3}>
              <div className="float relative">
                <div className="rounded-2xl border border-slate-800 bg-slate-900/80 backdrop-blur-sm shadow-2xl shadow-blue-500/5 overflow-hidden">
                  {/* Dashboard Top Bar */}
                  <div className="h-10 bg-slate-950 border-b border-slate-800 flex items-center px-4 gap-2">
                    <div className="w-3 h-3 rounded-full bg-red-500" />
                    <div className="w-3 h-3 rounded-full bg-amber-500" />
                    <div className="w-3 h-3 rounded-full bg-emerald-500" />
                    <span className="ml-4 text-xs text-slate-500 font-mono">PARKIRIN Admin Dashboard</span>
                  </div>
                  <div className="p-5">
                    {/* Stats Row */}
                    <div className="grid grid-cols-3 gap-3 mb-4">
                      {[
                        { label: "Total Revenue", value: "Rp 24.5M", icon: <BarChart3 className="h-4 w-4 text-blue-400" /> },
                        { label: "Active Sensors", value: "487/500", icon: <Wifi className="h-4 w-4 text-emerald-400" /> },
                        { label: "Alerts Today", value: "3", icon: <Bell className="h-4 w-4 text-amber-400" /> },
                      ].map((s) => (
                        <div key={s.label} className="bg-slate-800/60 rounded-lg p-3">
                          <div className="flex items-center gap-2 mb-1">
                            {s.icon}
                            <span className="text-[10px] text-slate-500 uppercase">{s.label}</span>
                          </div>
                          <p className="text-sm font-bold text-white">{s.value}</p>
                        </div>
                      ))}
                    </div>
                    {/* Mini Chart */}
                    <div className="bg-slate-800/40 rounded-lg p-4 mb-4">
                      <p className="text-[10px] text-slate-500 uppercase tracking-wider mb-3">Occupancy Rate (7 Days)</p>
                      <div className="flex items-end gap-1.5 h-16">
                        {[65, 72, 58, 80, 75, 82, 68].map((v, i) => (
                          <div
                            key={i}
                            className="flex-1 rounded-t bg-gradient-to-t from-blue-600 to-cyan-500 opacity-80"
                            style={{ height: `${v}%` }}
                          />
                        ))}
                      </div>
                      <div className="flex justify-between mt-2">
                        {["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"].map((d) => (
                          <span key={d} className="text-[8px] text-slate-600 flex-1 text-center">{d}</span>
                        ))}
                      </div>
                    </div>
                    {/* Notification List */}
                    <div className="space-y-2">
                      {[
                        { msg: "Sensor A12 offline — maintenance required", color: "border-amber-500/50" },
                        { msg: "Terminal 2 occupancy > 90%", color: "border-red-500/50" },
                      ].map((n) => (
                        <div key={n.msg} className={`flex items-center gap-3 p-2.5 rounded-lg bg-slate-800/30 border-l-2 ${n.color}`}>
                          <Bell className="h-3 w-3 text-slate-500 flex-shrink-0" />
                          <span className="text-[10px] text-slate-400">{n.msg}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
                {/* Glow */}
                <div className="absolute -inset-6 rounded-3xl bg-gradient-to-r from-blue-500/10 to-cyan-500/10 blur-2xl -z-10" />
              </div>
            </Reveal>
          </div>
        </div>
      </section>

      {/* ══════════════════════ CTA SECTION ══════════════════════ */}
      <section className="py-16 md:py-24 md:py-32 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600/10 via-transparent to-cyan-600/10 -z-10" />
        <Reveal>
          <div className="max-w-4xl mx-auto px-4 md:px-6 text-center">
            <h2 className="text-2xl md:text-5xl font-extrabold mb-4 md:mb-6">
              <span className="bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent">
                Siap Optimalkan Parkir Bandara?
              </span>
            </h2>
            <p className="text-sm md:text-lg text-slate-400 mb-6 md:mb-10 max-w-2xl mx-auto leading-relaxed">
              Bergabunglah dengan sistem parkir bandara terdepan di Indonesia. Setup cepat, integrasi mudah, dukungan 24/7.
            </p>
            <div className="flex flex-col sm:flex-row gap-3 md:gap-4 justify-center">
              <Link href="/login">
                <button className="glow-btn w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 md:px-10 py-3 md:py-5 bg-gradient-to-r from-blue-600 to-cyan-500 text-white font-bold rounded-xl text-sm md:text-lg hover:from-blue-500 hover:to-cyan-400 transition-all">
                  Mulai Sekarang
                  <ArrowRight className="h-4 w-4 md:h-5 md:w-5" />
                </button>
              </Link>
              <Link href="/login">
                <button className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 md:px-10 py-3 md:py-5 border border-slate-700 text-slate-300 font-medium rounded-xl text-sm md:text-lg hover:bg-slate-800/50 hover:border-slate-600 transition-all">
                  Hubungi Sales
                </button>
              </Link>
            </div>
          </div>
        </Reveal>
      </section>

      {/* ══════════════════════ FOOTER ══════════════════════ */}
      <footer className="border-t border-slate-800/50 bg-slate-950">
        <div className="max-w-7xl mx-auto px-6 py-16">
          <div className="grid md:grid-cols-4 gap-12 mb-12">
            <div className="md:col-span-2">
              <Image src="/logo.png" alt="Inapandara Logo" width={500} height={130} className="h-32 w-auto brightness-0 invert opacity-80 mb-4" />
              <p className="text-slate-500 max-w-md leading-relaxed">
                Smart Airport Parking System — Solusi parkir bandara terdepan dengan teknologi sensor IoT dan monitoring CCTV terintegrasi.
              </p>
              <p className="text-sm text-slate-600 mt-4">Trusted by Major Indonesian Airports</p>
            </div>
            <div>
              <h4 className="text-sm font-bold text-white uppercase tracking-wider mb-4">Navigasi</h4>
              <ul className="space-y-3">
                {["Fitur", "Teknologi", "Dashboard", "Login"].map((l) => (
                  <li key={l}>
                    <a href={l === "Login" ? "/login" : `#${l.toLowerCase()}`} className="text-sm text-slate-500 hover:text-white transition-colors">
                      {l}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
            <div>
              <h4 className="text-sm font-bold text-white uppercase tracking-wider mb-4">Sistem</h4>
              <ul className="space-y-3">
                {["Sensor Ultrasonik", "CCTV Monitoring", "Barrier Gate", "LED Signage"].map((l) => (
                  <li key={l}>
                    <span className="text-sm text-slate-500">{l}</span>
                  </li>
                ))}
              </ul>
            </div>
          </div>
          <div className="border-t border-slate-800/50 pt-8 flex flex-col md:flex-row items-center justify-between gap-4">
            <p className="text-sm text-slate-600">© 2026 PARKIRIN — Smart Airport Parking System. All rights reserved.</p>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-emerald-500 slot-pulse" />
              <span className="text-xs text-slate-500">All Systems Operational</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
