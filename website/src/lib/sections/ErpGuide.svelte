<script lang="ts">
  import GuidePage from '$lib/components/GuidePage.svelte';
  import { Waves } from 'lucide-svelte';
</script>

<GuidePage
  icon={Waves}
  eyebrow="ERP & how Patterns helps"
  title="The urge will pass - even if you don't act on it."
  intro="Exposure and Response Prevention (ERP) is the most evidence-based therapy for OCD. It works by teaching your brain, through experience rather than reassurance, that anxiety fades on its own. Patterns is built to support that work between sessions."
  related={[
    { label: 'Understanding the OCD cycle', href: '/ocd' },
    { label: 'Frequently asked questions', href: '/faq' }
  ]}
>
  <p class="lead">
    Compulsions feel like they bring relief. ERP reveals something the OCD loop hides:
    if you sit with the discomfort and <em>don't</em> perform the ritual, the anxiety
    rises, peaks, and then comes down by itself. Do that enough times and the threat
    your brain attached to the thought quietly loses its power.
  </p>

  <h2>What ERP actually is</h2>
  <p>
    ERP has two halves. <strong>Exposure</strong> means deliberately, gradually facing
    the thoughts and situations that trigger your obsessions - starting small and working
    up at your own pace. <strong>Response prevention</strong> means choosing not to do the
    compulsion that usually follows. The "prevention" half is where the change happens.
  </p>
  <p>
    The goal isn't to grit your teeth forever. It's <em>habituation</em> and new learning:
    your nervous system discovers that the feared outcome doesn't arrive, and the alarm
    stops firing so loudly. ERP is most effective when guided by a trained therapist -
    Patterns is a companion for that work, not a replacement for it.
  </p>

  <h2>Why delaying a compulsion matters</h2>
  <p>
    You don't have to resist a compulsion perfectly to start breaking the loop. Even
    <strong>delaying</strong> it - waiting five minutes, then ten - gives the urge time to
    crest and fall, and shows you first-hand that you can tolerate the discomfort. Each
    delay is a small act of response prevention, and they add up.
  </p>

  <h2>How Patterns maps to ERP</h2>
  <p>
    Patterns turns the core moves of ERP into a quiet daily habit you can keep on your
    own terms:
  </p>
  <ul>
    <li>
      <strong>Log obsessions and compulsions</strong> as they happen, so you can tell the
      two apart and spot your triggers.
    </li>
    <li>
      <strong>Rate distress on a 0–10 scale</strong> (clinicians call this SUDS), the same
      language used in ERP, so you can watch anxiety actually come down over time.
    </li>
    <li>
      <strong>Use the Compulsion Delay Tool</strong> to pause an urge, ride out the wave,
      and record how it went - turning "I have to" into "I waited, and it passed."
    </li>
    <li>
      <strong>Review your patterns</strong> with charts and history, so progress becomes
      visible and you arrive at therapy sessions with clear, concrete notes.
    </li>
  </ul>

  <div class="callout">
    <h3>Your ERP practice, kept private</h3>
    <p>
      Everything you record stays on your device - no accounts, no cloud, no one watching.
      That privacy makes it easier to be honest, which is exactly what ERP needs.
      <a href="/#download">Download Patterns</a> or start with
      <a href="/ocd">understanding the OCD cycle</a>.
    </p>
  </div>

  <h2>A note on doing this well</h2>
  <p>
    ERP can be intense, and going too fast or doing it alone can backfire. If you can,
    work with an OCD-trained therapist who can build a plan with you. Use Patterns to
    support that plan - to notice patterns, log your exposures, and see how far you've
    come.
  </p>
</GuidePage>
