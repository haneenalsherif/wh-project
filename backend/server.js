const express = require("express");
const path = require("path");
const { Pool } = require("pg");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const JWT_SECRET = "mysecretkey";
require("dotenv").config();

function authenticateToken(req, res, next) {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ message: "غير مسجل الدخول" });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ message: "توكن غير صالح أو منتهي" });
    }

    req.user = user;
    next();
  });
}

function requireAdmin(req, res, next) {
  if (!req.user || req.user.role !== "admin") {
    return res.status(403).json({ message: "غير مصرح" });
  }

  next();
}

function requireStoreOwner(req, res, next) {
  if (!req.user || !["store_owner", "admin"].includes(req.user.role)) {
    return res.status(403).json({ message: "غير مصرح لصاحب المتجر" });
  }
  next();
}

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, "..")));
app.use(express.json());

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "..", "index.html"));
});
require("dotenv").config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

pool.connect()
  .then(() => console.log("✅ Connected to PostgreSQL"))
  .catch(err => console.error("❌ Connection error", err));
app.get("/api/test", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");
    res.json(result.rows);
  } catch (err) {
    console.error("REAL ERROR /api/test:", err);
    res.status(500).json({ message: err.message });
  }
});
app.get("/api/stores", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM stores ORDER BY id ASC");
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Database error");
  }
});

app.get("/api/products/:storeId", async (req, res) => {
  try {
    const storeId = req.params.storeId;
    const result = await pool.query(
      "SELECT * FROM products WHERE store_id = $1 ORDER BY id ASC",
      [storeId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Database error");
  }
});

app.get("/api/store-types", async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, name, type_key
       FROM store_types
       ORDER BY id ASC`
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب أنواع المتاجر" });
  }
});


app.get("/api/products/:storeId/:category", async (req, res) => {
  try {
    const { storeId, category } = req.params;

    const result = await pool.query(
      "SELECT * FROM products WHERE store_id = $1 AND category_key = $2 ORDER BY id ASC",
      [storeId, category]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Database error");
  }
});

app.get("/api/store/:storeId/category/:categoryId/products", async (req, res) => {
  try {
    const { storeId, categoryId } = req.params;

    const result = await pool.query(
      "SELECT * FROM products WHERE store_id = $1 AND category_id = $2 ORDER BY id ASC",
      [storeId, categoryId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Database error");
  }
});

app.get("/api/store/:storeId/categories", async (req, res) => {
  try {
    const { storeId } = req.params;

    const result = await pool.query(
      "SELECT * FROM categories WHERE store_id = $1 ORDER BY id ASC",
      [storeId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Database error");
  }
});
app.post("/api/signup", async (req, res) => {
  try {

    const { full_name, phone, email, password } = req.body;

    if (!full_name || !phone || !email || !password) {
      return res.status(400).json({ message: "جميع الحقول مطلوبة" });
    }

    const existingUser = await pool.query(
      "SELECT id FROM users WHERE phone = $1 OR email = $2",
      [phone, email]
    );


    if (existingUser.rows.length > 0) {
      return res.status(409).json({ message: "رقم الهاتف أو البريد مستخدم بالفعل" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (full_name, phone, email, password, role)
       VALUES ($1, $2, $3, $4, 'customer')
       RETURNING id, full_name, phone, email, role`,
      [full_name, phone, email, hashedPassword]
    );


    res.status(201).json({
      message: "تم إنشاء الحساب بنجاح",
      user: result.rows[0]
    });
  } catch (err) {
    console.error("SIGNUP ERROR:", err);
    res.status(500).json({ message: err.message });
  }
});
app.post("/api/login", async (req, res) => {
  try {
    let { phoneOrEmail, password } = req.body;

    // 🔥 ننظف المدخلات
    phoneOrEmail = phoneOrEmail.trim();
    password = password.trim();

    if (!phoneOrEmail || !password) {
      return res.status(400).json({ message: "البيانات ناقصة" });
    }

   const result = await pool.query(
  `SELECT * FROM users WHERE email ILIKE $1 OR phone ILIKE $1`,
  [phoneOrEmail.trim()]
);


    if (result.rows.length === 0) {
      return res.status(401).json({ message: "المستخدم غير موجود" });
    }

    const user = result.rows[0];


    const isMatch = await bcrypt.compare(password, user.password);


    if (!isMatch) {
      return res.status(401).json({ message: "كلمة المرور غلط" });
    }

    const role = user.role || "customer";

    const token = jwt.sign(
      { id: user.id, role: role },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      message: "تم تسجيل الدخول بنجاح",
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        phone: user.phone,
        email: user.email,
        role: role
      }
    });

  } catch (err) {
    console.error("LOGIN ERROR:", err);
    res.status(500).json({ message: "خطأ في السيرفر" });
  }
});

