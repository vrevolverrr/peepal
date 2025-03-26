// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js';

const supabaseUrl = 'https://vyjzzjnnjqjtkvwsgfqh.supabase.co'
const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5anp6am5uanFqdGt2d3NnZnFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk5Nzc2NTQsImV4cCI6MjA1NTU1MzY1NH0.zyo5M5O5I-bAYmME6uHYWiBX_4CvKXP6DLkw91i1FSE"


console.log("Hello from Functions!")

Deno.serve(async (req) => {
  const { location, radius } = await req.json()
 
  const supabase = createClient(supabaseUrl, supabaseKey)
  const { data, error } = await supabase.from('toilets').select('*')

  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } },
  )
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/hello-world' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
