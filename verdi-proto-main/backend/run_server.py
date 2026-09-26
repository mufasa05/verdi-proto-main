import uvicorn

if __name__ == "__main__":
    print("🚀 Starting Verdi Sovereign AI Backend on http://localhost:3000 ...")
    uvicorn.run("backend.server:app", host="0.0.0.0", port=3000, reload=True)