app.get("/api/profile", authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, full_name, phone, email FROM users WHERE id = $1",
      [req.user.id]
    );

    if (!result.rows.length) {
      return res.status(404).json({ message: "المستخدم غير موجود" });
    }

    res.json({ user: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب البيانات" });
  }
});
app.post("/api/orders", authenticateToken, async (req, res) => {
  const client = await pool.connect();

  try {
    const userId = req.user.id;

    const {
      customer_address,
      store_id,
      total_price,
      items,
      payment,
      payment_method,
      delivery_note
    } = req.body;

    const finalPayment = payment_method || payment || "cash";

    if (!customer_address || !store_id || !total_price || !items || !items.length) {
      return res.status(400).json({ message: "بيانات الطلب ناقصة" });
    }

    const userResult = await client.query(
      "SELECT full_name, phone FROM users WHERE id = $1",
      [userId]
    );

    if (!userResult.rows.length) {
      return res.status(404).json({ message: "المستخدم غير موجود" });
    }

    const user = userResult.rows[0];

    await client.query("BEGIN");

    const orderResult = await client.query(
      `INSERT INTO orders
      (user_id, customer_name, customer_phone, customer_address, store_id, total_price, payment_method, delivery_note)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING id`,
      [
        userId,
        user.full_name,
        user.phone,
        customer_address,
        store_id,
        total_price,
        finalPayment,
        delivery_note || ""
      ]
    );

    const orderId = orderResult.rows[0].id;

    for (const item of items) {
      await client.query(
        `INSERT INTO order_items
        (order_id, product_id, product_name, price, qty)
        VALUES ($1, $2, $3, $4, $5)`,
        [
          orderId,
          item.product_id || null,
          item.product_name,
          item.price,
          item.qty
        ]
      );
    }

    await client.query("COMMIT");

    res.status(201).json({
      message: "تم حفظ الطلب بنجاح",
      order_id: orderId
    });

  } catch (err) {
    await client.query("ROLLBACK");
    console.error(err);
    res.status(500).json({ message: "فشل حفظ الطلب" });
  } finally {
    client.release();
  }
});

app.get("/api/orders", authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT orders.*, stores.name AS store_name
       FROM orders
       LEFT JOIN stores ON orders.store_id = stores.id
       WHERE orders.user_id = $1
       ORDER BY orders.id DESC`,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب الطلبات" });
  }
});
app.get("/api/orders/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const orderResult = await pool.query(
      `SELECT orders.*, stores.name AS store_name
       FROM orders
       LEFT JOIN stores ON orders.store_id = stores.id
       WHERE orders.id = $1 AND orders.user_id = $2`,
      [id, userId]
    );

    if (orderResult.rows.length === 0) {
      return res.status(404).json({ message: "الطلب غير موجود" });
    }

    const itemsResult = await pool.query(
      `SELECT * FROM order_items
       WHERE order_id = $1
       ORDER BY id ASC`,
      [id]
    );

    res.json({
      order: orderResult.rows[0],
      items: itemsResult.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب الطلب" });
  }
});
app.get("/api/users/:userId/addresses", authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;

    if (String(userId) !== String(req.user.id)) {
      return res.status(403).json({ message: "غير مصرح" });
    }

    const result = await pool.query(
      "SELECT * FROM addresses WHERE user_id = $1 ORDER BY id DESC",
      [req.user.id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب العناوين" });
  }
});

app.post("/api/users/:userId/addresses", authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { title, details, lat, lng } = req.body;

    if (String(userId) !== String(req.user.id)) {
      return res.status(403).json({ message: "غير مصرح" });
    }

    if (!title || !details) {
      return res.status(400).json({ message: "البيانات ناقصة" });
    }

    const result = await pool.query(
      `INSERT INTO addresses (user_id, title, details, lat, lng)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [req.user.id, title, details, lat || null, lng || null]
    );

    res.status(201).json({
      message: "تم إضافة العنوان بنجاح",
      address: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل إضافة العنوان" });
  }
});

