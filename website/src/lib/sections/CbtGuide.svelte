<script lang="ts">
  import GuidePage from '$lib/components/GuidePage.svelte';
  import { BrainCircuit } from 'lucide-svelte';
</script>

<GuidePage
  icon={BrainCircuit}
  eyebrow="CBT for OCD & how Patterns helps"
  title="For OCD, the CBT that works is ERP."
  intro="Cognitive behavioral therapy (CBT) is a family of practical, evidence-based therapies. For OCD specifically, the CBT approach with the strongest evidence is ERP - exposure and response prevention. Patterns is a CBT and ERP app built around that work."
  related={[
    { label: 'How ERP works in Patterns', href: '/erp' },
    { label: 'Understanding the OCD cycle', href: '/ocd' },
    { label: 'Frequently asked questions', href: '/faq' }
  ]}
>
  <p class="lead">
    If you've searched for a "CBT app" because you're dealing with OCD, here's the honest
    version: CBT is a broad family of therapies, and the part of it that actually moves the
    needle on OCD is <strong>ERP</strong>. That's the work Patterns is designed to support -
    quietly, privately, and on your own terms.
  </p>

  <h2>What CBT is</h2>
  <p>
    <strong>Cognitive behavioral therapy</strong> is a structured, evidence-based approach
    that looks at how thoughts, feelings, and behaviors feed each other - and then changes
    the behaviors and beliefs that keep you stuck. It's practical rather than open-ended:
    you learn skills, try them between sessions, and adjust based on what happens.
  </p>

  <h2>Why ERP is the CBT for OCD</h2>
  <p>
    OCD has its own particular loop - an intrusive thought, a spike of anxiety, and a
    compulsion that brings brief relief but teaches your brain the thought was dangerous.
    General "talk it through" or reassurance-based approaches can accidentally feed that
    loop. <strong>ERP</strong> - a specific form of CBT - does the opposite: you gradually
    face the trigger (exposure) and choose not to perform the ritual (response prevention),
    and your nervous system learns the feared outcome doesn't arrive.
  </p>
  <p>
    This is why clinicians consider ERP the gold-standard, first-line treatment for OCD.
    So when people look for a <strong>CBT app for OCD</strong>, ERP is almost always the
    thing that will actually help - and it's exactly what Patterns is built around. If you
    want the full walkthrough, read <a href="/erp">how ERP works</a>.
  </p>

  <h2>How Patterns works as a CBT & ERP app</h2>
  <p>
    Patterns turns the core CBT/ERP moves for OCD into a calm daily habit you can keep
    between therapy sessions:
  </p>
  <ul>
    <li>
      <strong>Log obsessions and compulsions</strong> as they happen, so you can see the
      loop clearly and spot your triggers.
    </li>
    <li>
      <strong>Rate distress on a 0–10 scale</strong> (SUDS), the same language ERP uses, and
      watch anxiety rise and fall on its own.
    </li>
    <li>
      <strong>Use the Compulsion Delay Tool</strong> to pause an urge and ride out the wave -
      response prevention, one small win at a time.
    </li>
    <li>
      <strong>Review your patterns</strong> with charts and history, so progress becomes
      visible and your therapy sessions start from concrete notes.
    </li>
  </ul>

  <div class="callout">
    <h3>An honest note on scope</h3>
    <p>
      Patterns is focused on OCD and the CBT that works for it - ERP. It isn't a general CBT
      app for mood tracking or thought records for other conditions, and it doesn't replace a
      therapist. If you can, work with an OCD-trained clinician and use Patterns to support
      the plan. <a href="/#download">Download Patterns</a> or start with
      <a href="/ocd">understanding the OCD cycle</a>.
    </p>
  </div>
</GuidePage>
