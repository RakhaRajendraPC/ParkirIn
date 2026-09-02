"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Car, LayoutDashboard, MapPin, Bookmark, LogOut, Users, Building2, Tags, Wallet, Star, AlertTriangle, ClipboardList } from "lucide-react";
import Image from "next/image";
import { useParkirin } from "@/context/ParkirinContext";

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { user } = useParkirin();

  const handleLogout = () => {
    router.push("/login");
  };

  const navItems = [
    { name: "Overview", href: "/dashboard/admin", icon: <LayoutDashboard className="h-5 w-5" /> },
    { name: "Lokasi Parkir", href: "/dashboard/admin/venues", icon: <MapPin className="h-5 w-5" /> },
    { name: "Partner", href: "/dashboard/admin/partners", icon: <Building2 className="h-5 w-5" /> },
    { name: "Pricing", href: "/dashboard/admin/pricing", icon: <Tags className="h-5 w-5" /> },
    { name: "Transaksi", href: "/dashboard/admin/bookings", icon: <Bookmark className="h-5 w-5" /> },
    { name: "Keuangan", href: "/dashboard/admin/finance", icon: <Wallet className="h-5 w-5" /> },
    { name: "Pengguna", href: "/dashboard/admin/users", icon: <Users className="h-5 w-5" /> },
    { name: "Review", href: "/dashboard/admin/reviews", icon: <Star className="h-5 w-5" /> },
    { name: "Issue Report", href: "/dashboard/admin/issues", icon: <AlertTriangle className="h-5 w-5" /> },
    { name: "Audit Log", href: "/dashboard/admin/audit", icon: <ClipboardList className="h-5 w-5" /> },
  ];

  return (
    <div className="flex min-h-screen bg-slate-950 text-slate-100">
      {/* Sidebar */}
      <aside className="hidden md:flex flex-col w-64 bg-slate-900 border-r border-slate-800 fixed inset-y-0 z-10">
        <div className="p-6 flex items-center gap-2 border-b border-slate-800">
          <Image src="/logo.png" alt="Inapandara Logo" width={320} height={85} className="h-20 w-auto brightness-0 invert" priority />
          <span className="text-blue-500 text-xs ml-1 bg-blue-500/20 px-2 py-1 rounded-full align-middle">ADMIN</span>
        </div>
        <div className="flex-1 py-6 px-4 space-y-2 overflow-y-auto">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors ${
                  isActive
                    ? "bg-blue-600/10 text-blue-400"
                    : "text-slate-400 hover:bg-slate-800 hover:text-slate-200"
                }`}
              >
                {item.icon}
                {item.name}
              </Link>
            );
          })}
        </div>
        <div className="p-4 border-t border-slate-800">
          <button
            onClick={handleLogout}
            className="flex w-full items-center gap-3 px-4 py-3 text-red-400 font-medium rounded-lg hover:bg-red-500/10 transition-colors"
          >
            <LogOut className="h-5 w-5" />
            Logout
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 md:ml-64 flex flex-col min-h-screen">
        {/* Topbar */}
        <header className="h-16 bg-slate-900/50 backdrop-blur-md border-b border-slate-800 flex items-center justify-between px-6 sticky top-0 z-10">
          <div className="md:hidden flex items-center gap-2">
            <Image src="/logo.png" alt="Inapandara Logo" width={220} height={60} className="h-14 w-auto brightness-0 invert" priority />
            <span className="font-bold text-white">ADMIN</span>
          </div>
          
          <div className="hidden md:flex flex-1"></div>

          <div className="flex items-center gap-4 ml-auto">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-full bg-slate-800 overflow-hidden flex items-center justify-center border border-slate-700">
                <span className="text-blue-400 font-bold text-sm">A</span>
              </div>
              <span className="text-sm font-medium text-slate-300 hidden sm:block">Administrator</span>
            </div>
          </div>
        </header>

        {/* Content Area */}
        <div className="flex-1 p-6 md:p-8">
          {children}
        </div>

        {/* Mobile Bottom Navigation */}
        <nav className="md:hidden fixed bottom-0 inset-x-0 bg-slate-900 border-t border-slate-800 flex items-center justify-around py-3 z-50 px-2 pb-safe">
          {navItems.slice(0, 3).map((item) => {
             const isActive = pathname === item.href;
             return (
               <Link
                 key={item.name}
                 href={item.href}
                 className={`flex flex-col items-center gap-1 ${
                   isActive ? "text-blue-400" : "text-slate-500"
                 }`}
               >
                 {item.icon}
                 <span className="text-[10px] font-medium">{item.name}</span>
               </Link>
             );
          })}
        </nav>
      </main>
    </div>
  );
}
