import type { LucideIcon } from '$lib/types/icons';
import {
  Footprints,
  Hourglass,
  LifeBuoy,
  Sparkles,
  ListOrdered,
  FolderOpen,
  ShieldCheck,
  CalendarRange,
  Waves,
  HelpCircle,
  ClipboardList,
  FlaskConical,
  BarChart3,
  BookOpen,
  GitBranch
} from 'lucide-svelte';

export type Tool = {
  icon: LucideIcon;
  title: string;
  description: string;
};

/**
 * The recovery toolkit shipped in the Patterns mobile app. Copy here mirrors the
 * in-app section intros so the website describes the tools honestly, in the same
 * plain language a person practising ERP actually reads.
 */
export const freeTools: Tool[] = [
  {
    icon: Footprints,
    title: 'Guided ERP',
    description:
      'Guided exposure and response prevention exercises to practise at your pace. The goal is to sit with discomfort without doing the compulsion.'
  },
  {
    icon: Hourglass,
    title: 'Compulsion Delay',
    description:
      'Put a pause between the urge and the action. Delay a compulsion for a set time and watch the urge rise and fall - proof you can tolerate the feeling.'
  },
  {
    icon: LifeBuoy,
    title: 'Emergency Toolkit',
    description:
      'Fast grounding techniques for the hard moments, when distress spikes. Kept a tap away, because you should not have to think clearly to use it.'
  },
  {
    icon: Sparkles,
    title: 'Coping Library',
    description:
      'A reference of coping strategies and reframes you can return to anytime. Save the ones that land for you and revisit them when you need them.'
  }
];

export const proTools: Tool[] = [
  {
    icon: ListOrdered,
    title: 'Exposure Hierarchy',
    description:
      'Build your ladder: list feared situations and rank them from easiest to hardest, then work up one rung at a time instead of all at once.'
  },
  {
    icon: FolderOpen,
    title: 'Exposure Materials',
    description:
      'Store the scripts, images, loop tapes, and notes you use during exposures, so everything you need for practice lives in one place.'
  },
  {
    icon: ShieldCheck,
    title: 'Response Prevention',
    description:
      'Plan and log how you held back from a compulsion. Response prevention is where exposures do their real work.'
  },
  {
    icon: CalendarRange,
    title: 'Structured Programs',
    description:
      'Multi-day programs that sequence exposures for you - follow along when you want structure instead of deciding each step yourself.'
  },
  {
    icon: Waves,
    title: 'Urge Surfing',
    description:
      'Urges rise, crest, and fall on their own if you let them. Surf one out here instead of acting on it.'
  },
  {
    icon: HelpCircle,
    title: 'Uncertainty Training',
    description:
      'Short practices for tolerating doubt instead of seeking reassurance. OCD feeds on certainty; this starves it a little.'
  },
  {
    icon: ClipboardList,
    title: 'Action Planner',
    description:
      'Turn intentions into concrete, scheduled actions. A clear next step is easier to take than a vague resolve.'
  },
  {
    icon: FlaskConical,
    title: 'Behavioral Experiments',
    description:
      'Predict what you fear will happen, then check what actually did. Reality is usually kinder than the anxious forecast.'
  },
  {
    icon: BarChart3,
    title: 'Recovery Metrics',
    description:
      'Track exposures completed, avoidance, and distress over time. Small, steady numbers tell the real recovery story.'
  },
  {
    icon: BookOpen,
    title: 'Reflection Journal',
    description:
      'Journal what an exposure was like once the intensity fades. Reflection turns a hard moment into learning you can reuse.'
  },
  {
    icon: GitBranch,
    title: 'Implementation Intentions',
    description:
      'Decide in advance: "if X happens, I will do Y." Pre-committing makes the healthy response the automatic one.'
  }
];
