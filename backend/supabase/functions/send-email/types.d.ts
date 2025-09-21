// Declaraciones de tipos para Supabase Edge Functions
declare global {
  namespace Deno {
    interface Env {
      get(key: string): string | undefined;
    }
    
    const env: Env;
    
    function serve(handler: (req: Request) => Response | Promise<Response>): void;
  }
}

export {};