app.put("/api/addresses/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, details, lat, lng } = req.body;

    if (!title || !details) {
      return res.status(400).json({ message: "البيانات ناقصة" });
    }

    const result = await pool.query(
      `UPDATE addresses
       SET title = $1, details = $2, lat = $3, lng = $4
       WHERE id = $5 AND user_id = $6
       RETURNING *`,
      [title, details, lat || null, lng || null, id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "العنوان غير موجود أو غير مصرح" });
    }

    res.json({
      message: "تم تعديل العنوان بنجاح",
      address: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل تعديل العنوان" });
  }
});

app.delete("/api/addresses/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      "DELETE FROM addresses WHERE id = $1 AND user_id = $2 RETURNING id",
      [id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "العنوان غير موجود أو غير مصرح" });
    }

    res.json({ message: "تم حذف العنوان بنجاح" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل حذف العنوان" });
  }
});

app.post("/api/send-reset-link", async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "الإيميل مطلوب" });
    }

    const userResult = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (!userResult.rows.length) {
      return res.status(404).json({ message: "المستخدم غير موجود" });
    }

    const user = userResult.rows[0];
const token = crypto.randomBytes(32).toString("hex");

    await pool.query(
      `UPDATE users
       SET reset_token = $1,
           reset_expires = NOW() + INTERVAL '15 minutes'
       WHERE id = $2`,
      [token, user.id]
    );

    const resetLink = `http://localhost:3000/reset-password.html?token=${token}`;

    console.log("Reset Link:", resetLink);

    res.json({
      message: "تم إرسال الرابط",
      link: resetLink
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل إرسال الرابط" });
  }
});
app.post("/api/reset-password", async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
      return res.status(400).json({ message: "البيانات ناقصة" });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ message: "كلمة المرور قصيرة جدًا" });
    }

    const userResult = await pool.query(
      `SELECT * FROM users
       WHERE reset_token = $1
       AND reset_expires > NOW()`,
      [token]
    );

    if (!userResult.rows.length) {
      return res.status(400).json({ message: "الرابط غير صالح أو منتهي" });
    }

    const user = userResult.rows[0];

   const hashedPassword = await bcrypt.hash(newPassword, 10);

await pool.query(
  `UPDATE users
   SET password = $1,
       reset_token = NULL,
       reset_expires = NULL
   WHERE id = $2`,
  [hashedPassword, user.id]
);
    res.json({ message: "تم تغيير كلمة المرور بنجاح" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل تغيير كلمة المرور" });
  }
});

app.put("/api/users/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, phone, email } = req.body;

    if (String(id) !== String(req.user.id)) {
      return res.status(403).json({ message: "غير مصرح" });
    }

    if (!full_name || !phone || !email) {
      return res.status(400).json({ message: "البيانات ناقصة" });
    }

    const duplicateResult = await pool.query(
      `SELECT id FROM users
       WHERE (phone = $1 OR email = $2)
       AND id <> $3`,
      [phone, email, id]
    );

    if (duplicateResult.rows.length > 0) {
      return res.status(409).json({ message: "رقم الهاتف أو البريد مستخدم بالفعل" });
    }

    const result = await pool.query(
      `UPDATE users
       SET full_name = $1,
           phone = $2,
           email = $3
       WHERE id = $4
       RETURNING id, full_name, phone, email`,
      [full_name, phone, email, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "المستخدم غير موجود" });
    }

    res.json({
      message: "تم تحديث البيانات بنجاح",
      user: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل تحديث البيانات" });
  }
});

