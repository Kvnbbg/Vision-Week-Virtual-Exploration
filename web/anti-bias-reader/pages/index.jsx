import { useCallback, useMemo, useState } from "react";
import BottomNav from "../components/BottomNav";

const BODY_TEXT_CLASS = "text-base text-ink-800";
const TOUCH_TARGET_CLASS =
  "min-h-[44px] min-w-[44px] px-4 py-2 text-sm font-semibold";
const AD_INTERVAL = 7;
const STREAK_REQUIREMENT = 2;
const FEED_SORT_OPTIONS = [
  { id: "trending", label: "Trending" },
  { id: "newest", label: "Newest" },
];
const SOCIAL_POSTS = [
  {
    id: "post-1",
    author: "Maya Alvarez",
    handle: "maya.codes",
    avatar: "/images/avatar-1.png",
    content:
      "Launching the #DailyBiasCheck with @techandstream. Who’s in for a 7-day streak?",
    timestamp: "2024-04-03T08:15:00Z",
    stats: { likes: 124, saves: 48, reshares: 17, comments: 9 },
    isOwner: true,
  },
  {
    id: "post-2",
    author: "Jordan Lee",
    handle: "jordansignal",
    avatar: "/images/avatar-2.png",
    content:
      "This is your reminder to cross-check sources before sharing. #MediaLiteracy",
    timestamp: "2024-04-03T11:42:00Z",
    stats: { likes: 88, saves: 32, reshares: 11, comments: 4 },
    isOwner: false,
  },
  {
    id: "post-3",
    author: "Samira Patel",
    handle: "samirap",
    avatar: "/images/avatar-3.png",
    content:
      "Today’s focus: community-led reporting and how it shifts the narrative. @techandstream",
    timestamp: "2024-04-03T13:05:00Z",
    stats: { likes: 64, saves: 21, reshares: 8, comments: 6 },
    isOwner: false,
  },
  {
    id: "post-4",
    author: "Alex Chen",
    handle: "alexwatches",
    avatar: "/images/avatar-4.png",
    content:
      "When newsrooms collaborate, the signal beats the noise. #TrustBuilding",
    timestamp: "2024-04-03T14:20:00Z",
    stats: { likes: 43, saves: 14, reshares: 5, comments: 2 },
    isOwner: false,
  },
  {
    id: "post-5",
    author: "Riley Shaw",
    handle: "rileyreports",
    avatar: "/images/avatar-5.png",
    content:
      "Anyone else documenting their fact-check workflow? Let’s compare notes. #OpenNews",
    timestamp: "2024-04-03T15:01:00Z",
    stats: { likes: 52, saves: 19, reshares: 9, comments: 5 },
    isOwner: false,
  },
];

const sanitizeText = (value) =>
  value.replace(/[<>]/g, "").replace(/\s+/g, " ").trim();

