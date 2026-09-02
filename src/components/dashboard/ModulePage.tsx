"use client";

import { useState } from "react";
import { Card, CardContent, Button, Input } from "@/components/ui/core";

export type ModuleRow = { name: string; detail: string; status: string; tone?: string };

export default function ModulePage({ title, description, stats, rows, action = "Tambah Data" }: {
  title: string;
  description: string;
  stats: { label: string; value: string }[];
  rows: ModuleRow[];
  action?: string;
}) {
  const [query, setQuery] = useState("");
  const [message, setMessage] = useState("");
  const filteredRows = rows.filter((row) => `${row.name} ${row.detail} ${row.status}`.toLowerCase().includes(query.toLowerCase()));

  return (
    <div className="space-y-6">
      <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
        <div><h1 className="text-3xl font-bold tracking-tight text-white">{title}</h1><p className="mt-1 text-slate-400">{description}</p></div>
        <Button onClick={() => setMessage(`${action} siap diproses`)} className="bg-blue-600 text-white hover:bg-blue-700">{action}</Button>
      </div>
      {message && <p className="text-sm text-emerald-400">{message}</p>}
      <div className="grid grid-cols-2 gap-4 md:grid-cols-4">{stats.map((stat) => <Card key={stat.label} className="border-slate-800 bg-slate-900"><CardContent className="p-5"><p className="text-xs uppercase tracking-wider text-slate-500">{stat.label}</p><p className="mt-2 text-2xl font-black text-white">{stat.value}</p></CardContent></Card>)}</div>
      <Card className="overflow-hidden border-slate-800 bg-slate-900"><div className="border-b border-slate-800 p-4"><Input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Cari data..." className="border-slate-700 bg-slate-950 text-white" /></div><div className="overflow-x-auto"><table className="w-full text-left text-sm text-slate-300"><thead className="bg-slate-950/60 text-xs uppercase text-slate-500"><tr><th className="px-6 py-4">Nama</th><th className="px-6 py-4">Detail</th><th className="px-6 py-4">Status</th><th className="px-6 py-4 text-right">Aksi</th></tr></thead><tbody className="divide-y divide-slate-800">{filteredRows.map((row) => <tr key={`${row.name}-${row.detail}`}><td className="px-6 py-4 font-semibold text-white">{row.name}</td><td className="px-6 py-4">{row.detail}</td><td className={`px-6 py-4 font-semibold ${row.tone || "text-emerald-400"}`}>{row.status}</td><td className="px-6 py-4 text-right"><Button variant="ghost" size="sm" className="text-blue-400">Kelola</Button></td></tr>)}</tbody></table></div></Card>
    </div>
  );
}
