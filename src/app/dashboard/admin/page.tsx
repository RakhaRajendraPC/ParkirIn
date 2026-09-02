"use client";

import { useParkirin } from "@/context/ParkirinContext";
import { Card, CardContent } from "@/components/ui/core";
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const data = [
  { name: 'Mon', revenue: 4000000, bookings: 240 },
  { name: 'Tue', revenue: 3000000, bookings: 139 },
  { name: 'Wed', revenue: 2000000, bookings: 980 },
  { name: 'Thu', revenue: 2780000, bookings: 390 },
  { name: 'Fri', revenue: 1890000, bookings: 480 },
  { name: 'Sat', revenue: 5390000, bookings: 380 },
  { name: 'Sun', revenue: 6490000, bookings: 430 },
];

export default function AdminOverview() {
  const { venues, bookings } = useParkirin();
  
  const totalVenues = venues.length;
  const totalBookings = bookings.length;
  const activeBookings = bookings.filter(b => ["CHECK_IN", "DIPESAN"].includes(b.status)).length;
  // Estimated revenue from mock data
  const revenue = bookings.reduce((acc, b) => acc + (b.totalPrice || 25000), 0);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white tracking-tight">System Overview</h1>
        <p className="text-slate-400 mt-1">Pantau performa seluruh platform Inapandara.</p>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <StatCard title="Total Pendapatan" value={`Rp ${(revenue || 15450000).toLocaleString('id-ID')}`} color="border-emerald-500/50" text="text-emerald-400" />
        <StatCard title="Total Lokasi" value={totalVenues.toString()} color="border-blue-500/50" text="text-blue-400" />
        <StatCard title="Total Booking" value={(totalBookings || 1243).toString()} color="border-purple-500/50" text="text-purple-400" />
        <StatCard title="Booking Aktif" value={(activeBookings || 42).toString()} color="border-orange-500/50" text="text-orange-400" />
      </div>

      <Card className="bg-slate-900 border-slate-800">
        <div className="p-6 border-b border-slate-800 flex justify-between items-center">
          <h2 className="text-lg font-bold text-white">Pendapatan Mingguan</h2>
        </div>
        <CardContent className="p-6 h-[400px]">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={data}>
              <defs>
                <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                  <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" vertical={false} />
              <XAxis dataKey="name" stroke="#64748b" tickLine={false} axisLine={false} />
              <YAxis 
                stroke="#64748b" 
                tickLine={false} 
                axisLine={false}
                tickFormatter={(value) => `Rp ${value/1000000}M`}
              />
              <Tooltip 
                contentStyle={{ backgroundColor: '#0f172a', borderColor: '#1e293b', color: '#f8fafc', borderRadius: '8px' }}
                itemStyle={{ color: '#60a5fa' }}
                formatter={(value: any) => [`Rp ${Number(value).toLocaleString('id-ID')}`, 'Pendapatan']}
              />
              <Area type="monotone" dataKey="revenue" stroke="#3b82f6" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
            </AreaChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  );
}

function StatCard({ title, value, color, text }: { title: string; value: string; color: string, text: string }) {
  return (
    <Card className={`bg-slate-900 border ${color} shadow-lg shadow-black/20`}>
      <CardContent className="p-6">
        <p className="text-xs font-bold text-slate-400 mb-2 uppercase tracking-wider">{title}</p>
        <p className={`text-2xl md:text-3xl font-black ${text} truncate`}>{value}</p>
      </CardContent>
    </Card>
  );
}
