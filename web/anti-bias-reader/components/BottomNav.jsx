import { useMemo } from "react";

const tabs = [
  { id: "feed", label: "Feed", icon: "📰" },
  { id: "search", label: "Search", icon: "🔍" },
  { id: "streaks", label: "Streaks", icon: "🔥" },
  { id: "profile", label: "Profile", icon: "👤" },
];

export default function BottomNav({ activeTab, onChange }) {
  const activeIndex = useMemo(
    () => tabs.findIndex((tab) => tab.id === activeTab),
    [activeTab]
  );

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-paper-0 shadow-[0_-6px_20px_-18px_rgba(15,23,42,0.35)]">
      <div className="mx-auto flex max-w-md items-center justify-between px-6 py-3">
        {tabs.map((tab, index) => {
          const isActive = tab.id === activeTab;
          return (
            <button
              key={tab.id}
              type="button"
              onClick={() => onChange(tab.id)}
              className={`nav-item ${isActive ? "nav-item-active" : ""}`}
              aria-pressed={isActive}
            >
              <span
                className={`text-xl transition-transform duration-150 ${
                  isActive && index === activeIndex ? "animate-tab-pop" : ""
                }`}
              >
                {tab.icon}
              </span>
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
