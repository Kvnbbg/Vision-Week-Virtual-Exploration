import { execFileSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";

// Requires sqlite3 CLI accessible in PATH (used to avoid extra Node dependencies).
const DEFAULT_DB_PATH = path.join(process.cwd(), "web", "data", "vision_week.sqlite");
const USER_TARGET = Number.parseInt(process.env.SEED_USERS ?? "60", 10);
const POST_TARGET = Number.parseInt(process.env.SEED_POSTS ?? "240", 10);

const USER_NAMES = [
  "Beticia Santos",
  "Laura Nguyen",
  "Jilou Martin",
  "Ananya Rao",
  "Chloé Dubois",
  "Kevin Ortiz",
  "Marco Silva",
  "David Kim",
  "Liam Parker",
  "Zara Okafor",
  "Noah Jensen",
  "Ava Morales",
  "Priya Nair",
  "Elena Rossi",
  "Mateo Rivera",
  "Sofia Alvarez",
  "Isabella Costa",
  "Hugo Bennett",
  "Jade Laurent",
  "Theo Martin",
  "Camila Fernandes",
  "Ethan Brooks",
  "Maya Patel",
  "Nora Schmidt",
  "Omar Hassan",
  "Rina Watanabe",
  "Leo Dubois",
  "Aria Collins",
  "Lucas Meyer",
  "Fatima Noor",
  "Julian Reed",
  "Lea Fischer",
  "Kai Nakamura",
  "Ismael Cruz",
  "Hannah Scott",
  "Nico Vargas",
  "Ivy Chen",
  "Rafael Gomes",
  "Aya Mori",
  "Amira Ali",
  "Tomasz Nowak",
  "Sienna Hart",
  "Andre Costa",
  "Lola Marchand",
  "Yara Khalil",
  "Zoe Bennett",
  "Jasper Singh",
  "Lina Petrova",
  "Milan Novak",
  "Valeria Ruiz",
  "Owen Murphy",
  "Nadia Benali",
  "Ren Ito",
  "Clara Jensen",
  "Samira Khan",
  "Bryce Walker",
  "Mia Lopez",
  "Roman Petrov",
  "Esme Laurent",
  "Callum Harris",
];

const BIOS = [
  "Digital artist 🎨 | Coffee lover ☕",
  "Tech enthusiast building the future 🚀",
  "Product designer obsessed with clarity ✨",
  "Full-stack builder & weekend hiker 🏔️",
  "Founder mode: always on 💡",
  "Community-led storyteller 🌍",
  "Creative coder sharing the journey 💻",
  "UX researcher + podcast addict 🎧",
  "Minimalist, maker, momentum chaser ⚡",
  "AI explorer & curious human 🤖",
  "Growth mindset, gentle hustle 🌱",
  "Brand strategist + tea enthusiast 🍵",
  "Learning in public, daily 📚",
  "Open-source believer, design thinker 🙌",
  "Optimist. Builder. Repeat. 🔁",
];

const CONTENT_TOPICS = [
  "Tech",
  "Art",
  "Lifestyle",
  "Motivation",
  "Coding",
  "Design",
  "Startups",
  "Productivity",
  "Community",
];

const TEMPLATE_PATH = path.join(process.cwd(), "data", "ghost-post-templates.json");
const POST_TEMPLATES: string[] = JSON.parse(fs.readFileSync(TEMPLATE_PATH, "utf-8"));

const randomItem = <T>(items: T[]): T => items[Math.floor(Math.random() * items.length)];
const randomInt = (min: number, max: number): number =>
  Math.floor(Math.random() * (max - min + 1)) + min;

const slugify = (value: string): string =>
  value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "")
    .replace(/^@?/, "@");

