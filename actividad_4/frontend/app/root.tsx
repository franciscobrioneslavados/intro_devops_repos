import {
  isRouteErrorResponse,
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  useLoaderData,
} from "react-router";
import { ThemeProvider, createTheme, CssBaseline } from "@mui/material";

import type { Route } from "./+types/root";

declare global {
  interface Window {
    ENV: {
      BACKEND_HOST: string;
    };
  }
}

export async function loader() {
  return {
    ENV: {
      BACKEND_HOST: process.env.BACKEND_HOST || "localhost",
    },
  };
}

const theme = createTheme({
// ... (omitted same lines for brevity in instruction, but replacing the block)
// I will use multi_replace if needed but let's do a clean replace of the top and Layout
  palette: {
    primary: {
      main: "#1976d2",
    },
    secondary: {
      main: "#dc004e",
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
  },
});

export const links: Route.LinksFunction = () => [
  { rel: "preconnect", href: "https://fonts.googleapis.com" },
  {
    rel: "preconnect",
    href: "https://fonts.gstatic.com",
    crossOrigin: "anonymous",
  },
  {
    rel: "stylesheet",
    href: "https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap",
  },
];

export function Layout({ children }: { children: React.ReactNode }) {
  const data = useLoaderData<typeof loader>();

  return (
    <html lang="es">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        <ThemeProvider theme={theme}>
          <CssBaseline />
          {children}
        </ThemeProvider>
        {/* Inyectamos las variables en el objeto window para el navegador */}
        <script
          dangerouslySetInnerHTML={{
            __html: `window.ENV = ${JSON.stringify(data?.ENV || {})}`,
          }}
        />
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}

export default function App() {
  return <Outlet />;
}

export function ErrorBoundary({ error }: Route.ErrorBoundaryProps) {
  let message = "¡Ups!";
  let details = "Ocurrió un error inesperado.";
  let stack: string | undefined;

  if (isRouteErrorResponse(error)) {
    message = error.status === 404 ? "404" : "Error";
    details =
      error.status === 404
        ? "La página solicitada no fue encontrada."
        : error.statusText || details;
  } else if (import.meta.env.DEV && error && error instanceof Error) {
    details = error.message;
    stack = error.stack;
  }

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <main style={{ padding: "2rem", textAlign: "center" }}>
        <h1>{message}</h1>
        <p>{details}</p>
        {stack && (
          <pre style={{ textAlign: "left", padding: "1rem", overflow: "auto" }}>
            <code>{stack}</code>
          </pre>
        )}
      </main>
    </ThemeProvider>
  );
}