/* =========================
   ADMIN HELPERS
========================= */
async function isAdmin(userId) {
  if (!userId) return false;

  const result = await pool.query(
    "SELECT id, role FROM users WHERE id = $1",
    [userId]
  );

  if (result.rows.length === 0) return false;

  return result.rows[0].role === "admin";
}
/* =========================
   ADMIN: STORES
========================= */

// جلب كل المتاجر للأدمن
app.get("/api/admin/stores", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM stores
       ORDER BY id DESC`
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب المتاجر" });
  }
});

// إضافة متجر جديد
app.post("/api/admin/stores", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const {
      name,
      store_type,
      type,
      description,
      image,
      page,
      delivery_fee,
      delivery_time,
      rating,
      is_active
    } = req.body;

    if (!name || !store_type || !image || !page) {
      return res.status(400).json({ message: "البيانات الأساسية ناقصة" });
    }

    const result = await pool.query(
      `INSERT INTO stores
       (name, type, store_type, description, image, page, delivery_fee, delivery_time, rating, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        name,
        type || store_type,
        store_type,
        description || "",
        image,
        page,
        delivery_fee || 0,
        delivery_time || "",
        rating || 4.5,
        is_active ?? true
      ]
    );

    res.status(201).json({
      message: "تم إضافة المتجر بنجاح",
      store: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل إضافة المتجر" });
  }
});

// تعديل متجر
app.put("/api/admin/stores/:id", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      store_type,
      type,
      description,
      image,
      page,
      delivery_fee,
      delivery_time,
      rating,
      is_active
    } = req.body;

    if (!name || !store_type || !image || !page) {
      return res.status(400).json({ message: "البيانات الأساسية ناقصة" });
    }

    const result = await pool.query(
      `UPDATE stores
       SET name = $1,
           type = $2,
           store_type = $3,
           description = $4,
           image = $5,
           page = $6,
           delivery_fee = $7,
           delivery_time = $8,
           rating = $9,
           is_active = $10
       WHERE id = $11
       RETURNING *`,
      [
        name,
        type || store_type,
        store_type,
        description || "",
        image,
        page,
        delivery_fee || 0,
        delivery_time || "",
        rating || 4.5,
        is_active ?? true,
        id
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "المتجر غير موجود" });
    }

    res.json({
      message: "تم تعديل المتجر بنجاح",
      store: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل تعديل المتجر" });
  }
});

// حذف متجر
app.delete("/api/admin/stores/:id", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      "DELETE FROM stores WHERE id = $1 RETURNING id",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "المتجر غير موجود" });
    }

    res.json({ message: "تم حذف المتجر بنجاح" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل حذف المتجر" });
  }
});
/* =========================
   ADMIN: ADMINS
========================= */

// جلب الأدمنات
app.get("/api/admin/admins", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, full_name, phone, email, created_at
       FROM users
       WHERE role = 'admin'
       ORDER BY id DESC`
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب الأدمنات" });
  }
});

// إضافة أدمن جديد
app.post("/api/admin/admins", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { full_name, phone, email, password } = req.body;

    if (!full_name || !phone || !email || !password) {
      return res.status(400).json({ message: "البيانات ناقصة" });
    }

    const existingUser = await pool.query(
      "SELECT id FROM users WHERE phone = $1 OR email = $2",
      [phone, email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({ message: "رقم الهاتف أو البريد مستخدم بالفعل" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (full_name, phone, email, password, role)
       VALUES ($1, $2, $3, $4, 'admin')
       RETURNING id, full_name, phone, email, role, created_at`,
      [full_name, phone, email, hashedPassword]
    );

    res.status(201).json({
      message: "تمت إضافة الأدمن بنجاح",
      admin: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل إضافة الأدمن" });
  }
});

