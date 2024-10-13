import type { Metadata } from "next";
import { Providers } from './providers'
import "./globals.css";

export const metadata: Metadata = {
  title: "AutoSwap",
  description: "AutoSwap is a decentralized exchange aggregator that finds the best prices for swapping tokens.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode,
}) {
  return (
    <html lang='en'>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
