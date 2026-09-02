"use client";

import { useState, useMemo } from "react";
import { useParkirin } from "@/context/ParkirinContext";
import { Card, Badge, Button } from "@/components/ui/core";
import { User, Search, UserCheck, UserX } from "lucide-react";

export default function AdminUsers() {
  const { users, updateUserStatus } = useParkirin();
  const [searchTerm, setSearchTerm] = useState("");

  const filteredUsers = useMemo(() => {
    if (!searchTerm) return users;
    const lower = searchTerm.toLowerCase();
    return users.filter(
      (u) =>
        u.name.toLowerCase().includes(lower) ||
        u.email.toLowerCase().includes(lower) ||
        u.phone.toLowerCase().includes(lower) ||
        u.id.toLowerCase().includes(lower)
    );
  }, [users, searchTerm]);

  const toggleStatus = (id: string, currentStatus: string) => {
    const newStatus = currentStatus === "ACTIVE" ? "INACTIVE" : "ACTIVE";
    updateUserStatus(id, newStatus);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-white tracking-tight">Pengguna</h1>
          <p className="text-slate-400 mt-1">Kelola data pelanggan dan pengguna aplikasi.</p>
        </div>
      </div>

      <div className="flex items-center gap-2 mb-4 bg-slate-900 border border-slate-800 p-2 rounded-lg">
        <Search className="h-5 w-5 text-slate-500 ml-2" />
        <input 
          type="text" 
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Cari berdasarkan Nama, Email, atau No. Telepon..." 
          className="bg-transparent border-none focus:outline-none focus:ring-0 text-slate-200 w-full placeholder-slate-500"
        />
      </div>

      <Card className="bg-slate-900 border-slate-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="bg-slate-950/50 text-slate-400 uppercase font-semibold text-xs border-b border-slate-800">
              <tr>
                <th className="px-6 py-4">Profil Pengguna</th>
                <th className="px-6 py-4">Kontak</th>
                <th className="px-6 py-4">Kendaraan Terdaftar</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/50">
              {filteredUsers.length > 0 ? filteredUsers.map((user) => (
                <tr key={user.id} className="hover:bg-slate-800/20 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-slate-800 overflow-hidden border border-slate-700 flex items-center justify-center shrink-0">
                        {user.avatar ? (
                          // eslint-disable-next-line @next/next/no-img-element
                          <img src={user.avatar} alt={user.name} className="w-full h-full object-cover" />
                        ) : (
                          <User className="h-5 w-5 text-slate-500" />
                        )}
                      </div>
                      <div>
                        <p className="font-bold text-slate-200">{user.name}</p>
                        <p className="text-xs text-slate-500 font-mono mt-0.5">{user.id}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <p className="font-medium text-slate-300">{user.email}</p>
                    <p className="text-xs text-slate-500 mt-1">{user.phone}</p>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex flex-col gap-1">
                      {user.vehicles.map(v => (
                        <div key={v.id} className="flex items-center gap-2">
                          <Badge variant="outline" className="bg-slate-800 border-slate-700 text-slate-300 font-mono text-xs">
                            {v.plateNumber}
                          </Badge>
                          <span className="text-xs text-slate-500">{v.type === "CAR" ? "Mobil" : "Motor"}</span>
                        </div>
                      ))}
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <Badge variant={user.status === "ACTIVE" ? "success" : "danger"} className={user.status === "ACTIVE" ? "bg-emerald-500/20 text-emerald-400" : ""}>
                      {user.status === "ACTIVE" ? "Aktif" : "Nonaktif"}
                    </Badge>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button 
                      onClick={() => toggleStatus(user.id, user.status as string)}
                      className={`p-2 rounded-lg transition-colors flex items-center justify-center gap-2 text-xs ml-auto border ${
                        user.status === "ACTIVE" 
                        ? "text-red-400 border-red-900 hover:bg-red-950" 
                        : "text-emerald-400 border-emerald-900 hover:bg-emerald-950"
                      }`}
                    >
                      {user.status === "ACTIVE" ? <><UserX className="h-4 w-4"/> Nonaktifkan</> : <><UserCheck className="h-4 w-4"/> Aktifkan</>}
                    </button>
                  </td>
                </tr>
              )) : (
                <tr>
                  <td colSpan={5} className="px-6 py-12 text-center text-slate-500">
                    Tidak ada pengguna yang sesuai dengan pencarian.
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
