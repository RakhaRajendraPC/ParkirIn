"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Building, LayoutDashboard, Settings, Map, LogOut, Receipt, Video, Bookmark, Users, Star, AlertTriangle, Wallet } from "lucide-react";
import Image from "next/image";

export default function PartnerLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();

  const handleLogout = () => {
    router.push("/login");
  };

  const navItems = [
    { name: "Overview", href: "/dashboard/partner", icon: <LayoutDashboard className="h-5 w-5" /> },
    { name: "Monitoring", href: "/dashboard/partner/monitoring", icon: <Video className="h-5 w-5" /> },
    { name: "Parking Lots", href: "/dashboard/partner/lots", icon: <Map className="h-5 w-5" /> },
    { name: "Pricing", href: "/dashboard/partner/pricing", icon: <Receipt className="h-5 w-5" /> },
    { name: "Booking", href: "/dashboard/partner/bookings", icon: <Bookmark className="h-5 w-5" /> },
    { name: "Staff", href: "/dashboard/partner/staff", icon: <Users className="h-5 w-5" /> },
    { name: "Keuangan", href: "/dashboard/partner/reports", icon: <Wallet className="h-5 w-5" /> },
    { name: "Review", href: "/dashboard/partner/reviews", icon: <Star className="h-5 w-5" /> },
    { name: "Issue Report", href: "/dashboard/partner/issues", icon: <AlertTriangle className="h-5 w-5" /> },
  ];

  return (
    <div className="flex min-h-screen bg-slate-900 text-slate-100">
      {/* Sidebar Desktop */}
      <aside className="hidden md:flex flex-col w-64 bg-slate-950 border-r border-slate-800 fixed inset-y-0 z-10">
        <div className="p-6 flex items-center gap-2 border-b border-slate-800">
          <Image src="/logo.png" alt="Inapandara Logo" width={420} height={110} className="h-24 w-auto brightness-0 invert" priority />
          <span className="text-blue-500 text-xs ml-1 bg-blue-500/20 px-2 py-1 rounded-full align-middle">PARTNER</span>
        </div>
        <div className="flex-1 py-6 px-4 space-y-2 overflow-y-auto">
          {navItems.map((item) => {
            const isActive = pathname === item.href || (item.href !== "/dashboard/partner" && pathname.startsWith(item.href));
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors ${
                  isActive
                    ? "bg-blue-500/10 text-blue-400"
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
            className="flex w-full items-center gap-3 px-4 py-3 text-slate-400 font-medium rounded-lg hover:bg-slate-800 hover:text-red-400 transition-colors"
          >
            <LogOut className="h-5 w-5" />
            Logout
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 md:ml-64 flex flex-col min-h-screen relative">
        <header className="h-16 bg-slate-950/50 backdrop-blur-md border-b border-slate-800 flex items-center justify-between px-6 sticky top-0 z-10">
          <div className="md:hidden flex items-center gap-2">
            <Image src="/logo.png" alt="Inapandara Logo" width={280} height={75} className="h-16 w-auto brightness-0 invert" />
            <span className="font-bold text-white">PARTNER</span>
          </div>
          <div className="hidden md:block">
            <h2 className="text-sm font-semibold text-slate-400 uppercase tracking-widest">Venue Management System</h2>
          </div>
          <div className="flex items-center gap-3 ml-auto">
            <div className="text-right hidden sm:block">
              <p className="text-sm font-bold text-white">Admin Venue</p>
              <p className="text-xs text-slate-400">Bandara Internasional</p>
            </div>
            <div className="w-10 h-10 rounded-full bg-slate-800 flex items-center justify-center border border-slate-700">
              <Building className="h-5 w-5 text-blue-500" />
            </div>
          </div>
        </header>
        <div className="flex-1 p-6 md:p-8">
          {children}
        </div>
        
        {/* Mobile Bottom Navigation */}
        <nav className="md:hidden fixed bottom-0 inset-x-0 bg-slate-950 border-t border-slate-800 flex items-center justify-around py-3 z-50 px-2 pb-safe">
          {navItems.map((item) => {
             const isActive = pathname === item.href || (item.href !== "/dashboard/partner" && pathname.startsWith(item.href));
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
