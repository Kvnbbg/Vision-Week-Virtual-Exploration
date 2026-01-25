import { useState } from "react";
import BottomNav from "../components/BottomNav";

const articles = [
  {
    id: 1,
    title: "Audit the Algorithm: Morning Bias Check",
    excerpt:
      "Scan headlines with a calibrated lens and compare framing across sources.",
    meta: "5 min read · 2 sources",
  },
  {
    id: 2,
    title: "Community Voices: Building Trust in Local News",
    excerpt:
      "A checklist to surface diverse perspectives while staying grounded in facts.",
    meta: "8 min read · 3 sources",
  },
  {
    id: 3,
    title: "Policy Watch: Equity in Urban Planning",
    excerpt:
      "Identify structural impacts before drawing conclusions from official reports.",
    meta: "6 min read · 4 sources",
  },
];

export default function Home() {
  const [activeTab, setActiveTab] = useState("feed");

  return (
    <div className="min-h-screen bg-paper-50">
      <header className="sticky top-0 z-20 bg-paper-0/90 backdrop-blur">
        <div className="mx-auto flex h-16 max-w-md items-center justify-between px-4">
          <div className="flex flex-col">
            <span className="text-xs font-ui text-ink-700">The Anti-Bias Reader</span>
            <h1 className="text-hero">Daily Briefing</h1>
          </div>
          <button
            type="button"
            className="btn-secondary text-sm"
            aria-label="Open menu"
          >
            More
          </button>
        </div>
      </header>

      <main className="mx-auto max-w-md px-4 pb-24 pt-6">
        <section className="section-spacing">
          <div className="card-standard">
            <div className="flex items-center justify-between">
              <h2 className="text-xl">Daily Streak</h2>
              <span className="rounded-full bg-paper-100 px-3 py-1 text-xs font-ui text-ink-700">
                12-day run
              </span>
            </div>
            <p className="prose-body">
              Keep your lens calibrated. Review two sources today to maintain balance.
            </p>
            <div className="flex gap-2">
              <button type="button" className="btn-primary">
                Start Today’s Check
              </button>
            </div>
          </div>

          <div className="section-spacing">
            <h2 className="text-xl">Today’s Articles</h2>
            {articles.map((article) => (
              <article key={article.id} className="card-standard">
                <div className="flex flex-col gap-2">
                  <h3 className="text-lg">{article.title}</h3>
                  <p className="prose-body">{article.excerpt}</p>
                  <span className="text-xs font-ui text-ink-700">
                    {article.meta}
                  </span>
                </div>
                <div className="flex flex-wrap gap-2">
                  <button type="button" className="btn-primary">
                    Verify Source
                  </button>
                  <button type="button" className="btn-secondary">
                    Save for Later
                  </button>
                </div>
              </article>
            ))}
          </div>
        </section>
      </main>

      <button
        type="button"
        className="fab-primary fixed bottom-20 right-4"
        aria-label="Next article"
      >
        ➜
      </button>

      <BottomNav activeTab={activeTab} onChange={setActiveTab} />
    </div>
  );
}
