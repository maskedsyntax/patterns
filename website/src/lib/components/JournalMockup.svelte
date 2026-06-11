<script lang="ts">
  import {
    PenLine,
    List,
    BarChart3,
    Settings,
    Sun,
    Expand,
    Search,
    Save,
    Calendar,
    Plus
  } from 'lucide-svelte';

  let { compact = false }: { compact?: boolean } = $props();

  const activeDate = 'June 10, 2026';

  const activeContent = `I noticed a pattern today that I hadn't connected before. When my morning routine gets disrupted, the intrusive thoughts feel louder for the first hour.

Writing it down helped me see the distress peaked around a 6, then eased once I stepped outside. I'm learning that naming the trigger doesn't make it go away — but it gives me something concrete to return to.`;

  const entries = [
    {
      date: 'June 10, 2026',
      preview: 'I noticed a pattern today that I hadn\'t connected before...',
      active: true
    },
    {
      date: 'June 9, 2026',
      preview: 'Practiced sitting with uncertainty for ten minutes before checking...',
      active: false
    },
    {
      date: 'June 7, 2026',
      preview: 'Brought my distress log to therapy — the trends were clearer on paper.',
      active: false
    },
    {
      date: 'June 5, 2026',
      preview: 'A quieter day. Logged two mild compulsions and moved on.',
      active: false
    }
  ];
</script>

