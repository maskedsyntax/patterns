/* Concept 1, production redesign: one continuous line becomes Patterns UI. */
(function () {
  const HOME_SCREEN =
    '/promo-screens/Simulator%20Screenshot%20-%20iPhone%2017%20-%202026-07-11%20at%2016.13.12.png';

  function markup() {
    return `
      <main class="c1v2" aria-label="Patterns OCD loop animation">
        <div class="c1v2-grain"></div>
        <header class="c1v2-header">
          <div class="c1v2-brand">
            <span class="c1v2-brand-mark" aria-hidden="true">
              <i></i><i></i><i></i>
            </span>
            <span>PATTERNS</span>
          </div>
          <div class="c1v2-hook-wrap">
            <h1 class="c1v2-hook">OCD CAN FEEL<br>LIKE A LOOP</h1>
            <h1 class="c1v2-pivot-title">THE EXIT<br>STARTS HERE</h1>
          </div>
        </header>

        <section class="c1v2-stage">
          <svg class="c1v2-drawing" viewBox="0 0 1080 1340" role="img" aria-label="The OCD cycle and an ERP exit path">
            <defs>
              <filter id="c1v2-soft-glow" x="-100%" y="-100%" width="300%" height="300%">
                <feGaussianBlur stdDeviation="7" result="blur" />
                <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
              </filter>
              <linearGradient id="c1v2-detour-gradient" x1="850" y1="480" x2="440" y2="1040" gradientUnits="userSpaceOnUse">
                <stop offset="0" stop-color="#F4C95D"/>
                <stop offset="1" stop-color="#7BBF91"/>
              </linearGradient>
            </defs>

            <path id="c1v2-loop-base" d="M 540 170 A 310 310 0 1 1 539.9 170"
              fill="none" stroke="#343434" stroke-width="7" stroke-linecap="round" />
            <path id="c1v2-loop-active" d="M 540 170 A 310 310 0 1 1 539.9 170"
              fill="none" stroke="#F4C95D" stroke-width="11" stroke-linecap="round" />
            <path id="c1v2-loop-repeat" d="M 540 170 A 310 310 0 1 1 539.9 170"
              fill="none" stroke="#F4C95D" stroke-width="17" stroke-linecap="round" opacity="0" />
            <path id="c1v2-detour" d="M 850 480 C 920 650 810 860 610 935 C 525 968 470 1012 438 1055"
              fill="none" stroke="url(#c1v2-detour-gradient)" stroke-width="13" stroke-linecap="round" />

            <circle id="c1v2-anxiety-halo" cx="850" cy="480" r="28" fill="none" stroke="#D26A6A" stroke-width="4" />
            <circle id="c1v2-playhead-glow" r="25" fill="#F4C95D" opacity=".17" filter="url(#c1v2-soft-glow)" />
            <circle id="c1v2-playhead" r="11" fill="#F4C95D" />
            <circle id="c1v2-detour-end" cx="438" cy="1055" r="10" fill="#7BBF91" />
          </svg>

          <div class="c1v2-label c1v2-label-thought">
            <span class="c1v2-anchor"></span>
            <small>01</small><strong>INTRUSIVE THOUGHT</strong>
          </div>
          <div class="c1v2-label c1v2-label-anxiety">
            <span class="c1v2-anchor"></span>
            <small>02</small><strong>ANXIETY SPIKES</strong>
          </div>
          <div class="c1v2-label c1v2-label-compulsion">
            <span class="c1v2-anchor"></span>
            <small>03</small><strong>COMPULSION</strong>
          </div>
          <div class="c1v2-label c1v2-label-relief">
            <span class="c1v2-anchor"></span>
            <small>04</small><strong>TEMPORARY RELIEF</strong>
          </div>

          <div class="c1v2-loop-caption">RELIEF. THEN THE LOOP RETURNS.</div>
          <div class="c1v2-erp-cue">
            <span>PAUSE</span>
            <strong>DELAY THE COMPULSION</strong>
          </div>

          <div class="c1v2-timer">
            <div class="c1v2-timer-ring">
              <svg viewBox="0 0 220 220" aria-hidden="true">
                <circle cx="110" cy="110" r="88" class="c1v2-ring-base" />
                <circle cx="110" cy="110" r="88" id="c1v2-ring-progress" />
              </svg>
              <div class="c1v2-timer-icon">
                <svg viewBox="0 0 24 24"><path d="M12 7v5l3.5 2M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z"/></svg>
              </div>
            </div>
            <div class="c1v2-timer-copy">
              <small>ERP PRACTICE</small>
              <h2>Compulsion Delay</h2>
              <p>Resist the urge, ride the wave.</p>
              <div class="c1v2-time"><span>15:00</span><i></i></div>
            </div>
          </div>
        </section>

        <section class="c1v2-product">
          <div class="c1v2-phone">
            <img src="${HOME_SCREEN}" alt="Patterns Home screen" />
            <div class="c1v2-practice-focus"></div>
          </div>
          <div class="c1v2-product-label">
            <span>BUILT INTO PATTERNS</span>
            <strong>Practice a different response.</strong>
          </div>
        </section>

        <section class="c1v2-cta">
          <div class="c1v2-cta-brand">
            <span class="c1v2-cta-mark"><i></i><i></i><i></i></span>
            <strong>Patterns</strong>
          </div>
          <h2>BREAK THE LOOP.<br>BUILD A NEW PATTERN.</h2>
          <div class="c1v2-download">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M17.1 20.3c-1 .9-2.1.8-3.1.4-1.1-.5-2.1-.5-3.2 0-1.5.6-2.2.4-3.1-.4-3.9-4-3-11.2 1.7-11.4 1.4.1 2.3.8 3.1.8.8 0 1.9-.9 3.5-.7 1.7.2 2.8 1 3.4 2-3.3 2-2.5 6.6.7 7.9-.7 1.7-1.4 3.4-3 3.4M14 7.5c.9-1.1 1.5-2.6 1.2-4.1-1.3.1-3 1-3.8 2-.8.9-1.4 2.5-1.1 3.9 1.5.1 2.9-.7 3.7-1.8Z"/></svg>
            <span>Download Patterns</span>
          </div>
          <p>Your entries stay on-device&nbsp;&nbsp;•&nbsp;&nbsp;No account&nbsp;&nbsp;•&nbsp;&nbsp;No subscription</p>
        </section>

        <div class="c1v2-progress" aria-hidden="true"><i></i></div>
      </main>`;
  }

  window.initConcept1 = function initConcept1V2() {
    const view = document.getElementById('concept-1');
    view.classList.remove('hidden');
    view.innerHTML = markup();
    window.animationDuration = 15;

    const tl = animationTimeline;
    tl.clear();

    const loop = document.getElementById('c1v2-loop-active');
    const repeat = document.getElementById('c1v2-loop-repeat');
    const detour = document.getElementById('c1v2-detour');
    const ring = document.getElementById('c1v2-ring-progress');
    const playhead = document.getElementById('c1v2-playhead');
    const playheadGlow = document.getElementById('c1v2-playhead-glow');
    const loopLength = loop.getTotalLength();
    const detourLength = detour.getTotalLength();
    const ringLength = 2 * Math.PI * 88;

    const setPlayhead = (path, distance) => {
      const point = path.getPointAtLength(Math.max(0, Math.min(path.getTotalLength(), distance)));
      playhead.setAttribute('cx', point.x);
      playhead.setAttribute('cy', point.y);
      playheadGlow.setAttribute('cx', point.x);
      playheadGlow.setAttribute('cy', point.y);
    };

    gsap.set(loop, { strokeDasharray: loopLength, strokeDashoffset: loopLength });
    gsap.set(detour, { strokeDasharray: detourLength, strokeDashoffset: detourLength });
    gsap.set(ring, { strokeDasharray: ringLength, strokeDashoffset: ringLength });
    gsap.set([
      '.c1v2-brand', '.c1v2-hook', '.c1v2-label', '.c1v2-loop-caption',
      '.c1v2-erp-cue', '.c1v2-timer', '#c1v2-anxiety-halo', '#c1v2-detour-end',
      '.c1v2-product', '.c1v2-product-label', '.c1v2-practice-focus', '.c1v2-cta'
    ], { opacity: 0 });
    gsap.set('.c1v2-pivot-title', { opacity: 0, y: 24 });
    gsap.set('.c1v2-label', { y: 18 });
    gsap.set('.c1v2-timer', { y: 45, scale: 0.96, transformOrigin: '260px 110px' });
    gsap.set('.c1v2-product', { scale: 0.92, transformOrigin: '50% 55%' });
    gsap.set('.c1v2-cta', { y: 54 });
    gsap.set('.c1v2-progress i', { scaleX: 0, transformOrigin: 'left center' });
    setPlayhead(loop, 0);

    tl.to('.c1v2-brand', { opacity: 1, duration: 0.35, ease: 'power2.out' }, 0.05);
    tl.to('.c1v2-hook', { opacity: 1, y: 0, duration: 0.55, ease: 'power3.out' }, 0.08);

    const firstPass = { distance: 0, offset: loopLength };
    tl.to(firstPass, {
      distance: loopLength,
      offset: 0,
      duration: 3.35,
      ease: 'power1.inOut',
      onUpdate: () => {
        loop.style.strokeDashoffset = firstPass.offset;
        setPlayhead(loop, firstPass.distance);
      }
    }, 0.18);

    tl.to('.c1v2-label-thought', { opacity: 1, y: 0, duration: 0.32, ease: 'power2.out' }, 0.38);
    tl.to('.c1v2-label-anxiety', { opacity: 1, y: 0, duration: 0.32, ease: 'power2.out' }, 1.15);
    tl.to('.c1v2-label-compulsion', { opacity: 1, y: 0, duration: 0.32, ease: 'power2.out' }, 1.98);
    tl.to('.c1v2-label-relief', { opacity: 1, y: 0, duration: 0.32, ease: 'power2.out' }, 2.78);
    tl.to('.c1v2-label-anxiety .c1v2-anchor', {
      backgroundColor: '#D26A6A', boxShadow: '0 0 0 14px rgba(210,106,106,.12)',
      duration: 0.28, yoyo: true, repeat: 1
    }, 1.25);

    tl.to(loop, { strokeWidth: 16, duration: 0.4, ease: 'power2.out' }, 3.45);
    tl.to('.c1v2-loop-caption', { opacity: 1, y: 0, duration: 0.45, ease: 'power2.out' }, 3.55);

    const secondPass = { distance: 0 };
    tl.set(repeat, { opacity: 0.34, strokeDasharray: `82 ${loopLength - 82}`, strokeDashoffset: 0 }, 3.66);
    tl.to(secondPass, {
      distance: loopLength,
      duration: 1.42,
      ease: 'none',
      onUpdate: () => {
        repeat.style.strokeDashoffset = `${-secondPass.distance}`;
        setPlayhead(loop, secondPass.distance);
      }
    }, 3.66);
    tl.to(repeat, { opacity: 0, duration: 0.22 }, 5.02);

    tl.add(() => setPlayhead(loop, loopLength * 0.25), 5.18);
    tl.to('#c1v2-anxiety-halo', { opacity: 1, scale: 1.35, transformOrigin: '850px 480px', duration: 0.28, ease: 'power2.out' }, 5.18);
    tl.to('#c1v2-anxiety-halo', { scale: 1, duration: 0.35, ease: 'power2.inOut' }, 5.46);
    tl.to(['.c1v2-label-compulsion', '.c1v2-label-relief'], { opacity: 0.16, duration: 0.48 }, 5.18);
    tl.to(['#c1v2-loop-base', '#c1v2-loop-active'], { opacity: 0.18, duration: 0.48 }, 5.18);
    tl.to('.c1v2-loop-caption', { opacity: 0, y: -12, duration: 0.3 }, 5.12);
    tl.to('.c1v2-hook', { opacity: 0, y: -18, duration: 0.35 }, 5.18);
    tl.to('.c1v2-pivot-title', { opacity: 1, y: 0, duration: 0.48, ease: 'power3.out' }, 5.42);
    tl.to('.c1v2-erp-cue', { opacity: 1, duration: 0.35, ease: 'power2.out' }, 5.42);

    const detourDraw = { offset: detourLength };
    tl.to(detourDraw, {
      offset: 0,
      duration: 1.62,
      ease: 'power2.inOut',
      onUpdate: () => { detour.style.strokeDashoffset = detourDraw.offset; }
    }, 5.72);
    tl.to('#c1v2-detour-end', { opacity: 1, scale: 1.4, transformOrigin: '438px 1055px', duration: 0.25, yoyo: true, repeat: 1 }, 7.15);

    tl.to('.c1v2-timer', { opacity: 1, y: 0, scale: 1, duration: 0.65, ease: 'power3.out' }, 6.88);
    tl.to(ring, { strokeDashoffset: ringLength * 0.18, duration: 1.45, ease: 'power2.out' }, 7.08);
    tl.from('.c1v2-timer-copy > *', { opacity: 0, x: 28, stagger: 0.09, duration: 0.35, ease: 'power2.out' }, 7.12);
    tl.fromTo('.c1v2-time i', { scaleX: 0 }, { scaleX: 1, transformOrigin: 'left center', duration: 1.15, ease: 'power2.out' }, 7.48);

    tl.to(['.c1v2-label', '#c1v2-loop-base', '#c1v2-loop-active', '#c1v2-anxiety-halo', '.c1v2-erp-cue'], {
      opacity: 0, y: -28, duration: 0.55, stagger: 0.025, ease: 'power2.in'
    }, 8.78);
    tl.to('.c1v2-pivot-title', { opacity: 0, y: -18, duration: 0.35 }, 8.85);
    tl.to(['#c1v2-detour', '#c1v2-detour-end', '#c1v2-playhead', '#c1v2-playhead-glow'], { opacity: 0, duration: 0.45 }, 9.0);

    tl.to('.c1v2-product', { opacity: 1, scale: 1, duration: 0.78, ease: 'power3.out' }, 9.15);
    tl.to('.c1v2-timer', { x: -253, y: -110, scale: 0.72, duration: 0.78, ease: 'power2.inOut' }, 9.15);
    tl.to('.c1v2-timer-copy', { opacity: 0, duration: 0.35 }, 9.22);
    tl.to('.c1v2-timer', { opacity: 0, duration: 0.38 }, 9.78);
    tl.to('.c1v2-practice-focus', { opacity: 1, duration: 0.42, ease: 'power2.out' }, 9.65);
    tl.to('.c1v2-product-label', { opacity: 1, y: 0, duration: 0.55, ease: 'power3.out' }, 10.05);
    tl.to('.c1v2-practice-focus', { boxShadow: '0 0 0 3px rgba(244,201,93,.82), 0 0 48px rgba(244,201,93,.2)', duration: 0.45, yoyo: true, repeat: 1 }, 10.3);

    tl.to('.c1v2-product-label', { opacity: 0, y: -20, duration: 0.35 }, 11.7);
    tl.to('.c1v2-phone', { y: -64, scale: 1.035, duration: 1.0, ease: 'power2.inOut' }, 11.65);
    tl.to('.c1v2-cta', { opacity: 1, y: 0, duration: 0.72, ease: 'power3.out' }, 12.0);
    tl.from('.c1v2-download', { scale: 0.92, duration: 0.5, ease: 'back.out(1.25)' }, 12.45);
    tl.to('.c1v2-progress i', { scaleX: 1, duration: 15, ease: 'none' }, 0);
  };
})();
