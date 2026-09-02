import type { Metadata } from "next";
import "./globals.css";
import { ParkirinProvider } from "@/context/ParkirinContext";

export const metadata: Metadata = {
  title: "PARKIRIN - Smart Airport Parking System",
  description: "Sistem parkir bandara cerdas dengan sensor ultrasonik per-slot dan monitoring CCTV 24/7. Reservasi dari rumah, navigasi presisi ke slot kosong.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="id">
      <body className="bg-slate-50 text-slate-900 min-h-screen">
        <ParkirinProvider>
          {children}
        </ParkirinProvider>
      </body>
    </html>
  );
}
