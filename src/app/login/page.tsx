"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useParkirin } from "@/context/ParkirinContext";
import { Role } from "@/types";
import { Button, Input, Card, CardContent, CardHeader, CardTitle } from "@/components/ui/core";
import Link from "next/link";
import { Car } from "lucide-react";
import Image from "next/image";

export default function LoginPage() {
  const router = useRouter();
  const { setRole } = useParkirin();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // Default mock login goes to admin dashboard
    setRole("ADMIN");
    router.push("/dashboard/admin");
  };

  const handleDemoSwitch = (r: Role) => {
    setRole(r);
    router.push(`/dashboard/${r.toLowerCase()}`);
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center p-6">
      <Link href="/" className="flex items-center gap-2 mb-8">
        <Image src="/logo.png" alt="Inapandara Logo" width={420} height={110} className="h-28 w-auto brightness-0" priority />
      </Link>
      
      <Card className="w-full max-w-md mb-8">
        <CardHeader>
          <CardTitle className="text-2xl text-center">Masuk ke Akun Anda</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleLogin} className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-700">Email</label>
              <Input 
                type="email" 
                placeholder="nama@email.com" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <div className="flex justify-between items-center">
                <label className="text-sm font-medium text-slate-700">Password</label>
                <a href="#" className="text-sm text-blue-600 hover:underline">Lupa password?</a>
              </div>
              <Input 
                type="password" 
                placeholder="••••••••" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            <div className="flex items-center gap-2">
              <input type="checkbox" id="remember" className="rounded text-blue-600 focus:ring-blue-500" />
              <label htmlFor="remember" className="text-sm text-slate-600">Ingat saya</label>
            </div>
            <Button type="submit" className="w-full">Login</Button>
            
          </form>
        </CardContent>
      </Card>

      {/* Demo Role Switcher */}
      <div className="w-full max-w-md p-6 bg-slate-100 rounded-xl border border-slate-200">
        <h3 className="text-sm font-bold text-slate-900 mb-3 text-center uppercase tracking-wider">Demo Role Switcher</h3>
        <p className="text-xs text-slate-500 mb-4 text-center">Bypass login dan langsung masuk sebagai peran tertentu untuk demo prototype.</p>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
          <Button variant="secondary" size="sm" onClick={() => handleDemoSwitch("PARTNER")}>Partner</Button>
          <Button variant="secondary" size="sm" onClick={() => handleDemoSwitch("GATE")}>Gate Staff</Button>
          <Button variant="secondary" size="sm" className="bg-blue-600 text-white hover:bg-blue-700" onClick={() => handleDemoSwitch("ADMIN")}>Admin</Button>
        </div>
      </div>
    </div>
  );
}
