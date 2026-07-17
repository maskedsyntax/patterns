/* Concept 1 V3 — grid-based replacement for the rejected V2 composition. */
(function () {
  const HOME_SCREEN =
    '/promo-screens/Simulator%20Screenshot%20-%20iPhone%2017%20-%202026-07-11%20at%2016.13.12.png';

  function markup() {
    return `
      <main class="c1v3">
        <div class="c1v3-ambient"></div>

        <header class="c1v3-header">
          <div class="c1v3-kicker"><span>Patterns</span><i></i><span>ERP, simplified</span></div>
          <div class="c1v3-title-stack">
            <h1 class="c1v3-title-loop">THE OCD LOOP</h1>
            <h1 class="c1v3-title-exit">CHANGE ONE RESPONSE.</h1>
          </div>
          <p class="c1v3-subtitle-loop">Watch how temporary relief keeps the cycle moving.</p>
          <p class="c1v3-subtitle-exit">Pause at the urge. Let a different path form.</p>
        </header>

        <section class="c1v3-stage">
          <svg class="c1v3-svg" viewBox="0 0 1080 1260" aria-label="The OCD cycle with an ERP exit">
            <defs>
              <linearGradient id="c1v3-exit-gradient" x1="860" y1="450" x2="540" y2="1040" gradientUnits="userSpaceOnUse">
                <stop offset="0" stop-color="#F4C95D" />
                <stop offset="1" stop-color="#7BBF91" />
              </linearGradient>
              <filter id="c1v3-dot-glow" x="-200%" y="-200%" width="500%" height="500%">
                <feGaussianBlur stdDeviation="10" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
              </filter>
            </defs>

            <circle id="c1v3-loop-base" cx="540" cy="450" r="320" fill="none" stroke="#353532" stroke-width="7" />
            <path id="c1v3-loop-line" d="M540 130 A320 320 0 1 1 539.9 130" fill="none" stroke="#F4C95D" stroke-width="13" stroke-linecap="round" />
            <path id="c1v3-loop-runner" d="M540 130 A320 320 0 1 1 539.9 130" fill="none" stroke="#F4C95D" stroke-width="20" stroke-linecap="round" />
            <path id="c1v3-exit-line" d="M860 450 C900 635 805 785 650 860 C540 910 455 942 380 970" fill="none" stroke="url(#c1v3-exit-gradient)" stroke-width="14" stroke-linecap="round" />

            <circle class="c1v3-node-dot c1v3-dot-thought" cx="540" cy="130" r="12" />
            <circle class="c1v3-node-dot c1v3-dot-anxiety" cx="860" cy="450" r="12" />
            <circle class="c1v3-node-dot c1v3-dot-compulsion" cx="540" cy="770" r="12" />
            <circle class="c1v3-node-dot c1v3-dot-relief" cx="220" cy="450" r="12" />
            <circle id="c1v3-stop-ring" cx="860" cy="450" r="36" fill="none" stroke="#D26A6A" stroke-width="4" />
            <circle id="c1v3-playhead-halo" r="26" fill="#F4C95D" opacity=".12" />
            <circle id="c1v3-playhead" r="11" fill="#F4C95D" />
          </svg>

          <div class="c1v3-node c1v3-node-thought"><small>01</small><strong>Intrusive thought</strong></div>
          <div class="c1v3-node c1v3-node-anxiety"><small>02</small><strong>Anxiety spikes</strong></div>
          <div class="c1v3-node c1v3-node-compulsion"><small>03</small><strong>Compulsion</strong></div>
          <div class="c1v3-node c1v3-node-relief"><small>04</small><strong>Temporary relief</strong></div>

          <div class="c1v3-center-copy">
            <strong>RELIEF</strong>
            <span>sends the cycle<br>around again</span>
          </div>

          <div class="c1v3-pause-label"><small>ERP STARTS WITH A PAUSE</small><strong>Delay the compulsion</strong></div>

          <div class="c1v3-timer">
            <div class="c1v3-timer-visual">
              <svg viewBox="0 0 200 200">
                <circle cx="100" cy="100" r="78" class="c1v3-timer-base" />
                <circle cx="100" cy="100" r="78" id="c1v3-timer-progress" />
              </svg>
              <svg class="c1v3-clock" viewBox="0 0 24 24"><path d="M12 7v5l3 2M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z"/></svg>
            </div>
            <div class="c1v3-timer-copy">
              <small>COMPULSION DELAY</small>
              <strong>Sit with the urge.</strong>
              <span>15:00 practice</span>
            </div>
          </div>
        </section>

        <section class="c1v3-product">
          <div class="c1v3-phone">
            <img src="${HOME_SCREEN}" alt="Patterns Home screen showing Compulsion Delay" />
          </div>
          <div class="c1v3-product-caption"><span>Compulsion Delay</span><strong>Built into Patterns.</strong></div>
        </section>

        <section class="c1v3-cta">
          <span class="c1v3-cta-brand">Patterns</span>
          <h2>Practice a different response.</h2>
          <p>Private OCD tracking and ERP tools, on-device.</p>
          <div class="c1v3-download">
            <svg viewBox="0 0 24 24"><path fill="currentColor" d="M17.1 20.3c-1 .9-2.1.8-3.1.4-1.1-.5-2.1-.5-3.2 0-1.5.6-2.2.4-3.1-.4-3.9-4-3-11.2 1.7-11.4 1.4.1 2.3.8 3.1.8.8 0 1.9-.9 3.5-.7 1.7.2 2.8 1 3.4 2-3.3 2-2.5 6.6.7 7.9-.7 1.7-1.4 3.4-3 3.4M14 7.5c.9-1.1 1.5-2.6 1.2-4.1-1.3.1-3 1-3.8 2-.8.9-1.4 2.5-1.1 3.9 1.5.1 2.9-.7 3.7-1.8Z"/></svg>
            <span>Download Patterns</span>
          </div>
          <small>No account&nbsp;&nbsp;•&nbsp;&nbsp;No subscription&nbsp;&nbsp;•&nbsp;&nbsp;Entries stay on-device</small>
        </section>

        <div class="c1v3-progress"><i></i></div>
      </main>`;
  }

  window.initConcept1 = function initConcept1V3() {
    const view = document.getElementById('concept-1');
    view.classList.remove('hidden');
    view.innerHTML = markup();
    window.animationDuration = 15;

    const tl = animationTimeline;
    tl.clear();

    const loop = document.getElementById('c1v3-loop-line');
    const runner = document.getElementById('c1v3-loop-runner');
    const exitLine = document.getElementById('c1v3-exit-line');
    const playhead = document.getElementById('c1v3-playhead');
    const halo = document.getElementById('c1v3-playhead-halo');
    const timerProgress = document.getElementById('c1v3-timer-progress');
    const loopLength = loop.getTotalLength();
    const exitLength = exitLine.getTotalLength();
    const timerLength = 2 * Math.PI * 78;

    const positionPlayhead = (distance) => {
      const p = loop.getPointAtLength(Math.max(0, Math.min(loopLength, distance)));
      playhead.setAttribute('cx', p.x); playhead.setAttribute('cy', p.y);
      halo.setAttribute('cx', p.x); halo.setAttribute('cy', p.y);
    };

    loop.setAttribute('stroke-dasharray', `${loopLength} ${loopLength}`);
    loop.setAttribute('stroke-dashoffset', `${loopLength}`);
    runner.setAttribute('stroke-dasharray', `90 ${loopLength - 90}`);
    runner.setAttribute('opacity', '0');
    exitLine.setAttribute('stroke-dasharray', `${exitLength} ${exitLength}`);
    exitLine.setAttribute('stroke-dashoffset', `${exitLength}`);
    timerProgress.setAttribute('stroke-dasharray', `${timerLength} ${timerLength}`);
    timerProgress.setAttribute('stroke-dashoffset', `${timerLength}`);
    gsap.set([
      '.c1v3-kicker', '.c1v3-title-loop', '.c1v3-subtitle-loop', '.c1v3-node',
      '.c1v3-center-copy', '.c1v3-title-exit', '.c1v3-subtitle-exit',
      '.c1v3-pause-label', '.c1v3-timer', '.c1v3-product', '.c1v3-product-caption',
      '.c1v3-cta', '#c1v3-stop-ring'
    ], { opacity: 0 });
    gsap.set('.c1v3-node', { y: 12 });
    gsap.set('.c1v3-title-exit, .c1v3-subtitle-exit', { y: 18 });
    gsap.set('.c1v3-timer', { y: 25 });
    gsap.set('.c1v3-product', { scale: 1.08, transformOrigin: '50% 50%' });
    gsap.set('.c1v3-phone', { scale: 1.55, y: -235, transformOrigin: '50% 47%' });
    gsap.set('.c1v3-product-caption', { y: 18 });
    gsap.set('.c1v3-cta', { y: 36 });
    gsap.set('.c1v3-progress i', { scaleX: 0, transformOrigin: 'left center' });
    positionPlayhead(0);

    tl.to('.c1v3-kicker', { opacity: 1, duration: .35 }, .05);
    tl.to('.c1v3-title-loop', { opacity: 1, duration: .45, ease: 'power2.out' }, .1);
    tl.to('.c1v3-subtitle-loop', { opacity: 1, duration: .4 }, .35);

    const first = { distance: 0, offset: loopLength };
    tl.to(first, {
      distance: loopLength, offset: 0, duration: 3.65, ease: 'power1.inOut',
      onUpdate: () => { loop.setAttribute('stroke-dashoffset', `${first.offset}`); positionPlayhead(first.distance); }
    }, .25);
    tl.to('.c1v3-node-thought', { opacity: 1, y: 0, duration: .3 }, .35);
    tl.to('.c1v3-node-anxiety', { opacity: 1, y: 0, duration: .3 }, 1.2);
    tl.to('.c1v3-node-compulsion', { opacity: 1, y: 0, duration: .3 }, 2.08);
    tl.to('.c1v3-node-relief', { opacity: 1, y: 0, duration: .3 }, 2.96);
    tl.to('.c1v3-dot-anxiety', { fill: '#D26A6A', duration: .22, yoyo: true, repeat: 1 }, 1.25);
    tl.to('.c1v3-center-copy', { opacity: 1, scale: 1, duration: .45, ease: 'power2.out' }, 3.35);

    const second = { distance: 0 };
    tl.set(runner, { opacity: .34 }, 3.95);
    tl.to(second, {
      distance: loopLength, duration: 1.28, ease: 'none',
      onUpdate: () => { runner.setAttribute('stroke-dashoffset', `${-second.distance}`); positionPlayhead(second.distance); }
    }, 3.95);
    tl.to(runner, { opacity: 0, duration: .2 }, 5.13);

    tl.add(() => positionPlayhead(loopLength * .25), 5.24);
    tl.to('#c1v3-stop-ring', { opacity: 1, scale: 1.2, transformOrigin: '860px 450px', duration: .25, yoyo: true, repeat: 1 }, 5.24);
    tl.to(['.c1v3-title-loop', '.c1v3-subtitle-loop', '.c1v3-center-copy'], { opacity: 0, y: -14, duration: .32 }, 5.2);
    tl.to('.c1v3-title-exit', { opacity: 1, y: 0, duration: .42, ease: 'power2.out' }, 5.42);
    tl.to('.c1v3-subtitle-exit', { opacity: 1, y: 0, duration: .4 }, 5.62);
    tl.to(['.c1v3-node-compulsion', '.c1v3-node-relief'], { opacity: .12, duration: .35 }, 5.25);
    tl.to(['#c1v3-loop-base', '#c1v3-loop-line'], { opacity: .16, duration: .35 }, 5.25);
    tl.to('.c1v3-pause-label', { opacity: 1, duration: .4 }, 5.55);

    const branch = { offset: exitLength };
    tl.to(branch, {
      offset: 0, duration: 1.55, ease: 'power2.inOut',
      onUpdate: () => { exitLine.setAttribute('stroke-dashoffset', `${branch.offset}`); }
    }, 5.72);
    tl.to('.c1v3-timer', { opacity: 1, y: 0, duration: .5, ease: 'power2.out' }, 6.9);
    tl.to(timerProgress, { strokeDashoffset: timerLength * .18, duration: 1.25, ease: 'power2.out' }, 7.0);
    tl.from('.c1v3-timer-copy > *', { opacity: 0, x: 18, stagger: .08, duration: .3 }, 7.02);

    tl.to('.c1v3-stage, .c1v3-header', { opacity: 0, duration: .5, ease: 'power2.in' }, 8.4);
    tl.to('.c1v3-product', { opacity: 1, scale: 1, duration: .65, ease: 'power2.out' }, 8.55);
    tl.to('.c1v3-product-caption', { opacity: 1, y: 0, duration: .42 }, 8.78);
    tl.to('.c1v3-phone', { scale: 1, y: 0, duration: 1.7, ease: 'power2.inOut' }, 9.45);
    tl.to('.c1v3-product-caption', { opacity: 0, y: -12, duration: .3 }, 10.8);

    tl.to('.c1v3-phone', { y: -70, duration: .8, ease: 'power2.inOut' }, 11.7);
    tl.to('.c1v3-cta', { opacity: 1, y: 0, duration: .6, ease: 'power2.out' }, 12.0);
    tl.from('.c1v3-download', { scale: .94, duration: .45, ease: 'back.out(1.2)' }, 12.35);
    tl.to('.c1v3-progress i', { scaleX: 1, duration: 15, ease: 'none' }, 0);
  };
})();