// حذف أدمن
app.delete("/api/admin/admins/:id", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    if (String(id) === String(req.user.id)) {
      return res.status(400).json({ message: "لا يمكنك حذف نفسك" });
    }

    const result = await pool.query(
      "DELETE FROM users WHERE id = $1 AND role = 'admin' RETURNING id",
      [id]
    );

    if (!result.rows.length) {
      return res.status(404).json({ message: "الأدمن غير موجود" });
    }

    res.json({ message: "تم حذف الأدمن بنجاح" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل حذف الأدمن" });
  }
});
/* =========================
   ADMIN: ORDERS
========================= */

// جلب كل الطلبات للأدمن
app.get("/api/admin/orders", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT o.*, s.name AS store_name
       FROM orders o
       LEFT JOIN stores s ON o.store_id = s.id
       ORDER BY o.id DESC`
    );

    const orders = result.rows;

    for (const order of orders) {
      const itemsResult = await pool.query(
        `SELECT product_name, qty
         FROM order_items
         WHERE order_id = $1
         ORDER BY id ASC`,
        [order.id]
      );

      order.items = itemsResult.rows;
    }

    res.json(orders);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب الطلبات" });
  }
});

// تحديث حالة الطلب للأدمن
app.put("/api/admin/orders/:id/status", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const allowedStatuses = ["pending", "preparing", "delivering", "delivered"];

    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({ message: "حالة غير صالحة" });
    }

    const result = await pool.query(
      `UPDATE orders
       SET status = $1
       WHERE id = $2
       RETURNING *`,
      [status, id]
    );

    if (!result.rows.length) {
      return res.status(404).json({ message: "الطلب غير موجود" });
    }

    res.json({
      message: "تم تحديث حالة الطلب",
      order: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل تحديث حالة الطلب" });
  }
});

/* =========================
   ADMIN: STORE TYPES
========================= */

// جلب أنواع المتاجر
app.get("/api/admin/store-types", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT *
       FROM store_types
       ORDER BY id DESC`
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب أنواع المتاجر" });
  }
});

// إضافة نوع متجر
app.post("/api/admin/store-types", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { name, type_key } = req.body;

    if (!name || !type_key) {
      return res.status(400).json({ message: "البيانات ناقصة" });
    }

    const exists = await pool.query(
      "SELECT id FROM store_types WHERE type_key = $1",
      [type_key]
    );

    if (exists.rows.length > 0) {
      return res.status(409).json({ message: "هذا النوع موجود بالفعل" });
    }

    const result = await pool.query(
      `INSERT INTO store_types (name, type_key)
       VALUES ($1, $2)
       RETURNING *`,
      [name, type_key]
    );

    res.status(201).json({
      message: "تمت إضافة النوع بنجاح",
      storeType: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل إضافة النوع" });
  }
});

// حذف نوع متجر
app.delete("/api/admin/store-types/:id", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      "DELETE FROM store_types WHERE id = $1 RETURNING id",
      [id]
    );

    if (!result.rows.length) {
      return res.status(404).json({ message: "النوع غير موجود" });
    }

    res.json({ message: "تم حذف النوع بنجاح" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل حذف النوع" });
  }
});
/* =========================
   STORE OWNER
========================= */

async function getMyStore(userId) {
  const result = await pool.query(
    "SELECT * FROM stores WHERE owner_user_id = $1",
    [userId]
  );

  return result.rows[0];
}

/* بيانات المتجر */
app.get("/api/store/me", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    res.json({ store });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب بيانات المتجر" });
  }
});

/* فتح / إغلاق المتجر */
app.put("/api/store/toggle-status", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    const result = await pool.query(
      `UPDATE stores
       SET is_active = NOT is_active
       WHERE id = $1
       RETURNING *`,
      [store.id]
    );

    res.json({
      message: result.rows[0].is_active ? "تم فتح المتجر" : "تم إغلاق المتجر",
      store: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل تغيير حالة المتجر" });
  }
});

/* جلب منتجات المتجر */

app.get("/api/store/products", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    const result = await pool.query(
      `SELECT p.*, c.name AS category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.store_id = $1
       ORDER BY p.id DESC`,
      [store.id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب المنتجات" });
  }
});


