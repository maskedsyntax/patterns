import type { LucideIcon } from '$lib/types/icons';
import {
  Edit,
  Target,
  LineChart,
  Shield,
  Moon,
  MonitorSmartphone
} from 'lucide-svelte';

export type Feature = {
  icon: LucideIcon;
  title: string;
  description: string;
};

export const features: Feature[] = [
  {
    icon: Edit,
    title: 'Daily Journaling',
    description:
      'A minimalist writing space to record your thoughts. Each entry is tied to a specific date, building a chronological history of your mental well-being.'
  },
  {
    icon: Target,
    title: 'OCD Tracking',
    description:
      'Document obsessions and compulsions as they happen. Record the nature of thoughts, actions taken in response, and distress levels on a 0-10 (SUDS) scale.'
  },
  {
    icon: LineChart,
    title: 'Pattern Analytics',
    description:
      'Visualize distress trends over time with intuitive charts and heatmaps. See anxiety rise and fall, and prepare clear information for therapy and ERP sessions.'
  },
  {
    icon: Shield,
    title: 'Privacy First',
    description:
      'All data stays on your device. No cloud uploads, no third-party sharing. Your reflections and personal data remain entirely under your control.'
  },
  {
    icon: Moon,
    title: 'Dark & Light Modes',
    description:
      'Switch between carefully crafted dark and light themes to match your environment and reduce eye strain during late-night reflections.'
  },
  {
    icon: MonitorSmartphone,
    title: 'Mobile & Desktop',
    description:
      'Built with Flutter for iOS, Android, macOS, Linux, and Windows with a clean interface that feels focused on every screen.'
  }
];
