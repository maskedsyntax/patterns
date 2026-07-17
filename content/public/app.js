// Parse URL params to select concept
const urlParams = new URLSearchParams(window.location.search);
const concept = parseInt(urlParams.get('concept') || '1', 10);

// Global timing controller for Puppeteer
let animationTimeline = gsap.timeline({ paused: true });
window.animationDuration = 10; // 10-second standard video ad

// Expose seek function for the Puppeteer capture script
window.seekToFrame = function(frameNumber, fps) {
  const time = frameNumber / fps;
  // Keep onUpdate callbacks enabled: SVG path drawing and moving playheads are
  // calculated in those callbacks and must be evaluated for deterministic
  // frame-by-frame exports.
  animationTimeline.seek(time, false);
};

document.addEventListener('DOMContentLoaded', () => {
  if (concept === 1) {
    initConcept1();
  } else {
    initConcept2();
  }
});

/* ========================================================================== */
/* CONCEPT 1: OCD Loop vs ERP Exit                                            */
/* ========================================================================== */
function initConcept1() {
  document.getElementById('concept-1').classList.remove('hidden');
  
  const ocdPath = document.getElementById('ocd-circle');
  const erpPath = document.getElementById('erp-detour');
  
  const ocdLength = ocdPath.getTotalLength();
  const erpLength = erpPath.getTotalLength();
  
  // Set initial stroke-dash properties for drawing effect
  gsap.set(ocdPath, {
    strokeDasharray: ocdLength,
    strokeDashoffset: ocdLength
  });
  
  gsap.set(erpPath, {
    strokeDasharray: erpLength,
    strokeDashoffset: erpLength,
    opacity: 0
  });

  // Trackers and Nodes
  const tracker = document.getElementById('tracker');
  const nodes = {
    obsession: document.getElementById('node-obsession'),
    anxiety: document.getElementById('node-anxiety'),
    compulsion: document.getElementById('node-compulsion'),
    relief: document.getElementById('node-relief'),
    erp: document.getElementById('node-erp')
  };

  // Initially hide nodes or scale them down
  gsap.set(Object.values(nodes), { scale: 0, opacity: 0 });
  gsap.set(tracker, { opacity: 0 });

  const tl = animationTimeline;

  // Frame seekable timeline construction
  // 1. Draw base path and pop-up nodes
  const pathObj = { offset: ocdLength };
  
  tl.to(tracker, { opacity: 1, duration: 0.1 }, 0);

  // Path draws from Obsession -> Anxiety
  tl.to(pathObj, {
    offset: ocdLength * 0.75, // 25% of circle
    duration: 1.0,
    ease: "power2.out",
    onUpdate: () => {
      ocdPath.style.strokeDashoffset = pathObj.offset;
      updateTrackerPosition(ocdPath, ocdLength - pathObj.offset);
    }
  }, 0);
  
  tl.to(nodes.obsession, { scale: 1, opacity: 1, ease: "back.out(1.7)", duration: 0.5 }, 0.1);
  tl.to(nodes.anxiety, { scale: 1, opacity: 1, ease: "back.out(1.7)", duration: 0.5 }, 0.8);

  // Path draws Anxiety -> Compulsion
  tl.to(pathObj, {
    offset: ocdLength * 0.5, // 50% of circle
    duration: 1.0,
    ease: "power2.inOut",
    onUpdate: () => {
      ocdPath.style.strokeDashoffset = pathObj.offset;
      updateTrackerPosition(ocdPath, ocdLength - pathObj.offset);
    }
  }, 1.0);
  
  tl.to(nodes.compulsion, { scale: 1, opacity: 1, ease: "back.out(1.7)", duration: 0.5 }, 1.8);

  // Path draws Compulsion -> Temporary Relief
  tl.to(pathObj, {
    offset: ocdLength * 0.25, // 75% of circle
    duration: 1.0,
    ease: "power2.inOut",
    onUpdate: () => {
      ocdPath.style.strokeDashoffset = pathObj.offset;
      updateTrackerPosition(ocdPath, ocdLength - pathObj.offset);
    }
  }, 2.0);
  
  tl.to(nodes.relief, { scale: 1, opacity: 1, ease: "back.out(1.7)", duration: 0.5 }, 2.8);

  // Path draws Temporary Relief -> Obsession (Completing the cycle)
  tl.to(pathObj, {
    offset: 0, // 100% of circle
    duration: 1.0,
    ease: "power2.in",
    onUpdate: () => {
      ocdPath.style.strokeDashoffset = pathObj.offset;
      updateTrackerPosition(ocdPath, ocdLength - pathObj.offset);
    }
  }, 3.0);

  // Anxiety node pulses and shakes representing high distress in the loop
  tl.to(nodes.anxiety, {
    boxShadow: "0 0 30px rgba(224, 93, 93, 0.8)",
    repeat: 3,
    yoyo: true,
    duration: 0.4
  }, 1.2);
  
  // 2. Loop repetition representation
  // Quickly zip the tracker around the circle again to represent feeding the loop
  const loopObj = { val: 0 };
  tl.to(loopObj, {
    val: ocdLength,
    duration: 1.2,
    ease: "none",
    onUpdate: () => {
      updateTrackerPosition(ocdPath, loopObj.val);
    }
  }, 4.0);
  
  // Highlight the loop feed
  tl.to("#c1-glow", { opacity: 0.35, scale: 1.2, duration: 0.6 }, 4.0);
  tl.to("#c1-glow", { opacity: 0.15, scale: 1.0, duration: 0.6 }, 4.6);

  // 3. The Pivot - Breaking the Loop
  // Pause/Break occurs at Anxiety Node (t = 5.2s)
  // Stop tracker at Anxiety node position (25% of loop length)
  tl.add(() => {
    updateTrackerPosition(ocdPath, ocdLength * 0.25);
  }, 5.2);

  // Turn Compulsion & Relief nodes grey/transparent to show breaking cycle
  tl.to([nodes.compulsion, nodes.relief], {
    opacity: 0.15,
    scale: 0.9,
    filter: "grayscale(100%)",
    duration: 0.6,
    ease: "power2.out"
  }, 5.2);

  // Fade out/dim the bottom-left half of the loop path
  tl.to(ocdPath, {
    opacity: 0.1,
    duration: 0.6
  }, 5.2);

  // Animate detour path
  tl.to(erpPath, { opacity: 1, duration: 0.1 }, 5.8);
  
  const erpObj = { offset: erpLength };
  tl.to(erpObj, {
    offset: 0,
    duration: 1.2,
    ease: "power1.out",
    onUpdate: () => {
      erpPath.style.strokeDashoffset = erpObj.offset;
      updateTrackerPosition(erpPath, erpLength - erpObj.offset);
    }
  }, 5.8);

  // Pop up the ERP Compulsion Delay card
  tl.to(nodes.erp, {
    scale: 1,
    opacity: 1,
    ease: "elastic.out(1, 0.75)",
    duration: 1.2
  }, 6.5);
  
  // Calming glow transition
  tl.to("#c1-glow", {
    backgroundColor: "#F5C543",
    opacity: 0.2,
    duration: 1.0
  }, 6.2);

  // 4. Outro Slide / CTA
  // Fade out diagram elements
  tl.to([Object.values(nodes), ocdPath, erpPath, tracker], {
    opacity: 0,
    y: -50,
    duration: 0.6,
    stagger: 0.05,
    ease: "power2.in"
  }, 8.0);
  
  // Slide in Outro phone frame mockup
  tl.to("#c1-outro", {
    opacity: 1,
    pointerEvents: "auto",
    duration: 0.8,
    ease: "power2.out"
  }, 8.4);

  // Animate Mockup home elements popping up inside phone
  tl.from(".phone-frame", {
    y: 100,
    scale: 0.95,
    opacity: 0,
    duration: 0.8,
    ease: "back.out(1.1)"
  }, 8.4);

  tl.from([".app-header-row", ".app-card", ".quick-actions-row"], {
    y: 30,
    opacity: 0,
    stagger: 0.1,
    duration: 0.6,
    ease: "power2.out"
  }, 8.6);

  // Animate circular progress ring drawing
  gsap.set(".ring-indicator", { strokeDashoffset: 226 });
  tl.to(".ring-indicator", {
    strokeDashoffset: 40,
    duration: 1.2,
    ease: "power2.out"
  }, 9.0);

  // Animate compulsion progress line filling
  gsap.set(".progress-line-fill", { width: "0%" });
  tl.to(".progress-line-fill", {
    width: "100%",
    duration: 1.2,
    ease: "power2.out"
  }, 9.0);
}

