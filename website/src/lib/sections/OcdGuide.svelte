<script lang="ts">
  import GuidePage from '$lib/components/GuidePage.svelte';
  import { Brain } from 'lucide-svelte';
</script>

<GuidePage
  icon={Brain}
  eyebrow="Understanding OCD"
  title="Intrusive thoughts are not who you are."
  intro="Obsessive-compulsive disorder isn't about being tidy or liking things 'just so.' It's an exhausting loop between thoughts you don't want and the things you do to feel safe. Understanding that loop is the first step to loosening its grip."
  related={[
    { label: 'How ERP works in Patterns', href: '/erp' },
    { label: 'Frequently asked questions', href: '/faq' }
  ]}
>
  <p class="lead">
    Almost everyone has strange, unwanted thoughts — a sudden image, a "what if," an
    urge that comes out of nowhere. For most people they pass like clouds. With OCD,
    the brain treats one of those thoughts as a genuine threat, and demands you do
    something about it.
  </p>

  <p>
    OCD is not a character flaw, and it is not the same as being careful or organised.
    It's a recognised mental-health condition built from two parts that feed each other:
    <strong>obsessions</strong> and <strong>compulsions</strong>.
  </p>

  <h2>Obsessions and compulsions</h2>
  <p>
    <strong>Obsessions</strong> are unwanted, intrusive thoughts, images, or urges that
    show up again and again and cause real distress. They often feel repugnant or
    frightening — which is exactly why they stick. The content tends to target what you
    care about most.
  </p>
  <p>
    <strong>Compulsions</strong> are the things you do to make that distress go away:
    repeated checking, washing, counting, reassurance-seeking, or quiet mental rituals
    nobody can see. They work — for a moment. And that brief relief is what keeps the
    whole thing running.
  </p>

  <h2>The OCD cycle</h2>
  <p>
    The reason OCD is so hard to think your way out of is that it's a self-reinforcing
    loop. Every time a compulsion brings relief, your brain learns the threat was real
    and the ritual "saved" you — so next time the urge is even stronger.
  </p>

  <div class="cycle">
    <div class="cycle-step">
      <h4>1 · Trigger</h4>
      <p>A situation, sensation, or thought sets things off.</p>
    </div>
    <div class="cycle-step">
      <h4>2 · Obsession</h4>
      <p>An intrusive thought latches on and won't let go.</p>
    </div>
    <div class="cycle-step">
      <h4>3 · Distress</h4>
      <p>Anxiety, dread, or disgust spikes fast.</p>
    </div>
    <div class="cycle-step">
      <h4>4 · Compulsion</h4>
      <p>You act to neutralise it and feel safe again.</p>
    </div>
    <div class="cycle-step">
      <h4>5 · Relief</h4>
      <p>Distress drops — briefly. The loop is reinforced.</p>
    </div>
  </div>

  <h2>OCD can attach to anything</h2>
  <p>
    OCD comes in many themes — contamination and washing, checking, symmetry and
    "just right" feelings, intrusive thoughts about harm, relationships, or religion and
    morality (sometimes called scrupulosity), and purely mental rituals with no visible
    sign at all. The theme isn't the point, and it doesn't say anything about you. What
    every version shares is the same loop above.
  </p>

  <h2>Seeing the pattern is what changes it</h2>
  <p>
    When you're inside the loop, an obsession feels like the truth and a compulsion feels
    like the only option. Writing things down breaks that spell. Naming a thought as an
    <em>obsession</em>, naming an action as a <em>compulsion</em>, and noticing how your
    distress actually rises and falls over time helps you see the cycle for what it is —
    a pattern, not a verdict.
  </p>
  <p>
    That awareness is also the foundation of the most evidence-based treatment for OCD:
    <a href="/erp">Exposure and Response Prevention (ERP)</a>, which gently teaches your
    brain that the distress fades on its own, without the ritual.
  </p>

  <div class="callout">
    <h3>How Patterns helps</h3>
    <p>
      Patterns gives you a calm, private space to log obsessions and compulsions as they
      happen, rate your distress on a 0–10 scale, and review the trend over days and
      weeks. Everything stays on your device — no accounts, no cloud — so it's a safe
      place to be honest. <a href="/#download">Download Patterns</a> or read about
      <a href="/erp">how it supports ERP</a>.
    </p>
  </div>
</GuidePage>
