import { Flame, Newspaper, Search, User } from "lucide-react";
import { useMemo } from "react";

const tabs = [
  { id: "feed", label: "Feed", icon: Newspaper },
  { id: "search", label: "Search", icon: Search },
  { id: "streaks", label: "Streaks", icon: Flame },
  { id: "profile", label: "Profile", icon: User },
];

export default function BottomNav({ activeTab, onChange }) {
  const activeIndex = useMemo(
    () => tabs.findIndex((tab) => tab.id === activeTab),
    [activeTab]
  );

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-paper-0 shadow-[0_-6px_20px_-18px_rgba(15,23,42,0.35)]">
      <div className="mx-auto flex max-w-md items-center justify-between px-4 py-3">
        {tabs.map((tab, index) => {
          const isActive = tab.id === activeTab;
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              type="button"
              onClick={() => onChange(tab.id)}
              className={`nav-item group min-h-[44px] min-w-[44px] px-2 ${
                isActive ? "nav-item-active" : ""
              }`}
              aria-pressed={isActive}
            >
              <span className="flex h-8 w-8 items-center justify-center rounded-full">
                <Icon
                  aria-hidden="true"
                  className={`h-5 w-5 transition-all duration-200 ${
                    isActive
                      ? "animate-icon-float text-ink-900"
                      : "text-ink-700 group-hover:-translate-y-0.5 group-hover:text-ink-900"
                  } ${isActive && index === activeIndex ? "animate-tab-pop" : ""}`}
                />
              </span>
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