const ensureDir = (filePath: string): void => {
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

const runSql = (dbPath: string, sql: string, json = false): string => {
  const args = [];
  if (json) {
    args.push("-json");
  }
  args.push(dbPath, sql);
  return execFileSync("sqlite3", args, { encoding: "utf-8" });
};

const ensureSchema = (dbPath: string): void => {
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

const generateHandle = (name: string, existing: Set<string>): string => {
  const base = slugify(name.replace(/\s+/g, ""));
  let handle = base;
  let suffix = 1;
  while (existing.has(handle)) {
    suffix += 1;
    handle = `${base}${suffix}`;
  }
  existing.add(handle);
  return handle;
};

const generateAvatar = (handle: string): string =>
  `https://i.pravatar.cc/150?u=${encodeURIComponent(handle)}`;

const randomImage = (): string | null => {
  if (Math.random() < 0.35) {
    const topic = randomItem(CONTENT_TOPICS).toLowerCase();
    return `https://source.unsplash.com/featured/800x600?${topic}`;
  }
  return null;
};

const randomTimestamp = (): string => {
  const daysAgo = randomInt(0, 30);
  const minutesAgo = randomInt(0, 1440);
  const date = new Date();
  date.setDate(date.getDate() - daysAgo);
  date.setMinutes(date.getMinutes() - minutesAgo);
  return date.toISOString();
};

const escapeSql = (value: string | null): string => {
  if (value === null) {
    return "NULL";
  }
  return `'${value.replace(/'/g, "''")}'`;
};

const seed = (): void => {
  const dbPath = process.env.GHOST_DB_PATH || DEFAULT_DB_PATH;
  ensureDir(dbPath);
  ensureSchema(dbPath);

  const existingUsers = JSON.parse(
    runSql(dbPath, "SELECT COUNT(*) as count FROM ghost_users;", true)
  )[0] as { count: number };
  const existingPosts = JSON.parse(
    runSql(dbPath, "SELECT COUNT(*) as count FROM ghost_posts;", true)
  )[0] as { count: number };

  const usersToCreate = Math.max(USER_TARGET - existingUsers.count, 0);
  const postsToCreate = Math.max(POST_TARGET - existingPosts.count, 0);

  const handleRows = JSON.parse(runSql(dbPath, "SELECT handle FROM ghost_users;", true)) as {
    handle: string;
  }[];
  const handleSet = new Set<string>(handleRows.map((row) => row.handle));

  const userStatements: string[] = [];
  for (let i = 0; i < usersToCreate; i += 1) {
    const name = USER_NAMES[i % USER_NAMES.length];
    const handle = generateHandle(name, handleSet);
    const avatar = generateAvatar(handle);
    const bio = randomItem(BIOS);
    const createdAt = randomTimestamp();
    userStatements.push(
      `INSERT INTO ghost_users (full_name, handle, avatar_url, bio, created_at) VALUES (${escapeSql(
        name
      )}, ${escapeSql(handle)}, ${escapeSql(avatar)}, ${escapeSql(bio)}, ${escapeSql(createdAt)});`
    );
  }

  if (userStatements.length > 0) {
    runSql(dbPath, `BEGIN;${userStatements.join("")}COMMIT;`);
  }

  const userRows = JSON.parse(runSql(dbPath, "SELECT id FROM ghost_users;", true)) as {
    id: number;
  }[];

  const postStatements: string[] = [];
  if (userRows.length > 0) {
    for (let i = 0; i < postsToCreate; i += 1) {
      const user = randomItem(userRows);
      const content = randomItem(POST_TEMPLATES);
      const image = randomImage();
      const likes = randomInt(0, 50);
      const views = randomInt(100, 5000);
      const createdAt = randomTimestamp();
      postStatements.push(
        `INSERT INTO ghost_posts (user_id, content, image_url, likes_count, views_count, created_at) VALUES (${user.id}, ${escapeSql(
          content
        )}, ${escapeSql(image)}, ${likes}, ${views}, ${escapeSql(createdAt)});`
      );
    }
  }

  if (postStatements.length > 0) {
    runSql(dbPath, `BEGIN;${postStatements.join("")}COMMIT;`);
  }

  const finalUsers = JSON.parse(
    runSql(dbPath, "SELECT COUNT(*) as count FROM ghost_users;", true)
  )[0] as { count: number };
  const finalPosts = JSON.parse(
    runSql(dbPath, "SELECT COUNT(*) as count FROM ghost_posts;", true)
  )[0] as { count: number };

  console.log("Ghost seeding complete.");
  console.log(`Users: ${finalUsers.count}`);
  console.log(`Posts: ${finalPosts.count}`);

};

seed();
