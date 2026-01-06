# go-test-api

API de prueba escrita en Go para el proyecto **punk-records**.

El objetivo de este servicio es:
- aprender el patrón de backends en punk-records
- comparar implementaciones en distintos lenguajes
- servir como referencia mínima (hello-world API)

---

## Endpoints

### `GET /health`

Respuesta de ejemplo:
```json
{
  "status": "ok",
  "service": "go-test-api"
}
Arquitectura
Lenguaje: Go

Runtime: Docker

Puerto interno: 8080

Acceso: solo vía reverse proxy (Caddy)

El servicio no expone puertos directamente al exterior.

Estructura del proyecto

go-test-api/
├── app/          # código Go
├── docker/       # Dockerfile
├── update.sh     # CI/CD local-first (pull + build)
├── deploy.sh     # levantar/recrear el container
└── README.md
CI/CD (local-first)
El servidor:

ejecuta update.sh periódicamente (cron)

hace git pull

build del container

ejecuta deploy.sh

No se usan webhooks ni GitHub Actions para deploy.

Desarrollo local
Ejecutar sin Docker:

Copiar código
cd app
go run main.go
Ejecutar con Docker:

Copiar código
docker build -t go-test-api:local -f docker/Dockerfile .
docker run --rm -p 8080:8080 go-test-api:local
Probar:

http://localhost:8080/health