function updateTrackerPosition(path, length) {
  try {
    const pt = path.getPointAtLength(length);
    gsap.set("#tracker", { x: pt.x, y: pt.y });
  } catch (e) {
    // Fallback if browser doesn't support getPointAtLength
  }
}

/* ========================================================================== */
/* CONCEPT 2: SUDS Distress Graph                                             */
/* ========================================================================== */
function initConcept2() {
  document.getElementById('concept-2').classList.remove('hidden');

  const svg = document.getElementById('c2-svg');
  const gridGroup = document.getElementById('graph-grid');
  const yTicksGroup = svg.querySelector('.y-ticks');
  const xTicksGroup = svg.querySelector('.x-ticks');

  // 1. Generate Grid and Labels programmatically
  const startX = 100, endX = 850, startY = 800, endY = 100;
  
  // Draw Y-axis grid & labels (0 to 10 score)
  for (let i = 0; i <= 10; i += 2) {
    const y = startY - (i * 70); // 70px per score unit
    
    // Grid line
    if (i > 0) {
      const line = document.createElementNS("http://www.w3.org/2000/svg", "line");
      line.setAttribute("x1", startX.toString());
      line.setAttribute("y1", y.toString());
      line.setAttribute("x2", endX.toString());
      line.setAttribute("y2", y.toString());
      line.setAttribute("class", "grid-line");
      gridGroup.appendChild(line);
    }
    
    // Label text
    const text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    text.setAttribute("x", (startX - 20).toString());
    text.setAttribute("y", (y + 6).toString());
    text.setAttribute("text-anchor", "end");
    text.setAttribute("class", "tick-text");
    text.textContent = i === 10 ? "10 (Peak)" : i.toString();
    yTicksGroup.appendChild(text);
  }

  // Draw X-axis grid & labels (0 to 25 mins)
  const timeLabels = ["0", "5", "10", "15", "20", "25 Mins"];
  for (let i = 0; i < timeLabels.length; i++) {
    const x = startX + (i * 150); // 150px per 5-minute unit
    
    // Grid line
    if (i > 0) {
      const line = document.createElementNS("http://www.w3.org/2000/svg", "line");
      line.setAttribute("x1", x.toString());
      line.setAttribute("y1", startY.toString());
      line.setAttribute("x2", x.toString());
      line.setAttribute("y2", endY.toString());
      line.setAttribute("class", "grid-line");
      gridGroup.appendChild(line);
    }
    
    // Label text
    const text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    text.setAttribute("x", x.toString());
    text.setAttribute("y", (startY + 35).toString());
    text.setAttribute("text-anchor", "middle");
    text.setAttribute("class", "tick-text");
    text.textContent = timeLabels[i];
    xTicksGroup.appendChild(text);
  }

  // 2. Generate SUDS Line points
  const points = [];
  
  // Phase 1: Spike (0 to 2 mins)
  // x: 100 -> 160 (rapid increase to SUDS 9.5)
  for (let x = 100; x <= 160; x += 2) {
    const t = (x - 100) / 60;
    const y = startY - t * (9.5 * 70); // SUDS 9.5
    points.push({ x, y });
  }
  
  // Phase 2: High plateau / Jitter (2 to 5 mins)
  // x: 160 -> 250
  for (let x = 162; x <= 250; x += 2) {
    const t = (x - 160) / 90;
    const jitter = Math.sin(x * 0.3) * 6; // Active panic jitter
    const y = (startY - (9.5 * 70)) + t * 40 + jitter; // subtle decay + jitter
    points.push({ x, y });
  }
  
  // Phase 3: Smooth exponential decay (5 to 25 mins)
  // x: 250 -> 850
  const decayStartY = points[points.length - 1].y;
  const targetDecayY = startY - (2 * 70); // SUDS 2
  for (let x = 252; x <= 850; x += 2) {
    const t = (x - 250) / 600; // 0 to 1
    const y = targetDecayY - (targetDecayY - decayStartY) * Math.exp(-4 * t);
    points.push({ x, y });
  }

  // Generate SVG Path coordinates
  let pathD = `M ${points[0].x},${points[0].y}`;
  for (let i = 1; i < points.length; i++) {
    pathD += ` L ${points[i].x},${points[i].y}`;
  }

  // Set line paths
  const graphLine = document.getElementById('graph-line');
  const graphArea = document.getElementById('graph-area-path');
  
  graphLine.setAttribute('d', pathD);
  
  const areaD = `${pathD} L ${points[points.length - 1].x},${startY} L ${points[0].x},${startY} Z`;
  graphArea.setAttribute('d', areaD);

  // Setup clip path details
  const clipPath = document.createElementNS("http://www.w3.org/2000/svg", "clipPath");
  clipPath.setAttribute("id", "reveal-clip");
  
  const clipRect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
  clipRect.setAttribute("x", "0");
  clipRect.setAttribute("y", "0");
  clipRect.setAttribute("width", "100"); // Start matching X coordinate
  clipRect.setAttribute("height", "900");
  clipPath.appendChild(clipRect);
  svg.appendChild(clipPath);

  // Apply clip-path to graph components
  graphLine.setAttribute("clip-path", "url(#reveal-clip)");
  graphArea.setAttribute("clip-path", "url(#reveal-clip)");

  // Tooltips
  const tooltipSpike = document.getElementById('tooltip-spike');
  const tooltipHabituate = document.getElementById('tooltip-habituate');
  const graphTracker = document.getElementById('graph-tracker');

  gsap.set(graphTracker, { opacity: 0 });

  // 3. Build Timeline
  const tl = animationTimeline;

  // Grid fade in
  tl.from([gridGroup, yTicksGroup, xTicksGroup], {
    opacity: 0,
    duration: 1.0,
    stagger: 0.1,
    ease: "power2.out"
  }, 0);

  // Reveal clip-rect & track cursor position (0 to 100%)
  const clipObj = { x: 100 };
  tl.to(graphTracker, { opacity: 1, duration: 0.1 }, 0.5);

  // Spike Phase (t = 0.5s to 2.2s)
  tl.to(clipObj, {
    x: 160,
    duration: 1.7,
    ease: "power3.out",
    onUpdate: () => {
      clipRect.setAttribute("width", clipObj.x.toString());
      updateGraphTracker(clipObj.x, points, graphTracker);
    }
  }, 0.5);

  // Pop up Peak Distress tooltip
  tl.to(tooltipSpike, {
    opacity: 1,
    scale: 1,
    ease: "back.out(1.5)",
    duration: 0.8
  }, 1.2);

  // Plateau / Panic Jitter Phase (t = 2.2s to 3.8s)
  tl.to(clipObj, {
    x: 250,
    duration: 1.6,
    ease: "none",
    onUpdate: () => {
      clipRect.setAttribute("width", clipObj.x.toString());
      updateGraphTracker(clipObj.x, points, graphTracker);
    }
  }, 2.2);

  // Smooth Exponential Decay Phase (t = 3.8s to 7.0s)
  tl.to(clipObj, {
    x: 850,
    duration: 3.2,
    ease: "power1.inOut",
    onUpdate: () => {
      clipRect.setAttribute("width", clipObj.x.toString());
      updateGraphTracker(clipObj.x, points, graphTracker);
    }
  }, 3.8);

  // Change tracker color dynamically during recovery
  tl.to(graphTracker, {
    fill: "#4EB586",
    duration: 2.0,
    ease: "power2.out"
  }, 4.8);

  // Pop up Habituation tooltip at bottom-right
  tl.to(tooltipHabituate, {
    opacity: 1,
    scale: 1,
    ease: "back.out(1.5)",
    duration: 0.8
  }, 6.0);

  // Slowly pulse glow of graph tracker
  tl.to("#c2-glow", { opacity: 0.3, duration: 1.5, repeat: 1, yoyo: true }, 1.5);

  // Fade out graph elements
  tl.to([svg, tooltipSpike, tooltipHabituate, ".y-axis-label", ".x-axis-label"], {
    opacity: 0,
    y: -40,
    duration: 0.6,
    stagger: 0.05,
    ease: "power2.in"
  }, 8.0);

  // Slide in Outro phone frame mockup
  tl.to("#c2-outro", {
    opacity: 1,
    pointerEvents: "auto",
    duration: 0.8,
    ease: "power2.out"
  }, 8.4);

  // Slide in phone frame mockup
  tl.from(".phone-frame", {
    y: 100,
    scale: 0.95,
    opacity: 0,
    duration: 0.8,
    ease: "back.out(1.1)"
  }, 8.4);

  // Pop up card elements inside Insights mockup
  tl.from([".app-header-row", ".insights-tabs", ".app-card"], {
    y: 30,
    opacity: 0,
    stagger: 0.1,
    duration: 0.6,
    ease: "power2.out"
  }, 8.6);

  // Animate mood graph inside insights card drawing
  const moodPath = document.querySelector(".mood-svg path");
  const moodPathLength = moodPath.getTotalLength();
  gsap.set(moodPath, {
    strokeDasharray: moodPathLength,
    strokeDashoffset: moodPathLength
  });
  tl.to(moodPath, {
    strokeDashoffset: 0,
    duration: 1.2,
    ease: "power2.out"
  }, 9.0);

  // Animate dots pop
  tl.from(".mood-svg circle", {
    scale: 0,
    stagger: 0.05,
    duration: 0.4,
    ease: "back.out(1.5)"
  }, 9.2);

  // Animate themes progress bars growing
  gsap.set(".theme-progress-bar", { width: "0%" });
  tl.to(".theme-progress-bar.red", { width: "100%", duration: 1.0, ease: "power2.out" }, 9.0);
  tl.to(".theme-progress-bar.orange", { width: "74%", duration: 1.0, ease: "power2.out" }, 9.1);
  tl.to(".theme-progress-bar.blue", { width: "71%", duration: 1.0, ease: "power2.out" }, 9.2);
}

function updateGraphTracker(currentX, points, trackerEl) {
  let closestPoint = points[0];
  let minDiff = Math.abs(points[0].x - currentX);
  
  for (let i = 1; i < points.length; i++) {
    const diff = Math.abs(points[i].x - currentX);
    if (diff < minDiff) {
      minDiff = diff;
      closestPoint = points[i];
    }
  }
  
  gsap.set(trackerEl, { cx: closestPoint.x, cy: closestPoint.y });
}
