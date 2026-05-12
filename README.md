WORLD CUP HUB - DATABASE SERVICE

## 1. Descripción de la base de datos
La base de datos de **Mundial 2026 Hub** fue diseñada en PostgreSQL como parte del proyecto académico de Ingeniería de Software de la Universidad El Bosque.

El sistema tiene como objetivo central ofrecer una plataforma digital para el seguimiento y gestión operativa del Mundial FIFA 2026, integrando funcionalidades orientadas tanto a aficionados como a operadores administrativos.

La base de datos implementa un modelo relacional enfocado en garantizar integridad, trazabilidad y escalabilidad, permitiendo gestionar información relacionada con:

- Usuarios y autenticación
- Preferencias y agendas personalizadas
- Partidos, estadios, selecciones y eventos deportivos
- Notificaciones y comunicaciones operativas
- Gestión de entradas y reservas
- Transferencias y reembolsos con trazabilidad
- Sistema de pollas futboleras y rankings
- Álbum digital de láminas e intercambios entre usuarios
- Registro de eventos auditables y monitoreo del sistema

El diseño incorpora reglas de negocio asociadas al ciclo de vida de las entradas, control de estados, límites de operaciones y registro histórico de acciones relevantes para auditoría y soporte.

La solución fue desarrollada utilizando PostgreSQL debido a sus capacidades avanzadas para manejo de transacciones, integridad referencial, concurrencia y escalabilidad, permitiendo soportar una arquitectura orientada a servicios y preparada para futuras integraciones externas.

## 2. Tecnologías utilizadas

| Tecnología | Descripción |
|---|---|
| PostgreSQL | Sistema de gestión de bases de datos relacional |
| SQL | Lenguaje utilizado para definición y manipulación de datos |
| pgAdmin 4 | Herramienta de administración y monitoreo de PostgreSQL |
| GitHub | Control de versiones y gestión del repositorio |
| Docker | Contenerización y despliegue del entorno de base de datos |

## 3. Estructura del proyecto

```bash
📦 ISWProjectDatabase
 ┣ 📂 DOCUMENTOS
 ┃ ┣ 📄 AnálisisYSelecciónBaseDeDatos
 ┃ ┗ 📄 Documento técnico de infraestructura
 ┃
 ┣ 📂 MODELOS
 ┃ ┣ 📂 ModeloRelacionalBoyce-Scodd
 ┃ ┗ 📄 DiagramaERBoyce-ScoddNF.drawio
 ┃
 ┣ 📂 SQL
 ┃ ┗ 📂 SCHEMA
 ┃    ┗ 📄 creación de tablas.sql
 ┃
 ┗ 📄 README.md
```

## 4. Requisitos del entorno

| Herramienta | Versión |
|---|---|
| PostgreSQL | 17 |
| pgAdmin 4 | 9.4 |
| Docker | 28.0.4 |
| GitHub | Repositorio remoto |
| SQL | Compatible con PostgreSQL |