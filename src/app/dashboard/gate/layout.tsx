"use client";

import { LogOut, ScanLine } from "lucide-react";
import { useRouter } from "next/navigation";
import Image from "next/image";

export default function GateLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();

  return (
    <div className="min-h-screen bg-slate-950 flex flex-col">
      <header className="h-16 px-6 border-b border-slate-800 flex items-center justify-between bg-slate-900">
        <div className="flex items-center gap-3 text-white">
          <Image src="/logo.png" alt="Inapandara Logo" width={320} height={85} className="h-20 w-auto brightness-0 invert" priority />
          <span className="text-blue-500 text-xs ml-2 bg-blue-500/20 px-2 py-1 rounded-full align-middle font-bold tracking-widest uppercase">Gate Kiosk</span>
        </div>
        <div className="flex items-center gap-6">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 bg-blue-500 rounded-full animate-pulse"></span>
            <span className="text-sm font-medium text-slate-400">System Online</span>
          </div>
          <button 
            onClick={() => router.push("/login")}
            className="text-slate-400 hover:text-white transition-colors"
          >
            <LogOut className="h-5 w-5" />
          </button>
        </div>
      </header>
      <main className="flex-1 flex flex-col p-6">
        {children}
      </main>
    </div>
  );
}
