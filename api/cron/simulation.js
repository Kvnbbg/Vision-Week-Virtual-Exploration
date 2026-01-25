const { execFileSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const DEFAULT_DB_PATH = path.join(process.cwd(), "web", "data", "vision_week.sqlite");
const TEMPLATE_PATH = path.join(process.cwd(), "data", "ghost-post-templates.json");

const loadTemplates = () => {
  if (!fs.existsSync(TEMPLATE_PATH)) {
    return [];
  }
  return JSON.parse(fs.readFileSync(TEMPLATE_PATH, "utf-8"));
};

const runSql = (dbPath, sql, json = false) => {
  const args = [];
  if (json) {
    args.push("-json");
  }
  args.push(dbPath, sql);
  return execFileSync("sqlite3", args, { encoding: "utf-8" });
};

const ensureSchema = (dbPath) => {
  runSql(
    dbPath,
    `CREATE TABLE IF NOT EXISTS ghost_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        handle TEXT NOT NULL UNIQUE,
        avatar_url TEXT NOT NULL,
        bio TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS ghost_posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        image_url TEXT,
        likes_count INTEGER NOT NULL DEFAULT 0,
        views_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES ghost_users(id)
      );`
  );
};

const randomItem = (items) => items[Math.floor(Math.random() * items.length)];
const randomInt = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const randomTimestamp = () => new Date().toISOString();

const randomImage = () => {
  if (Math.random() < 0.4) {
    const topics = [
      "tech",
      "art",
      "lifestyle",
      "motivation",
      "coding",
      "design",
      "startup",
      "community",
    ];
    return `https://source.unsplash.com/featured/800x600?${randomItem(topics)}`;
  }
  return null;
};

const escapeSql = (value) => {
  if (value === null || value === undefined) {
    return "NULL";
  }
  return `'${String(value).replace(/'/g, "''")}'`;
};

const getDbPath = () => process.env.GHOST_DB_PATH || DEFAULT_DB_PATH;

const isAuthorized = (req) => {
  const secret = process.env.CRON_SECRET;
  if (!secret) {
    return false;
  }

  const authHeader = req.headers.authorization || "";
  if (authHeader.startsWith("Bearer ")) {
    const token = authHeader.slice("Bearer ".length).trim();
    if (token === secret) {
      return true;
    }
  }

  const cronHeader = req.headers["x-cron-secret"];
  if (cronHeader && cronHeader === secret) {
    return true;
  }

  const requestUrl = new URL(req.url, `http://${req.headers.host}`);
  const tokenParam = requestUrl.searchParams.get("secret");
  return tokenParam === secret;
};

module.exports = async (req, res) => {
  if (!isAuthorized(req)) {
    res.statusCode = 401;
    res.setHeader("Content-Type", "application/json");
    res.end(JSON.stringify({ ok: false, error: "Unauthorized" }));
    return;
  }

  const dbPath = getDbPath();
  if (!fs.existsSync(dbPath)) {
    res.statusCode = 500;
    res.setHeader("Content-Type", "application/json");
    res.end(
      JSON.stringify({
        ok: false,
        error: "Database not found. Run the seed script first.",
      })
    );
    return;
  }

  ensureSchema(dbPath);

  const templates = loadTemplates();
  const users = JSON.parse(runSql(dbPath, "SELECT id FROM ghost_users;", true));
  if (!users.length) {
    res.statusCode = 200;
    res.setHeader("Content-Type", "application/json");
    res.end(JSON.stringify({ ok: true, message: "No ghost users available." }));
    return;
  }

  let payload;
  if (Math.random() < 0.6 || templates.length === 0) {
    const user = randomItem(users);
    const content = templates.length ? randomItem(templates) : "Fresh update just landed! #LaunchDay";
    const image = randomImage();
    const likes = randomInt(0, 12);
    const views = randomInt(120, 900);
    runSql(
      dbPath,
      `INSERT INTO ghost_posts (user_id, content, image_url, likes_count, views_count, created_at) VALUES (${user.id}, ${escapeSql(
        content
      )}, ${escapeSql(image)}, ${likes}, ${views}, ${escapeSql(randomTimestamp())});`
    );
    payload = { ok: true, action: "post_created", userId: user.id };
  } else {
    const postRows = JSON.parse(
      runSql(dbPath, "SELECT id FROM ghost_posts ORDER BY RANDOM() LIMIT 1;", true)
    );
    const post = postRows[0];
    if (post) {
      const likesBoost = randomInt(5, 10);
      const viewsBoost = randomInt(100, 600);
      runSql(
        dbPath,
        `UPDATE ghost_posts SET likes_count = likes_count + ${likesBoost}, views_count = views_count + ${viewsBoost} WHERE id = ${post.id};`
      );
      payload = { ok: true, action: "post_engaged", postId: post.id };
    } else {
      const user = randomItem(users);
      const content = randomItem(templates);
      runSql(
        dbPath,
        `INSERT INTO ghost_posts (user_id, content, image_url, likes_count, views_count, created_at) VALUES (${user.id}, ${escapeSql(
          content
        )}, ${escapeSql(randomImage())}, 8, 240, ${escapeSql(randomTimestamp())});`
      );
      payload = { ok: true, action: "post_created", userId: user.id };
    }
  }

  res.statusCode = 200;
  res.setHeader("Content-Type", "application/json");
  res.end(JSON.stringify(payload));
};