app.post("/api/store/products", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const { name, price, image, category_id, description } = req.body;

    if (!name || !price || !image || !category_id) {
      return res.status(400).json({ message: "البيانات ناقصة" });
    }

    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    await pool.query(
      `INSERT INTO products
       (name, price, image, description, store_id, category_id, is_available)
       VALUES ($1, $2, $3, $4, $5, $6, true)`,
      [name, price, image, description || "", store.id, category_id]
    );

    res.status(201).json({ message: "تمت إضافة المنتج بنجاح" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل إضافة المنتج" });
  }
});


app.put("/api/store/products/:id", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, image, category_id, description } = req.body;

    if (!name || !price || !image || !category_id) {
      return res.status(400).json({ message: "البيانات ناقصة" });
    }

    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    const result = await pool.query(
      `UPDATE products
       SET name = $1,
           price = $2,
           image = $3,
           category_id = $4,
           description = $5
       WHERE id = $6 AND store_id = $7
       RETURNING *`,
      [name, price, image, category_id, description || "", id, store.id]
    );

    if (!result.rows.length) {
      return res.status(404).json({ message: "المنتج غير موجود أو غير مصرح" });
    }

    res.json({ message: "تم تعديل المنتج بنجاح", product: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل تعديل المنتج" });
  }
});



/* متاح / غير متاح */
app.put("/api/store/products/:id/toggle", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const { id } = req.params;
    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    const result = await pool.query(
      `UPDATE products
       SET is_available = NOT is_available
       WHERE id = $1 AND store_id = $2
       RETURNING *`,
      [id, store.id]
    );

    if (!result.rows.length) {
      return res.status(404).json({ message: "المنتج غير موجود أو غير مصرح" });
    }

    res.json({
      message: result.rows[0].is_available ? "تم إظهار المنتج" : "تم إخفاء المنتج",
      product: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل تغيير حالة المنتج" });
  }
});

/* حذف منتج */
app.delete("/api/store/products/:id", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const { id } = req.params;
    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    const result = await pool.query(
      "DELETE FROM products WHERE id = $1 AND store_id = $2 RETURNING id",
      [id, store.id]
    );

    if (!result.rows.length) {
      return res.status(404).json({ message: "المنتج غير موجود أو غير مصرح" });
    }

    res.json({ message: "تم حذف المنتج بنجاح" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل حذف المنتج" });
  }
});

/* طلبات المتجر */
app.get("/api/store/orders", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    const result = await pool.query(
      `SELECT *
       FROM orders
       WHERE store_id = $1
       ORDER BY id DESC`,
      [store.id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب طلبات المتجر" });
  }
});

/* تغيير حالة طلب المتجر */
app.put("/api/store/orders/:id/status", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const allowed = ["pending", "preparing", "delivering", "delivered"];

    if (!allowed.includes(status)) {
      return res.status(400).json({ message: "حالة غير صالحة" });
    }

    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    const result = await pool.query(
      `UPDATE orders
       SET status = $1
       WHERE id = $2 AND store_id = $3
       RETURNING *`,
      [status, id, store.id]
    );

    if (!result.rows.length) {
      return res.status(404).json({ message: "الطلب غير موجود أو غير مصرح" });
    }

    res.json({ message: "تم تحديث حالة الطلب", order: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل تحديث حالة الطلب" });
  }
});


app.get("/api/store/categories", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const store = await getMyStore(req.user.id);

    if (!store) {
      return res.status(404).json({ message: "ما عندكش متجر مربوط بحسابك" });
    }

    const result = await pool.query(
      "SELECT * FROM categories WHERE store_id = $1 ORDER BY id ASC",
      [store.id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل جلب التصنيفات" });
  }
});


app.post("/api/store/categories", authenticateToken, requireStoreOwner, async (req, res) => {
  try {
    const { name } = req.body;

    const store = await getMyStore(req.user.id);

    await pool.query(
      "INSERT INTO categories (name, store_id) VALUES ($1, $2)",
      [name, store.id]
    );

    res.json({ message: "تم إضافة التصنيف" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "فشل إضافة التصنيف" });
  }
});


app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});