# =====================================
# This file is part of the CodeDev project
# Author: Ricel Quispe
# =====================================

# revlogica-data-validation/Dockerfile

# ---------- Tools providers ----------
# BusyBox gives us a tiny wget (no shell required)
FROM busybox:1.36.1-uclibc AS bb

# curl + its deps (and certs)
FROM curlimages/curl:8.10.1 AS curlsrc


# ---------- FastAPI app image ----------

# Use a lean Python base image.
FROM python:3.13-slim AS fastapi

# Set the initial working directory to the project root inside the container.
WORKDIR /app

# Install system dependencies (curl + CA certificates)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy the poetry configuration files into the container.
COPY ./pyproject.toml ./poetry.lock* ./

# Install the project's production dependencies.
RUN pip install poetry && poetry install --no-root --only main

# Copy the rest of the application code into the container.
COPY ./app ./app

# Set the working directory to the inner app folder where manage.py is located.
WORKDIR /app

# Expose the application's port.
EXPOSE 8002

# Command to run the Django application.
CMD ["poetry", "run", "python", "app/manage.py", "runserver", "0.0.0.0:8002"]


