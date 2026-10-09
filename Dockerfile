FROM python:3.12-slim

# 1. Install uv by copying it from the official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 2. Set the working directory
WORKDIR /app

# 3. Copy configuration files first (helps leverage Docker layer caching)
COPY pyproject.toml uv.lock ./

# 4. Explicitly tell uv to install the declared dependencies
RUN uv sync --frozen --no-cache

# 5. Copy the rest of your application code
COPY . /app

# 6. Run the FastAPI application using the installed environment
CMD ["uv", "run", "main.py", "--port", "8080", "--host", "0.0.0.0"]
