/* Concept 1 V4 — app-native vertical event trail, no circular diagram. */
(function () {
  const HOME_SCREEN =
    '/promo-screens/Simulator%20Screenshot%20-%20iPhone%2017%20-%202026-07-11%20at%2016.13.12.png';

  function markup() {
    return `
      <main class="c1v4">
        <header class="c1v4-header">
          <div class="c1v4-kicker"><span>Patterns</span><i></i><span>ERP, simplified</span></div>
          <div class="c1v4-title-stack">
            <h1 class="c1v4-title-loop">THE LOOP THAT REPEATS</h1>
            <h1 class="c1v4-title-exit">CHANGE ONE RESPONSE.</h1>
          </div>
          <p class="c1v4-sub-loop">Four moments can become one learned pattern.</p>
          <p class="c1v4-sub-exit">ERP creates space between the urge and the ritual.</p>
        </header>

        <section class="c1v4-stage">
          <div class="c1v4-focus-field"></div>
          <svg class="c1v4-svg" viewBox="0 0 1080 1230" aria-label="A repeating OCD event trail with an ERP exit">
            <path id="c1v4-rail-base" d="M180 120 L180 760" fill="none" stroke="#353532" stroke-width="8" stroke-linecap="round" />
            <path id="c1v4-rail-active" d="M180 120 L180 760" fill="none" stroke="#F4C95D" stroke-width="13" stroke-linecap="round" />
            <path id="c1v4-return-base" d="M180 760 C180 890 295 950 430 950 H720 C835 950 900 875 900 760 V185 C900 92 830 55 750 55 H180" fill="none" stroke="#2E2E2B" stroke-width="8" stroke-linecap="round" stroke-linejoin="round" />
            <path id="c1v4-return-active" d="M180 760 C180 890 295 950 430 950 H720 C835 950 900 875 900 760 V185 C900 92 830 55 750 55 H180" fill="none" stroke="#F4C95D" stroke-width="13" stroke-linecap="round" stroke-linejoin="round" />
            <path id="c1v4-runner" d="M180 120 L180 760 C180 890 295 950 430 950 H720 C835 950 900 875 900 760 V185 C900 92 830 55 750 55 H180 V120" fill="none" stroke="#F4C95D" stroke-width="20" stroke-linecap="round" stroke-linejoin="round" />
            <path id="c1v4-erp-branch" d="M180 333 C292 333 330 425 410 470 C468 503 518 528 580 545" fill="none" stroke="#7BBF91" stroke-width="18" stroke-linecap="round" />

            <circle class="c1v4-dot c1v4-thought-dot" cx="180" cy="120" r="13" />
            <circle class="c1v4-dot c1v4-anxiety-dot" cx="180" cy="333" r="13" />
            <circle class="c1v4-dot c1v4-compulsion-dot" cx="180" cy="546" r="13" />
            <circle class="c1v4-dot c1v4-relief-dot" cx="180" cy="760" r="13" />
            <circle id="c1v4-stop-ring" cx="180" cy="333" r="36" fill="none" stroke="#D26A6A" stroke-width="4" />
            <circle id="c1v4-playhead-halo" r="28" fill="#F4C95D" opacity=".12" />
            <circle id="c1v4-playhead" r="11" fill="#F4C95D" />
          </svg>

          <div class="c1v4-event c1v4-event-thought">
            <small>01</small><strong>Intrusive thought</strong><span>A thought arrives.</span>
          </div>
          <div class="c1v4-event c1v4-event-anxiety">
            <small>02</small><strong>Anxiety spikes</strong>
            <span class="c1v4-anxiety-before">The urge feels urgent.</span>
            <span class="c1v4-anxiety-after">Pause before the compulsion.</span>
          </div>
          <div class="c1v4-event c1v4-event-compulsion">
            <small>03</small><strong>Compulsion</strong><span>A ritual brings relief.</span>
          </div>
          <div class="c1v4-event c1v4-event-relief">
            <small>04</small><strong>Temporary relief</strong><span>The brain learns to repeat it.</span>
          </div>

          <div class="c1v4-return-copy"><small>AND BACK TO THE START</small><strong>Relief reinforces the route.</strong></div>
          <div class="c1v4-timer">
            <div class="c1v4-timer-ring">
              <svg viewBox="0 0 180 180">
                <circle cx="90" cy="90" r="70" class="c1v4-timer-base" />
                <circle cx="90" cy="90" r="70" id="c1v4-timer-progress" />
              </svg>
              <svg class="c1v4-clock" viewBox="0 0 24 24"><path d="M12 7v5l3 2M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z"/></svg>
            </div>
            <div class="c1v4-timer-copy">
              <small>COMPULSION DELAY</small>
              <strong>Sit with the urge.</strong>
              <span>15:00 practice</span>
            </div>
          </div>
        </section>

        <section class="c1v4-product">
          <div class="c1v4-phone"><img src="${HOME_SCREEN}" alt="Patterns Home screen" /></div>
        </section>

        <section class="c1v4-cta">
          <span>Patterns</span>
          <h2>Practice a different response.</h2>
          <p>Private OCD tracking and ERP tools, on-device.</p>
          <div class="c1v4-download">
            <svg viewBox="0 0 24 24"><path fill="currentColor" d="M17.1 20.3c-1 .9-2.1.8-3.1.4-1.1-.5-2.1-.5-3.2 0-1.5.6-2.2.4-3.1-.4-3.9-4-3-11.2 1.7-11.4 1.4.1 2.3.8 3.1.8.8 0 1.9-.9 3.5-.7 1.7.2 2.8 1 3.4 2-3.3 2-2.5 6.6.7 7.9-.7 1.7-1.4 3.4-3 3.4M14 7.5c.9-1.1 1.5-2.6 1.2-4.1-1.3.1-3 1-3.8 2-.8.9-1.4 2.5-1.1 3.9 1.5.1 2.9-.7 3.7-1.8Z"/></svg>
            <b>Download Patterns</b>
          </div>
          <small>No account&nbsp;&nbsp;•&nbsp;&nbsp;No subscription&nbsp;&nbsp;•&nbsp;&nbsp;Entries stay on-device</small>
        </section>
        <div class="c1v4-progress"><i></i></div>
      </main>`;
  }

  window.initConcept1 = function initConcept1V4() {
    const view = document.getElementById('concept-1');
    view.classList.remove('hidden');
    view.innerHTML = markup();
    window.animationDuration = 15;

    const tl = animationTimeline;
    tl.clear();

    const rail = document.getElementById('c1v4-rail-active');
    const returnPath = document.getElementById('c1v4-return-active');
    const runner = document.getElementById('c1v4-runner');
    const branch = document.getElementById('c1v4-erp-branch');
    const timerProgress = document.getElementById('c1v4-timer-progress');
    const playhead = document.getElementById('c1v4-playhead');
    const halo = document.getElementById('c1v4-playhead-halo');
    const railLength = rail.getTotalLength();
    const returnLength = returnPath.getTotalLength();
    const runnerLength = runner.getTotalLength();
    const branchLength = branch.getTotalLength();
    const timerLength = 2 * Math.PI * 70;

    const moveOn = (path, distance) => {
      const p = path.getPointAtLength(Math.max(0, Math.min(path.getTotalLength(), distance)));
      playhead.setAttribute('cx', p.x); playhead.setAttribute('cy', p.y);
      halo.setAttribute('cx', p.x); halo.setAttribute('cy', p.y);
    };
    const dash = (path, length) => {
      path.setAttribute('stroke-dasharray', `${length} ${length}`);
      path.setAttribute('stroke-dashoffset', `${length}`);
    };
    dash(rail, railLength); dash(returnPath, returnLength); dash(branch, branchLength);
    timerProgress.setAttribute('stroke-dasharray', `${timerLength} ${timerLength}`);
    timerProgress.setAttribute('stroke-dashoffset', `${timerLength}`);
    runner.setAttribute('stroke-dasharray', `92 ${runnerLength - 92}`);
    runner.setAttribute('opacity', '0');
    moveOn(rail, 0);

    gsap.set([
      '.c1v4-kicker', '.c1v4-title-loop', '.c1v4-sub-loop', '.c1v4-event',
      '.c1v4-return-copy', '.c1v4-title-exit', '.c1v4-sub-exit',
      '.c1v4-timer', '.c1v4-product', '.c1v4-cta', '#c1v4-stop-ring', '.c1v4-focus-field'
    ], { opacity: 0 });
    gsap.set('.c1v4-event', { x: -18 });
    gsap.set('.c1v4-anxiety-after', { opacity: 0, y: 8 });
    gsap.set('.c1v4-title-exit, .c1v4-sub-exit', { y: 16 });
    gsap.set('.c1v4-timer', { x: 18, scale: .94, transformOrigin: 'left center' });
    gsap.set('.c1v4-timer-copy', { opacity: 0, x: 14 });
    gsap.set('.c1v4-phone', { scale: .985, y: 12, transformOrigin: '50% 50%' });
    gsap.set('.c1v4-product', { opacity: 0 });
    gsap.set('.c1v4-cta', { y: 32 });
    gsap.set('.c1v4-progress i', { scaleX: 0, transformOrigin: 'left center' });

    tl.to('.c1v4-kicker', { opacity: 1, duration: .3 }, .05);
    tl.to('.c1v4-title-loop', { opacity: 1, duration: .42 }, .1);
    tl.to('.c1v4-sub-loop', { opacity: 1, duration: .4 }, .32);

    const down = { offset: railLength, distance: 0 };
    tl.to(down, {
      offset: 0, distance: railLength, duration: 2.45, ease: 'power1.inOut',
      onUpdate: () => { rail.setAttribute('stroke-dashoffset', `${down.offset}`); moveOn(rail, down.distance); }
    }, .28);
    tl.to('.c1v4-event-thought', { opacity: 1, x: 0, duration: .32 }, .36);
    tl.to('.c1v4-event-anxiety', { opacity: 1, x: 0, duration: .32 }, 1.02);
    tl.to('.c1v4-event-compulsion', { opacity: 1, x: 0, duration: .32 }, 1.68);
    tl.to('.c1v4-event-relief', { opacity: 1, x: 0, duration: .32 }, 2.34);

    const back = { offset: returnLength, distance: 0 };
    tl.to(back, {
      offset: 0, distance: returnLength, duration: 1.45, ease: 'power2.inOut',
      onUpdate: () => { returnPath.setAttribute('stroke-dashoffset', `${back.offset}`); moveOn(returnPath, back.distance); }
    }, 2.72);
    tl.to('.c1v4-return-copy', { opacity: 1, duration: .4 }, 3.05);

    const repeat = { distance: 0 };
    tl.set(runner, { opacity: .32 }, 4.18);
    tl.to(repeat, {
      distance: runnerLength, duration: 1.03, ease: 'none',
      onUpdate: () => { runner.setAttribute('stroke-dashoffset', `${-repeat.distance}`); moveOn(runner, repeat.distance); }
    }, 4.18);
    tl.to(runner, { opacity: 0, duration: .18 }, 5.12);

    tl.add(() => moveOn(rail, railLength / 3), 5.24);
    tl.to('#c1v4-stop-ring', { opacity: 1, scale: 1.18, transformOrigin: '180px 333px', duration: .24, yoyo: true, repeat: 1 }, 5.24);
    tl.to(['.c1v4-title-loop', '.c1v4-sub-loop'], { opacity: 0, y: -12, duration: .4, ease: 'power2.inOut' }, 5.14);
    tl.to('.c1v4-return-copy', { opacity: 0, y: 8, duration: .26, ease: 'power2.in' }, 5.14);
    tl.to('.c1v4-title-exit', { opacity: 1, y: 0, duration: .5, ease: 'power2.out' }, 5.52);
    tl.to('.c1v4-sub-exit', { opacity: 1, y: 0, duration: .44, ease: 'power2.out' }, 5.66);
    tl.to(['.c1v4-event-compulsion', '.c1v4-event-relief'], { opacity: 0, x: -16, y: 8, duration: .52, ease: 'power2.inOut' }, 5.18);
    tl.to('.c1v4-event-thought', { opacity: 0, x: -16, duration: .48, ease: 'power2.inOut' }, 5.18);
    tl.to([
      '#c1v4-return-base', '#c1v4-return-active', '#c1v4-rail-base', '#c1v4-rail-active',
      '.c1v4-thought-dot', '.c1v4-compulsion-dot', '.c1v4-relief-dot'
    ], { opacity: 0, duration: .58, ease: 'power2.inOut' }, 5.18);
    tl.to('.c1v4-focus-field', { opacity: 1, duration: .72, ease: 'power2.inOut' }, 5.28);
    tl.to('.c1v4-anxiety-before', { opacity: 0, y: -7, duration: .28, ease: 'power2.in' }, 5.28);
    tl.to('.c1v4-anxiety-after', { opacity: 1, y: 0, duration: .42, ease: 'power2.out' }, 5.5);
    tl.to('#c1v4-stop-ring', { opacity: 0, scale: 1.35, transformOrigin: '180px 333px', duration: .48, ease: 'power2.out' }, 5.82);

    const exit = { offset: branchLength };
    tl.to(exit, {
      offset: 0, duration: 1.5, ease: 'power2.inOut',
      onUpdate: () => branch.setAttribute('stroke-dashoffset', `${exit.offset}`)
    }, 5.72);
    tl.to('.c1v4-timer', { opacity: 1, x: 0, scale: 1, duration: .58, ease: 'power2.out' }, 6.58);
    tl.to('.c1v4-timer-copy', { opacity: 1, x: 0, duration: .48, ease: 'power2.out' }, 6.82);
    tl.to(timerProgress, { strokeDashoffset: timerLength * .18, duration: 1.05, ease: 'power2.out' }, 6.76);

    tl.to('.c1v4-stage, .c1v4-header', { opacity: 0, scale: .985, transformOrigin: '50% 48%', duration: .68, ease: 'power2.inOut' }, 8.25);
    tl.to('.c1v4-product', { opacity: 1, duration: .68, ease: 'power2.inOut' }, 8.42);
    tl.to('.c1v4-phone', { scale: 1, y: 0, duration: .82, ease: 'power2.out' }, 8.42);
    tl.to('.c1v4-phone', { y: -60, duration: .75, ease: 'power2.inOut' }, 11.65);
    tl.to('.c1v4-cta', { opacity: 1, y: 0, duration: .58 }, 11.95);
    tl.from('.c1v4-download', { scale: .95, duration: .4, ease: 'back.out(1.2)' }, 12.3);
    tl.to('.c1v4-progress i', { scaleX: 1, duration: 15, ease: 'none' }, 0);
  };
})();
