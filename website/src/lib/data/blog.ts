/**
 * Blog posts for Patterns. These are written in the first person by the person
 * building Patterns - someone who lives with OCD - for everyone else working
 * through the same thoughts and feelings. They are personal essays, not clinical
 * advice. Keep that voice: honest, plain, no pretending to be a therapist.
 *
 * Content is stored as HTML and rendered inside a `.prose` container (see the
 * post route), which supplies the typography for h2/h3/p/ul/strong/blockquote.
 */
export type BlogPost = {
  slug: string;
  title: string;
  description: string;
  /** ISO date (YYYY-MM-DD). */
  date: string;
  readingMinutes: number;
  /** One or two sentence teaser used on the index and in metadata. */
  excerpt: string;
  /** Long-form HTML body. */
  content: string;
};

export const posts: BlogPost[] = [
  {
    slug: 'why-i-built-patterns',
    title: 'Why I built Patterns',
    description:
      'I have OCD, and I built the tracker I wished existed - private, calm, and built around the therapy that actually helped me. Here is the whole story.',
    date: '2026-07-11',
    readingMinutes: 6,
    excerpt:
      'I have OCD. I built Patterns because I kept looking for the tool I needed and never finding it. This is the honest version of why.',
    content: `
      <p class="lead">
        I want to be upfront about something before you read another word: I am not a
        therapist, a doctor, or a researcher. I am a person with OCD who got tired of
        fighting the same loop with sticky notes and half-finished spreadsheets, and
        decided to build something better. Patterns is that something.
      </p>

      <h2>The tool I kept looking for</h2>
      <p>
        For years my "system" was chaos. A notes app full of intrusive thoughts I was
        too embarrassed to reread. A reminder to "not check" that I ignored. A vague
        memory of what my distress felt like last Tuesday that my brain happily rewrote
        into something worse. When I finally started ERP - exposure and response
        prevention - my therapist asked me to track my compulsions and rate my anxiety.
        I wanted to. I just did not have anywhere calm to do it.
      </p>
      <p>
        Every app I tried felt wrong. Some wanted an account and my email before they
        would show me anything. Some sold my kind of vulnerability back to me as a
        subscription with a countdown timer. Most were built for "wellness" in the
        abstract and had never heard the words <strong>obsession</strong> and
        <strong>compulsion</strong> used the way people with OCD use them. I wanted
        something that spoke my language and then got out of the way.
      </p>

      <h2>What OCD taught me about design</h2>
      <p>
        OCD is, among other cruelties, a demand for certainty. So I knew that whatever I
        built could not become another thing to do perfectly. If logging a compulsion
        turned into its own little ritual - the right tags, the right time, the exactly
        correct wording - I would have just handed my OCD a new toy. So Patterns is
        deliberately low-stakes. You can write two words or two paragraphs. You can rate
        your distress and move on. Nothing punishes you for a missed day.
      </p>
      <p>
        I also knew it had to be private in a way I could feel. Not "we take privacy
        seriously" in a footer - actually private. So everything you write in Patterns
        stays on your device. No account, no cloud, no one on the other end. I made that
        choice for myself first, because I could not be honest in a journal I did not
        trust.
      </p>

      <h2>Built around the therapy that worked</h2>
      <p>
        The reason Patterns is shaped the way it is - a journal, an OCD tracker, a
        distress scale, a compulsion delay tool, and a whole recovery toolkit - is that
        those are the moves ERP asks of you. Name the thought. Notice the urge. Rate the
        distress. Delay the compulsion. Sit with the wave until it passes. Look back and
        see that it did. I did not invent any of that; I just tried to make it a little
        less lonely to do at 2am.
      </p>
      <blockquote>
        I am not trying to be your therapist. I am trying to be the notebook that is
        already open when you need it.
      </blockquote>

      <h2>For everyone else in the loop</h2>
      <p>
        If you have OCD, you already know the specific exhaustion of it - the way a
        single thought can eat an afternoon. I built Patterns for that person, because I
        am that person. It is free to download and use, the core is open source, and the
        Pro tools exist so I can keep working on it without turning your worst moments
        into an ad slot.
      </p>
      <p>
        You do not have to do this perfectly. That is sort of the whole point. You just
        have to keep showing up, and it helps to have somewhere calm to do it.
      </p>
    `
  },
  {
    slug: 'the-loop-and-how-i-loosen-it',
    title: 'The loop, and how I loosen it',
    description:
      'Obsession, distress, compulsion, relief - then it starts again. Here is how I learned to see the OCD loop, and the small moves that give me room inside it.',
    date: '2026-07-11',
    readingMinutes: 7,
    excerpt:
      'Obsession, distress, compulsion, relief. Then it starts again. Here is how I learned to see the loop instead of living inside it.',
    content: `
      <p class="lead">
        For a long time I thought OCD was the thoughts. The intrusive images, the
        what-ifs, the horrible flashes that felt like they came from someone I did not
        want to be. It took me embarrassingly long to understand that the thoughts were
        never the problem. The loop was.
      </p>

      <h2>Naming the four steps</h2>
      <p>
        The loop, for me, goes like this. A thought latches on - the
        <strong>obsession</strong>. My body floods with <strong>distress</strong> almost
        instantly, faster than reason. I do something to make it stop - the
        <strong>compulsion</strong> - checking, googling, washing, seeking reassurance,
        or just ruminating in circles. And I get <strong>relief</strong>, real relief,
        for a minute or an hour. Then the loop tightens and comes back sooner.
      </p>
      <p>
        The cruel trick is that the relief is exactly what keeps it going. Every time I
        "solved" the anxiety with a compulsion, I taught my brain that the thought really
        was dangerous and the ritual really did save me. I was training the thing that
        was hurting me, several times a day, for years.
      </p>

      <h2>Why I started writing it down</h2>
      <p>
        You cannot loosen a loop you cannot see. When it is happening, it does not feel
        like four steps - it feels like one solid wall of "I have to." Writing it down
        pulls the steps apart. Once I could see "ah, that was the obsession, and this is
        just distress, and the checking is a compulsion, not a necessity," I had a
        sliver of room I did not have before.
      </p>
      <p>
        That is really all the OCD tracker in Patterns is for. Not to build a beautiful
        dataset. Just to turn a wall back into steps, so there is a gap to act in.
      </p>

      <h2>The move that changed things: delay</h2>
      <p>
        I could not white-knuckle my way to "never do the compulsion." That framing set
        me up to fail and then feel worse. What actually worked was smaller:
        <strong>delay</strong>. Wait five minutes before checking. Then ten. Sit with the
        urge and watch what it does.
      </p>
      <p>
        Here is the thing nobody could convince me of with words, only experience: the
        urge crests and falls on its own. Every single time. When I delayed instead of
        acting, the anxiety climbed, peaked, and then - without me fixing anything - came
        down. That is the whole secret of response prevention, and you have to feel it to
        believe it. The compulsion delay tool in the app is just a timer and a place to
        notice that it happened.
      </p>
      <blockquote>
        "I have to" became "I waited, and it passed." That sentence rebuilt a lot of my
        life.
      </blockquote>

      <h2>Progress is not a straight line</h2>
      <p>
        Some weeks I surf the urge like it is nothing. Some weeks a single thought puts me
        flat on the floor. Early on, a bad day felt like proof that none of it worked.
        Looking back over weeks of entries taught me otherwise: the trend was quietly
        bending the right way even when any single day looked like a loss. Seeing that on
        a chart, in my own handwriting so to speak, is the closest thing to hope I could
        manufacture on the hard days.
      </p>

      <h2>If you are in the loop right now</h2>
      <p>
        You are not the thought. The thought is loud; that is not the same as true. You do
        not have to win against your OCD today. You just have to leave one small gap - one
        delayed compulsion, one thought named instead of obeyed - and let the wave do what
        waves do. I still practise this. That is not a failure; it is the practice.
      </p>
    `
  },
  {
    slug: 'why-patterns-stays-private',
    title: 'Why Patterns stays private (and always will)',
    description:
      'People with OCD write down their most frightening thoughts. That data should never leave your device. Here is why Patterns has no account, no cloud, and no tracking.',
    date: '2026-07-11',
    readingMinutes: 5,
    excerpt:
      'The things people with OCD write down are exactly the things they least want anyone to see. So Patterns keeps all of it on your device. Here is why.',
    content: `
      <p class="lead">
        The entries people write in an OCD journal are often the most frightening,
        shameful, misunderstood thoughts they have ever had. Intrusive thoughts are, by
        definition, the ones you do not want. Asking someone to write those down and then
        quietly shipping them to a server would be a betrayal. So Patterns does not.
      </p>

      <h2>What "private" actually means here</h2>
      <p>
        Everything you record in Patterns - journal entries, tracked obsessions and
        compulsions, distress ratings, every note in the recovery toolkit - is stored
        locally on your device. There is no account to create. There is no cloud sync.
        There are no analytics watching what you type. I cannot read your entries, and
        neither can anyone else, because they never leave your phone or computer in the
        first place.
      </p>
      <p>
        When you want a backup, you export a file yourself, and it goes wherever you
        decide to put it. The control stays with you. That is not a premium feature or a
        toggle buried in settings - it is just how the app is built.
      </p>

      <h2>Why I would not do it any other way</h2>
      <p>
        I made this decision for myself before I made it for anyone else. I could not be
        honest in a journal I did not trust. And OCD recovery <em>requires</em> honesty -
        the whole point of ERP is to face the exact thoughts you most want to hide. If
        part of me was performing for an invisible audience, or worrying where the data
        went, that part would sabotage the work. Privacy is not a nice-to-have on top of
        the therapy. For this kind of app, it is a precondition for the therapy working.
      </p>
      <blockquote>
        You should be able to write the worst thing your brain has ever handed you and
        know, with certainty, that it stays with you.
      </blockquote>

      <h2>How the app stays alive without your data</h2>
      <p>
        The usual way "free" mental health apps survive is by turning your vulnerability
        into a product - selling attention, data, or an anxious subscription. I did not
        want any of that near this. Patterns is free to download and use, and the core is
        open source so you can check that the claims on this page are true. Patterns Pro
        is a one-time unlock for the deeper recovery tools - you pay once, you own it,
        there is no subscription, and none of it changes the privacy promise. That is how
        I keep building this without ever needing to look at what you wrote.
      </p>

      <h2>The short version</h2>
      <p>
        No account. No cloud. No tracking. Your thoughts stay yours. If you have OCD, you
        deserve at least one place that is genuinely safe to be honest - and I wanted that
        place to exist, so I built it.
      </p>
    `
  },
  {
    slug: 'what-i-wanted-in-an-ocd-app',
    title: 'What I actually wanted from an OCD app',
    description:
      'I tried a lot of apps before I built one. Here is the honest list of what an OCD app needs to do - and what most of them get wrong.',
    date: '2026-07-21',
    readingMinutes: 6,
    excerpt:
      'Before I built Patterns, I kept downloading apps and deleting them. This is what I was actually looking for in an OCD app, and why it was so hard to find.',
    content: `
      <p class="lead">
        For a long time my search history was some version of "best OCD app" over and over
        again. I would download one, poke at it for ten minutes, and delete it. It took me a
        while to put words to what I was actually looking for - so here it is, the honest
        checklist I wish someone had handed me.
      </p>

      <h2>It had to speak OCD, not "wellness"</h2>
      <p>
        Most of what came up when I searched for an OCD app was general mood-tracking with a
        calming gradient slapped on top. Nice, but useless to me. I did not need to rate my
        day with an emoji. I needed to log an <strong>obsession</strong>, name the
        <strong>compulsion</strong> it dragged behind it, and rate how much distress it
        caused - in that language, because that is the language OCD actually uses.
      </p>

      <h2>It had to be built around ERP</h2>
      <p>
        The thing that helped me was ERP - exposure and response prevention. So the app I
        wanted was really an <strong>ERP app</strong>: something that helped me delay a
        compulsion, sit with the discomfort, and see, in my own data, that the wave came down
        on its own. An OCD app that ignores ERP is just a diary. I wanted the tool that
        supported the therapy, not a prettier place to spiral.
      </p>

      <h2>It could not ask for my email</h2>
      <p>
        I am not writing my worst intrusive thoughts into something that wants an account
        first. Every app that opened with a sign-up wall lost me immediately. The OCD app I
        wanted would keep everything on my device, no login, no cloud, nobody on the other
        end. That turned out to be non-negotiable - I could not be honest otherwise.
      </p>

      <h2>It had to get out of the way</h2>
      <p>
        No streaks guilt-tripping me. No countdown timer on a subscription. No notifications
        engineered to pull me back in. OCD already has enough hooks; I did not want an app
        adding more. I wanted something quiet that I could open when I needed it and close
        without a fight.
      </p>

      <h2>I could not find it, so I built it</h2>
      <p>
        Eventually I stopped searching and built the thing from the list. That is what
        <a href="/">Patterns</a> is: a private OCD app built around
        <a href="/erp">ERP</a>, with no account and no cloud. I am not a therapist and it is
        not a replacement for one - but it is the OCD app I kept looking for and never found.
      </p>
    `
  },
  {
    slug: 'is-patterns-a-cbt-app',
    title: 'Is Patterns a CBT app? ERP, CBT, and what actually helped me',
    description:
      'People ask if Patterns is a CBT app. The honest answer: it is built around ERP, which is the form of CBT with the strongest evidence for OCD. Here is what that means.',
    date: '2026-07-21',
    readingMinutes: 5,
    excerpt:
      'A question I get a lot: is Patterns a CBT app? The short answer is yes-ish, and the honest answer is more interesting than that.',
    content: `
      <p class="lead">
        People ask me whether Patterns is a "CBT app." It is a fair question, and I want to
        answer it honestly rather than just say whatever gets more downloads. So here is the
        real version: Patterns is built around ERP, which <em>is</em> a form of CBT - the one
        with the strongest evidence for OCD.
      </p>

      <h2>What CBT means</h2>
      <p>
        Cognitive behavioral therapy is not one single technique - it is a family of
        practical, evidence-based approaches that work on the link between your thoughts,
        feelings, and behaviors. When people picture a "CBT app," they often imagine thought
        records or mood tracking. That is one corner of CBT. For OCD, it is not the corner
        that helped me.
      </p>

      <h2>The CBT that works for OCD is ERP</h2>
      <p>
        The part of CBT that actually moves OCD is <strong>ERP</strong> - exposure and
        response prevention. You gradually face the thought or situation that triggers you,
        and you choose not to do the compulsion that usually follows. Over time your brain
        learns the feared thing does not happen. Clinicians treat ERP as the gold-standard,
        first-line therapy for OCD, and it is the thing that changed my life. So a
        <strong>CBT app for OCD</strong> that is worth using is, in practice, an ERP app.
      </p>

      <h2>So, is Patterns a CBT app?</h2>
      <p>
        Yes, in the way that matters for OCD: it is built entirely around ERP, the CBT
        approach proven to help. But I want to be careful not to over-claim. Patterns is not
        a general CBT app for depression, or a thought-record tool for every situation. It is
        focused, on purpose, on OCD and the CBT that treats it. If you want the full
        walkthrough, I wrote up <a href="/cbt">CBT for OCD</a> and
        <a href="/erp">how ERP works</a> in plain language.
      </p>

      <h2>The honest bottom line</h2>
      <p>
        I am not a therapist, and no app replaces one. What I can tell you is that ERP is the
        CBT that helped me, and Patterns is the private, no-account app I built to keep doing
        it between sessions. If that is what you are searching for, that is what this is.
      </p>
    `
  }
];

export function getPost(slug: string): BlogPost | undefined {
  return posts.find((post) => post.slug === slug);
}

/** Newest first, for the index. */
export const postsByDate: BlogPost[] = [...posts].sort((a, b) =>
  b.date.localeCompare(a.date)
);
