# 🌾 Verdi Sovereign AI Backend Microservice

Production API microservice for Verdi Agricultural Platform. Implements REST (`/assistant/ask`) and SSE Stream (`/v1/assistant/stream`).

---

## ⚡ 100% Free Quickstart (Groq / Local)

### 1. Install Dependencies
```bash
pip install -r backend/requirements.txt
```

### 2. Get a 100% FREE Groq API Key (Optional)
1. Sign up at [https://console.groq.com](https://console.groq.com) (Takes 30 seconds, zero credit card required).
2. Create an API key.
3. Set the environment variable:
   - **Windows PowerShell:** `$env:GROQ_API_KEY="your_groq_api_key_here"`
   - **Linux / macOS:** `export GROQ_API_KEY="your_groq_api_key_here"`

*(If no key is set, the server cleanly uses the internal agronomy fallback engine so it never crashes!)*

### 3. Run Server Locally
```bash
python -m uvicorn backend.server:app --host 0.0.0.0 --port 3000 --reload
```

---

## 🚀 1-Click Free Hosting (Render.com)

1. Push your repository to GitHub.
2. Go to [Render.com](https://render.com) -> New Web Service.
3. Set:
   - **Environment:** Python 3
   - **Build Command:** `pip install -r backend/requirements.txt`
   - **Start Command:** `uvicorn backend.server:app --host 0.0.0.0 --port $PORT`
   - **Environment Variables:** Add `GROQ_API_KEY` or `OPENAI_API_KEY`
4. Copy your deployed Render URL (e.g., `https://verdi-ai-backend.onrender.com`).
5. Update `lib/core/config/app_config.dart` or run Flutter with:
   ```bash
   flutter run -d chrome --dart-define=BACKEND_URL=https://verdi-ai-backend.onrender.com
   ```