<div class="journal-mockup" class:compact aria-hidden="true">
  <div class="mac-bar">
    <div class="traffic">
      <span class="red"></span>
      <span class="yellow"></span>
      <span class="green"></span>
    </div>
    <span class="mac-title">Patterns — Journal & OCD Tracker</span>
  </div>

  <div class="mockup-body">
    <nav class="nav-rail">
      <div class="nav-spacer"></div>
      <div class="nav-icon active">
        <PenLine size={22} strokeWidth={1.75} />
      </div>
      <div class="nav-icon">
        <List size={22} strokeWidth={1.75} />
      </div>
      <div class="nav-icon">
        <BarChart3 size={22} strokeWidth={1.75} />
      </div>
      <div class="nav-icon">
        <Settings size={22} strokeWidth={1.75} />
      </div>
      <div class="nav-bottom">
        <Sun size={18} strokeWidth={1.75} />
      </div>
    </nav>

    <div class="journal-pane">
      <header class="toolbar">
        <button type="button" class="icon-btn" tabindex="-1">
          <Expand size={18} strokeWidth={1.75} />
        </button>
        <div class="date-block">
          <span class="date">{activeDate}</span>
          <span class="status">Saved</span>
        </div>
        {#if !compact}
          <div class="search">
            <Search size={14} strokeWidth={2} />
            <span>Search journals...</span>
          </div>
        {/if}
        <div class="toolbar-actions">
          <button type="button" class="save-btn" tabindex="-1">
            <Save size={13} strokeWidth={2.25} />
            <span>Save</span>
          </button>
          <button type="button" class="icon-btn muted" tabindex="-1">
            <Calendar size={17} strokeWidth={1.75} />
          </button>
        </div>
      </header>

      <div class="workspace">
        {#if !compact}
          <aside class="entry-panel">
            <button type="button" class="today-btn" tabindex="-1">
              <Plus size={14} strokeWidth={2.5} />
              <span>Today</span>
            </button>
            <ul class="entry-list">
              {#each entries as entry}
                <li class="entry" class:active={entry.active}>
                  <span class="entry-date">{entry.date}</span>
                  <span class="entry-preview">{entry.preview}</span>
                </li>
              {/each}
            </ul>
          </aside>
        {/if}
        <div class="editor">
          <div class="entry-content">
            {#each activeContent.split('\n\n') as paragraph}
              <p>{paragraph}</p>
            {/each}
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<style>
  .journal-mockup {
    --mock-bg: #000000;
    --mock-surface: #141414;
    --mock-border: rgba(255, 255, 255, 0.08);
    --mock-text: #f5f5f7;
    --mock-muted: rgba(245, 245, 247, 0.35);
    --mock-accent: #ffd700;
    --mock-search: rgba(255, 255, 255, 0.05);

    width: 100%;
    border-radius: 12px;
    overflow: hidden;
    border: 1px solid var(--mock-border);
    box-shadow:
      0 24px 64px -16px rgba(0, 0, 0, 0.55),
      0 8px 24px rgba(255, 215, 0, 0.06);
    text-align: left;
    font-family: var(--font-body);
  }

  .mac-bar {
    display: grid;
    grid-template-columns: 52px 1fr 52px;
    align-items: center;
    height: 36px;
    padding: 0 14px;
    background: var(--mock-surface);
    border-bottom: 1px solid var(--mock-border);
  }

  .traffic {
    display: flex;
    gap: 7px;
  }

  .traffic span {
    width: 11px;
    height: 11px;
    border-radius: 50%;
  }

  .red { background: #ff5f57; }
  .yellow { background: #ffbd2e; }
  .green { background: #27c93f; }

  .mac-title {
    font-size: 11px;
    font-weight: 500;
    color: var(--mock-muted);
    text-align: center;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .mockup-body {
    display: flex;
    min-height: 380px;
    background: var(--mock-bg);
  }

  .compact .mockup-body {
    min-height: 240px;
  }

  .nav-rail {
    width: 72px;
    flex-shrink: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-bottom: 24px;
    background: var(--mock-surface);
    border-right: 1px solid var(--mock-border);
  }

  .compact .nav-rail {
    width: 52px;
  }

  .nav-spacer {
    height: 48px;
  }

  .compact .nav-spacer {
    height: 28px;
  }

  .nav-icon {
    width: 44px;
    height: 44px;
    margin: 4px 0;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 10px;
    color: rgba(245, 245, 247, 0.3);
  }

  .compact .nav-icon {
    width: 36px;
    height: 36px;
  }

  .nav-icon.active {
    color: var(--mock-accent);
    background: rgba(255, 215, 0, 0.15);
  }

  .nav-bottom {
    margin-top: auto;
    color: rgba(245, 245, 247, 0.55);
    display: flex;
    align-items: center;
    justify-content: center;
    width: 44px;
    height: 44px;
  }

  .journal-pane {
    flex: 1;
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .toolbar {
    display: flex;
    align-items: center;
    gap: 12px;
    height: 48px;
    padding: 0 12px 0 8px;
    background: var(--mock-bg);
    border-bottom: 1px solid var(--mock-border);
  }

  .compact .toolbar {
    height: 42px;
    gap: 8px;
  }

  .icon-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    border-radius: 8px;
    color: rgba(245, 245, 247, 0.65);
    flex-shrink: 0;
  }

  .icon-btn.muted {
    color: rgba(245, 245, 247, 0.55);
  }

  .date-block {
    display: flex;
    flex-direction: column;
    gap: 1px;
    flex-shrink: 0;
    min-width: 108px;
  }

  .date {
    font-size: 12px;
    font-weight: 700;
    color: var(--mock-text);
    line-height: 1.2;
  }

  .status {
    font-size: 9px;
    font-weight: 500;
    color: rgba(245, 245, 247, 0.3);
    line-height: 1.2;
  }

  .search {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 8px;
    height: 30px;
    max-width: 250px;
    margin: 0 auto;
    padding: 0 10px;
    border-radius: 8px;
    background: var(--mock-search);
    color: rgba(245, 245, 247, 0.35);
    font-size: 12px;
  }

  .toolbar-actions {
    display: flex;
    align-items: center;
    gap: 4px;
    margin-left: auto;
    flex-shrink: 0;
  }

  .save-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    height: 28px;
    padding: 0 12px;
    border-radius: 6px;
    background: var(--mock-accent);
    color: #000;
    font-size: 11px;
    font-weight: 700;
  }

  .workspace {
    display: flex;
    flex: 1;
    min-height: 0;
  }

  .entry-panel {
    width: 220px;
    flex-shrink: 0;
    padding: 16px 12px;
    background: var(--mock-surface);
    border-right: 1px solid var(--mock-border);
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .today-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    width: 100%;
    padding: 9px 12px;
    border-radius: 8px;
    border: 1.5px solid var(--mock-accent);
    color: var(--mock-accent);
    font-size: 12px;
    font-weight: 600;
  }

  .entry-list {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .entry {
    padding: 10px 14px;
    border-radius: 8px;
    border: 1px solid transparent;
    cursor: default;
  }

  .entry.active {
    background: rgba(255, 215, 0, 0.12);
    border-color: rgba(255, 215, 0, 0.45);
  }

  .entry-date {
    display: block;
    font-size: 12px;
    font-weight: 500;
    color: rgba(245, 245, 247, 0.75);
    line-height: 1.3;
  }

  .entry.active .entry-date {
    font-weight: 700;
    color: var(--mock-accent);
  }

  .entry-preview {
    display: block;
    margin-top: 4px;
    font-size: 11px;
    line-height: 1.35;
    color: rgba(245, 245, 247, 0.28);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .entry.active .entry-preview {
    color: rgba(245, 245, 247, 0.5);
  }

  .editor {
    flex: 1;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding: 36px 40px;
    background: var(--mock-bg);
    overflow: hidden;
  }

  .compact .editor {
    padding: 20px 16px;
  }

  .entry-content {
    width: 100%;
    max-width: 520px;
  }

  .entry-content {
    font-family: var(--font-reading);
  }

  .entry-content p {
    margin: 0 0 1.2em;
    font-size: 17px;
    line-height: 1.8;
    font-weight: 400;
    letter-spacing: 0.015em;
    color: rgba(245, 245, 247, 0.9);
  }

  .entry-content p:last-child {
    margin-bottom: 0;
  }

  .compact .entry-content p {
    font-size: 13px;
    line-height: 1.6;
  }

  .compact .entry-content p:not(:first-child) {
    display: none;
  }
</style>
