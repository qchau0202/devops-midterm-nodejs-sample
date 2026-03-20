# Product API + UI (Express + MongoDB, fallback in-memory)

> **Note:** This project is provided as a reference foundation for students performing their midterm presentations in the course **502094 - Software Deployment, Operations And Maintenance** (compiled by M.Sc. Mai Văn Mạnh). Students are not required to use this exact project — you may choose or build an equivalent (or more complex) project using other languages or frameworks if desired.

This is a sample project organized according to the MVC (Model — View — Controller) pattern built with Node.js + Express, using MongoDB (Mongoose) for product data storage. If the server cannot connect to MongoDB during startup (3s timeout), the application will automatically switch to using an `in-memory` datastore and continue running.

**Key Features**
- Full REST API for Product management: CRUD (GET/POST/PUT/PATCH/DELETE).
- Server-side rendered UI using `EJS` combined with `Bootstrap` for product management (interface at `/`).
- Each JSON response includes `hostname` and `source` information (whether data is being retrieved from `mongodb` or `in-memory`).
- Support for product image uploads: images are saved to disk in `public/uploads/` and the `imageUrl` field in the product stores the relative path (`/uploads/<filename>`).
- When updating or deleting a product, the old image file (located in `/uploads/`) will be deleted from the disk.
- Upon startup, if the MongoDB connection is successful and the collection is empty, the application will automatically seed 10 sample Apple products into MongoDB.

**Main Structure**
- `main.js` — entrypoint: connects to MongoDB (3s timeout), falls back to in-memory, and launches Express.
- `models/product.js` — Mongoose schema (`name`, `price`, `color`, `description`, `imageUrl`).
- `services/dataSource.js` — abstraction layer between MongoDB and in-memory (seeding, CRUD, file deletion when necessary).
- `controllers/` — controllers handling request/response logic.
- `routes/` — routes for the API (`/products`) and UI (`/`).
- `views/` — `EJS` templates for the UI.
- `public/` — static files: CSS, JS, `uploads/` (images are stored here).

**Requirements & Configuration**
- Node.js 16+ (or compatible version) and `npm`.
- Environment file `.env` (sample file already in the repo):

```text
PORT=3000
MONGO_URI=mongodb://localhost:27017/products_db
```

If you want to connect to a MongoDB instance with a username/password, adjust the `MONGO_URI` accordingly.

**Installation & Running Locally**
1. Install dependencies:

```bash
cd /sample-midterm-node.js-project
npm install
```

2. Start the server:

```bash
# Run for production (node)
npm start

# Or development mode with nodemon
npm run dev
```

3. Open your browser at: `http://localhost:3000/` — the UI page will display the product list and provide Add / Edit / Delete operations.

**API (JSON) — Main Endpoints**
- `GET /products` — retrieve product list.
- `GET /products/:id` — retrieve details for one product.
- `POST /products` — create new product. Supports multipart form-data for image uploads (file field: `imageFile`) and text fields: `name`, `price`, `color`, `description`.
- `PUT /products/:id` — replace the entire product. Supports file upload via multipart.
- `PATCH /products/:id` — partial update. Supports file upload via multipart.
- `DELETE /products/:id` — delete product and its corresponding image file if stored in `/uploads/`.

Example of creating a product (curl, file upload):

```bash
curl -X POST -F "name=My Device" -F "price=199" -F "color=black" -F "description=Note" -F "imageFile=@/path/to/photo.jpg" http://localhost:3000/products
```

Note: The UI on the homepage uses fetch + FormData to send files, so no changes are needed if you use the interface.

**Important Behavior**
- Upon startup, `main.js` attempts to connect to MongoDB with `serverSelectionTimeoutMS: 3000`. If it fails, the application logs the error and uses `in-memory` storage for the duration of the process lifecycle.
- When MongoDB connects successfully and the `products` collection is empty, the repository will seed 10 sample Apple products (with default `name`, `price`, `color`, `description`, and an empty `imageUrl`).
- Images are stored on disk at `public/uploads/` and served statically by Express; the path stored in the DB is relative (`/uploads/<filename>`).
- When updating a new image for a product, the old file (if it exists and is located in `/uploads/`) will be deleted.

**Limitations & Recommendations**
- Currently, the server allows file uploads and saves them directly to the disk — this is suitable for demos and development environments but is not optimal for production (in terms of backup, scaling, and bandwidth). For production environments, cloud storage (S3/Cloudinary) should be used, with only the URL stored in the DB.
- Consider adding file size limits and MIME type checks for better security. I can add `multer` configurations to limit size (e.g., 2MB) and whitelist `image/*`.

---
## Automation & Setup

### `scripts/setup.sh`
This script automates the initial server provisioning on **Ubuntu-based systems**. It handles everything from dependency installation to Nginx configuration.

#### **Pre-requisites**
* **Permissions:** The script modifies system files and must be run with `sudo` or as a `root` user.
* **Environment File:** Ensure a `.env` file exists in the **root directory** of the project before running the script.

#### **What it does:**
1.  **Environment Loading:** Automatically sources variables from your `.env` file to configure the environment.
2.  **Package Management:** Updates `apt` packages and installs core tools (`curl`, `git`, `build-essential`, `nginx`).
3.  **Runtime Installation:** Installs **Node.js (v18.x)** and **PM2** globally for process management.
4.  **Nginx Reverse Proxy:** Configures Nginx to forward traffic from `devops-ltc.io.vn` (Port 80) to the local application (Port 3000).
    * Automatically handles symlinks for `sites-enabled` and restarts the service.
5.  **Directory Provisioning:** Creates required application directories at `/opt/my_app` and sets up logging at `/var/log/my_app` with appropriate ownership permissions.

#### **Usage**
To execute the setup, run the following from the project root:
```bash
chmod +x scripts/setup.sh
sudo ./scripts/setup.sh
```
*Logs are captured at `/var/log/setup.log` for troubleshooting.*