const splitMentionsAndTags = (value) => {
  const safeValue = sanitizeText(value);
  return safeValue.split(/(\B#[a-z0-9_]+|\B@[a-z0-9_.]+)/gi);
};

const formatRelativeTime = (isoTimestamp) => {
  const timestamp = Date.parse(isoTimestamp);
  if (Number.isNaN(timestamp)) {
    return "Just now";
  }

  const seconds = Math.floor((Date.now() - timestamp) / 1000);
  if (seconds < 60) return "Just now";
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
};

const getUtcDateKey = (date = new Date()) =>
  `${date.getUTCFullYear()}-${date.getUTCMonth() + 1}-${date.getUTCDate()}`;

const getStreakMessage = (streakCount, lastActiveUtc) => {
  const todayKey = getUtcDateKey();
  const hasStreakToday = todayKey === lastActiveUtc;
  if (!hasStreakToday) {
    return "Log two sources today to keep your streak alive.";
  }
  return `You're on track! Review ${STREAK_REQUIREMENT} sources today.`;
};

const sortPosts = (posts, sortMode) => {
  if (sortMode === "newest") {
    return [...posts].sort(
      (a, b) => Date.parse(b.timestamp) - Date.parse(a.timestamp)
    );
  }
  return [...posts].sort(
    (a, b) =>
      b.stats.likes +
      b.stats.reshares +
      b.stats.comments -
      (a.stats.likes + a.stats.reshares + a.stats.comments)
  );
};

const updateCount = (count, isActive) => (isActive ? count + 1 : count - 1);

const AdContainer = ({ isActive }) => {
  if (!isActive) return null;
  return (
    <aside
      className="rounded-3xl border border-dashed border-paper-200 bg-paper-0 p-4 text-center text-sm text-ink-600"
      aria-label="Sponsored content"
    >
      <p className="font-ui text-xs uppercase tracking-[0.2em] text-ink-500">
        Sponsored
      </p>
      <p className="mt-2 text-base font-semibold text-ink-800">
        Smart placement for your next campaign.
      </p>
      <p className="mt-1 text-sm text-ink-600">
        This space appears only when ads are available.
      </p>
    </aside>
  );
};

export default function Home() {
  const [activeTab, setActiveTab] = useState("feed");
  const [sortMode, setSortMode] = useState("trending");
  const [posts, setPosts] = useState(
    SOCIAL_POSTS.map((post) => ({
      ...post,
      interactions: { liked: false, saved: false, reshared: false },
    }))
  );
  const [streakState] = useState({
    count: 12,
    lastActiveUtc: getUtcDateKey(),
  });
  const [notice, setNotice] = useState("");

  const sortedPosts = useMemo(
    () => sortPosts(posts, sortMode),
    [posts, sortMode]
  );
  const streakMessage = useMemo(
    () => getStreakMessage(streakState.count, streakState.lastActiveUtc),
    [streakState]
  );

  const handleSortChange = useCallback((mode) => {
    if (!FEED_SORT_OPTIONS.some((option) => option.id === mode)) {
      return;
    }
    setSortMode(mode);
  }, []);

  const handleAction = useCallback(
    async (postId, actionType) => {
      if (!["liked", "saved", "reshared"].includes(actionType)) {
        return;
      }

      let previousState;
      setPosts((currentPosts) =>
        currentPosts.map((post) => {
          if (post.id !== postId) return post;
          const isActive = !post.interactions[actionType];
          previousState = post;
          return {
            ...post,
            interactions: { ...post.interactions, [actionType]: isActive },
            stats: {
              ...post.stats,
              likes:
                actionType === "liked"
                  ? updateCount(post.stats.likes, isActive)
                  : post.stats.likes,
              saves:
                actionType === "saved"
                  ? updateCount(post.stats.saves, isActive)
                  : post.stats.saves,
              reshares:
                actionType === "reshared"
                  ? updateCount(post.stats.reshares, isActive)
                  : post.stats.reshares,
            },
          };
        })
      );

      try {
        await new Promise((resolve) => setTimeout(resolve, 300));
      } catch (error) {
        setNotice("We couldn’t save that action. Please try again.");
        if (previousState) {
          setPosts((currentPosts) =>
            currentPosts.map((post) =>
              post.id === previousState.id ? previousState : post
            )
          );
        }
      }
    },
    []
  );

  return (
    <div className="min-h-screen bg-paper-50 text-base text-ink-900">
      <header className="sticky top-0 z-20 bg-paper-0/90 backdrop-blur">
        <div className="mx-auto flex h-16 w-full max-w-6xl items-center justify-between px-4">
          <div className="flex flex-col">
            <span className="text-xs font-ui text-ink-700">
              techandstream Social
            </span>
            <h1 className="text-hero">Daily Briefing</h1>
          </div>
          <button
            type="button"
            className={`btn-secondary ${TOUCH_TARGET_CLASS}`}
            aria-label="Open menu"
          >
            Menu
          </button>
        </div>
      </header>

      <main className="mx-auto w-full max-w-6xl px-4 pb-24 pt-6 md:grid md:grid-cols-[minmax(0,1fr)_minmax(0,2fr)_minmax(0,1fr)] md:gap-6">
        <aside className="hidden flex-col gap-4 md:flex">
          <section className="card-standard">
            <h2 className="text-lg font-semibold">Creator Studio</h2>
            <p className={BODY_TEXT_CLASS}>
              Build your daily brief and publish in minutes.
            </p>
            <button type="button" className={`btn-primary ${TOUCH_TARGET_CLASS}`}>
              Create Post
            </button>
          </section>
          <section className="card-standard">
            <h2 className="text-lg font-semibold">Streak Coach</h2>
            <p className={BODY_TEXT_CLASS}>{streakMessage}</p>
            <div className="mt-3 flex items-center gap-2">
              <span className="rounded-full bg-paper-100 px-3 py-1 text-xs font-ui text-ink-700">
                {streakState.count}-day run
              </span>
              <span className="text-xs font-ui text-ink-500">
                UTC aligned
              </span>
            </div>
          </section>
        </aside>

        <section className="flex flex-col gap-4" aria-live="polite">
          <div className="card-standard">
            <div className="flex flex-col gap-3">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <h2 className="text-xl font-semibold">Daily Streak</h2>
                  <p className={`${BODY_TEXT_CLASS} mt-1`}>{streakMessage}</p>
                </div>
                <span className="rounded-full bg-paper-100 px-3 py-1 text-xs font-ui text-ink-700">
                  {streakState.count}-day run
                </span>
              </div>
              <div className="flex flex-wrap gap-2">
                <button
                  type="button"
                  className={`btn-primary ${TOUCH_TARGET_CLASS}`}
                >
                  Start Today’s Check
                </button>
                <button
                  type="button"
                  className={`btn-secondary ${TOUCH_TARGET_CLASS}`}
                >
                  Log Sources
                </button>
              </div>
            </div>
          </div>

          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <h2 className="text-xl font-semibold">Today’s Feed</h2>
              <p className={`${BODY_TEXT_CLASS} mt-1`}>
                Curated updates from verified creators and analysts.
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              {FEED_SORT_OPTIONS.map((option) => (
                <button
                  key={option.id}
                  type="button"
                  onClick={() => handleSortChange(option.id)}
                  className={`${
                    sortMode === option.id ? "btn-primary" : "btn-secondary"
                  } ${TOUCH_TARGET_CLASS}`}
                  aria-pressed={sortMode === option.id}
                >
                  {option.label}
                </button>
              ))}
            </div>
          </div>

          {notice ? (
            <div className="rounded-2xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800">
              {notice}
            </div>
          ) : null}

          {sortedPosts.map((post, index) => (
            <div key={post.id} className="flex flex-col gap-4">
              {index > 0 && (index + 1) % AD_INTERVAL === 0 ? (
                <AdContainer isActive />
              ) : null}
              <article className="card-standard" aria-label={`Post by ${post.author}`}>
                <div className="flex flex-col gap-4">
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-3">
                      <img
                        src={post.avatar}
                        alt={`${post.author} profile`}
                        className="h-12 w-12 rounded-full object-cover"
                        loading="lazy"
                      />
                      <div>
                        <p className="text-base font-semibold text-ink-900">
                          {post.author}
                        </p>
                        <p className="text-sm text-ink-600">
                          @{post.handle} · {formatRelativeTime(post.timestamp)}
                        </p>
                      </div>
                    </div>
                    {post.isOwner ? (
                      <button
                        type="button"
                        className={`btn-secondary ${TOUCH_TARGET_CLASS}`}
                      >
                        Manage
                      </button>
                    ) : null}
                  </div>

                  <p className={BODY_TEXT_CLASS}>
                    {splitMentionsAndTags(post.content).map((part, partIndex) => {
                      const isMentionOrTag = /^(#|@)/.test(part);
                      if (!isMentionOrTag) {
                        return <span key={`${post.id}-text-${partIndex}`}>{part}</span>;
                      }
                      const linkTarget = part.startsWith("#")
                        ? `/tags/${part.substring(1)}`
                        : `/profile/${part.substring(1)}`;
                      return (
                        <a
                          key={`${post.id}-link-${partIndex}`}
                          href={linkTarget}
                          className="text-ink-900 underline decoration-ink-400 underline-offset-4"
                        >
                          {part}
                        </a>
                      );
                    })}
                  </p>

                  <div className="flex flex-wrap items-center gap-2 text-sm text-ink-600">
                    <span>{post.stats.likes} Likes</span>
                    <span>•</span>
                    <span>{post.stats.saves} Saves</span>
                    <span>•</span>
                    <span>{post.stats.reshares} Reshares</span>
                    <span>•</span>
                    <span>{post.stats.comments} Comments</span>
                  </div>

                  <div className="flex flex-wrap gap-2">
                    <button
                      type="button"
                      className={`${
                        post.interactions.liked ? "btn-primary" : "btn-secondary"
                      } ${TOUCH_TARGET_CLASS}`}
                      onClick={() => handleAction(post.id, "liked")}
                      aria-pressed={post.interactions.liked}
                    >
                      Like
                    </button>
                    <button
                      type="button"
                      className={`${
                        post.interactions.saved ? "btn-primary" : "btn-secondary"
                      } ${TOUCH_TARGET_CLASS}`}
                      onClick={() => handleAction(post.id, "saved")}
                      aria-pressed={post.interactions.saved}
                    >
                      Save
                    </button>
                    <button
                      type="button"
                      className={`${
                        post.interactions.reshared ? "btn-primary" : "btn-secondary"
                      } ${TOUCH_TARGET_CLASS}`}
                      onClick={() => handleAction(post.id, "reshared")}
                      aria-pressed={post.interactions.reshared}
                    >
                      Reshare
                    </button>
                    <button
                      type="button"
                      className={`btn-secondary ${TOUCH_TARGET_CLASS}`}
                      aria-label="Reply to post"
                    >
                      Reply
                    </button>
                  </div>
                </div>
              </article>
            </div>
          ))}
        </section>

        <aside className="hidden flex-col gap-4 md:flex">
          <section className="card-standard">
            <h2 className="text-lg font-semibold">Trending</h2>
            <ul className="mt-3 flex flex-col gap-3 text-sm text-ink-700">
              <li className="flex items-center justify-between">
                <span>#DailyBiasCheck</span>
                <span className="text-xs text-ink-500">1.2k</span>
              </li>
              <li className="flex items-center justify-between">
                <span>#MediaLiteracy</span>
                <span className="text-xs text-ink-500">980</span>
              </li>
              <li className="flex items-center justify-between">
                <span>#OpenNews</span>
                <span className="text-xs text-ink-500">720</span>
              </li>
            </ul>
          </section>
          <AdContainer isActive />
        </aside>
      </main>

      <button
        type="button"
        className="fab-primary fixed bottom-20 right-4 min-h-[44px] min-w-[44px]"
        aria-label="Next article"
      >
        ➜
      </button>

      <BottomNav activeTab={activeTab} onChange={setActiveTab} />
    </div>
  );
}
