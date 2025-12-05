// Type declarations for Deno runtime in Supabase Edge Functions
// These types are available at runtime but may not be recognized by the IDE

declare namespace Deno {
  interface Env {
    get(key: string): string | undefined;
  }
  
  const env: Env;
  
  function serve(
    handler: (req: Request) => Response | Promise<Response>
  ): void;
}

