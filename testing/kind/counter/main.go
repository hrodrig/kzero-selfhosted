// Lab HTTP counter: each increment inserts a row into public.e2e_scratch; count is SELECT COUNT(*).
// The kind e2e pre-down hook truncates this table so the counter returns to zero after kzero reset.
package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/lib/pq"
)

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func dataSourceName() string {
	host := getenv("PGHOST", "postgres")
	port := getenv("PGPORT", "5432")
	user := getenv("PGUSER", "app")
	pass := getenv("PGPASSWORD", "e2e")
	db := getenv("PGDATABASE", "app")
	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, pass, db)
}

var (
	db   *sql.DB
	tmpl = template.Must(template.New("home").Parse(homeHTML))
)

func ensureSchema(ctx context.Context) error {
	_, err := db.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS public.e2e_scratch (
		id         bigserial primary key,
		note       text not null default '',
		created_at timestamptz not null default now()
	)`)
	return err
}

func countRows(ctx context.Context) (int64, error) {
	var n int64
	err := db.QueryRowContext(ctx, `SELECT COUNT(*) FROM public.e2e_scratch`).Scan(&n)
	return n, err
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		http.Error(w, "db down", http.StatusServiceUnavailable)
		return
	}
	if err := ensureSchema(ctx); err != nil {
		http.Error(w, "schema", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte("ok"))
}

func handleAPI(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()
	n, err := countRows(ctx)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]int64{"count": n})
}

func handleIncrement(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()
	if _, err := db.ExecContext(ctx, `INSERT INTO public.e2e_scratch (note) VALUES ($1)`, "increment"); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func handleHome(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()
	n, err := countRows(ctx)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	_ = tmpl.Execute(w, struct{ Count int64 }{Count: n})
}

const homeHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>kzero e2e lab counter</title>
  <style>
    :root { color-scheme: light dark; --bg: #0f1419; --card: #1a2332; --text: #e7ecf3; --muted: #8b9cb3; --accent: #3d8bfd; --accent-hover: #5ba3ff; --border: #2a3647; }
    @media (prefers-color-scheme: light) {
      :root { --bg: #f4f6f9; --card: #fff; --text: #1a2332; --muted: #5c6b7f; --accent: #0b57d0; --accent-hover: #0842a0; --border: #d8dee9; }
    }
    * { box-sizing: border-box; }
    body { font-family: system-ui, Segoe UI, Roboto, sans-serif; margin: 0; min-height: 100vh; background: var(--bg); color: var(--text); line-height: 1.5; }
    main { max-width: 28rem; margin: 2rem auto; padding: 0 1rem; }
    .card {
      background: var(--card); border: 1px solid var(--border); border-radius: 12px;
      padding: 1.5rem; box-shadow: 0 4px 24px rgba(0,0,0,.12);
    }
    h1 { font-size: 1.25rem; font-weight: 600; margin: 0 0 1rem; letter-spacing: -0.02em; }
    .count-row { display: flex; align-items: baseline; justify-content: space-between; gap: 1rem; flex-wrap: wrap; }
    .count-label { color: var(--muted); font-size: .875rem; }
    .count-value { font-variant-numeric: tabular-nums; font-size: 2.25rem; font-weight: 700; letter-spacing: -0.03em; }
    code { font-size: .8em; background: var(--bg); padding: .15em .4em; border-radius: 4px; border: 1px solid var(--border); }
    p.hint { color: var(--muted); font-size: .8125rem; margin: 1rem 0 0; }
    form { margin-top: 1.25rem; }
    button {
      appearance: none; font: inherit; cursor: pointer; width: 100%;
      padding: .65rem 1rem; border-radius: 8px; border: none;
      background: var(--accent); color: #fff; font-weight: 600;
    }
    button:hover { background: var(--accent-hover); }
    button:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
    footer { margin-top: 1.25rem; padding-top: 1rem; border-top: 1px solid var(--border); font-size: .75rem; color: var(--muted); }
    footer a { color: var(--accent); }
  </style>
</head>
<body>
  <main id="lab-app" data-e2e-count="{{ .Count }}">
    <div class="card">
      <h1>Lab counter</h1>
      <div class="count-row">
        <span class="count-label">Rows in <code>public.e2e_scratch</code></span>
        <span class="count-value" aria-live="polite">{{ .Count }}</span>
      </div>
      <p class="hint">Each click adds one row. After a kzero <strong>down</strong> (Postgres pre-hook), the table is truncated and this value returns to <strong>0</strong>.</p>
      <form method="post" action="/increment">
        <button type="submit" name="go" value="1">Increment</button>
      </form>
      <footer>Optional: <a href="/api/count"><code>GET /api/count</code></a> (JSON) for debugging.</footer>
    </div>
  </main>
</body>
</html>
`

func main() {
	addr := ":" + getenv("PORT", "8080")
	var err error
	db, err = sql.Open("postgres", dataSourceName())
	if err != nil {
		log.Fatal(err)
	}
	db.SetMaxOpenConns(8)
	db.SetConnMaxLifetime(5 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	for i := 0; i < 60; i++ {
		if err = db.PingContext(ctx); err == nil {
			break
		}
		log.Printf("waiting for postgres: %v", err)
		time.Sleep(time.Second)
	}
	if err != nil {
		log.Fatalf("postgres: %v", err)
	}
	if err := ensureSchema(ctx); err != nil {
		log.Fatalf("schema: %v", err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", handleHealth)
	mux.HandleFunc("/api/count", handleAPI)
	mux.HandleFunc("/increment", handleIncrement)
	mux.HandleFunc("/", handleHome)

	srv := &http.Server{
		Addr:              addr,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}
	log.Printf("listening on %s", addr)
	if err := srv.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}
