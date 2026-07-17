import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// Static content for the Y-BOCS self-check: the 10-item severity scale and
/// the full symptom checklist. Kept in one place (like `uncertaintyExercises`)
/// so the screen stays about behaviour, not data.
///
/// The wording is faithful to the Yale-Brown Obsessive Compulsive Scale
/// (Goodman et al.) but rephrased in first-person, plain language to match the
/// app's voice. This is a self-check aid, never a diagnostic instrument.

// ── Severity scale ─────────────────────────────────────────────────────────

enum YbocsDimension { obsessions, compulsions }

/// One severity item. Each [options] entry is an anchor; its list index is the
/// point value (0–4), so the same list drives both display and scoring.
class YbocsSeverityQuestion {
  final String id;
  final YbocsDimension dimension;
  final String prompt;
  final List<String> options;

  const YbocsSeverityQuestion({
    required this.id,
    required this.dimension,
    required this.prompt,
    required this.options,
  });
}

const ybocsSeverityQuestions = <YbocsSeverityQuestion>[
  // Obsessions (items 1–5)
  YbocsSeverityQuestion(
    id: 'o_time',
    dimension: YbocsDimension.obsessions,
    prompt: 'How much of my time is taken up by obsessive thoughts?',
    options: [
      'None at all',
      'A little — less than an hour a day, or a few now and then',
      'A moderate amount — 1 to 3 hours a day, or frequent intrusions',
      'A lot — 3 to 8 hours a day, or very frequent intrusions',
      'Almost constant — more than 8 hours a day',
    ],
  ),
  YbocsSeverityQuestion(
    id: 'o_interfere',
    dimension: YbocsDimension.obsessions,
    prompt: 'How much do the obsessions get in the way of my life?',
    options: [
      'Not at all',
      'A little — they don\'t really affect what I do',
      'Some — they interfere but I can still manage',
      'A lot — they clearly get in the way of my day',
      'So much that I can barely function',
    ],
  ),
  YbocsSeverityQuestion(
    id: 'o_distress',
    dimension: YbocsDimension.obsessions,
    prompt: 'How much distress do the obsessive thoughts cause me?',
    options: [
      'None',
      'A little — not too disturbing',
      'A moderate amount — disturbing but manageable',
      'A lot — very disturbing',
      'Nearly constant, disabling distress',
    ],
  ),
  YbocsSeverityQuestion(
    id: 'o_resist',
    dimension: YbocsDimension.obsessions,
    prompt: 'How hard do I try to resist the obsessive thoughts?',
    options: [
      'I always try to resist, or they barely happen',
      'I try to resist most of the time',
      'I make some effort to resist',
      'I give in to almost all of them without much of a fight',
      'I completely give in to them, willingly',
    ],
  ),
  YbocsSeverityQuestion(
    id: 'o_control',
    dimension: YbocsDimension.obsessions,
    prompt: 'How much control do I have over the obsessive thoughts?',
    options: [
      'Full control — I can dismiss them easily',
      'A lot of control — usually I can stop or divert them',
      'Some control — sometimes I can, sometimes I can\'t',
      'Little control — I rarely manage to stop them',
      'No control — they feel completely involuntary',
    ],
  ),
  // Compulsions (items 6–10)
  YbocsSeverityQuestion(
    id: 'c_time',
    dimension: YbocsDimension.compulsions,
    prompt: 'How much time do I spend on compulsions (rituals, checking, etc.)?',
    options: [
      'None at all',
      'A little — less than an hour a day, or a few now and then',
      'A moderate amount — 1 to 3 hours a day, or frequent rituals',
      'A lot — 3 to 8 hours a day, or very frequent rituals',
      'Almost constant — more than 8 hours a day',
    ],
  ),
  YbocsSeverityQuestion(
    id: 'c_interfere',
    dimension: YbocsDimension.compulsions,
    prompt: 'How much do the compulsions get in the way of my life?',
    options: [
      'Not at all',
      'A little — they don\'t really affect what I do',
      'Some — they interfere but I can still manage',
      'A lot — they clearly get in the way of my day',
      'So much that I can barely function',
    ],
  ),
  YbocsSeverityQuestion(
    id: 'c_distress',
    dimension: YbocsDimension.compulsions,
    prompt: 'How anxious or upset would I feel if I could not do the compulsion?',
    options: [
      'Not at all',
      'A little uneasy',
      'Moderately anxious',
      'Very anxious',
      'Overwhelmed, disabling anxiety',
    ],
  ),
  YbocsSeverityQuestion(
    id: 'c_resist',
    dimension: YbocsDimension.compulsions,
    prompt: 'How hard do I try to resist the compulsions?',
    options: [
      'I always try to resist, or they barely happen',
      'I try to resist most of the time',
      'I make some effort to resist',
      'I give in to almost all of them without much of a fight',
      'I completely give in to them, willingly',
    ],
  ),
  YbocsSeverityQuestion(
    id: 'c_control',
    dimension: YbocsDimension.compulsions,
    prompt: 'How much control do I have over the compulsions?',
    options: [
      'Full control — I can stop myself easily',
      'A lot of control — usually I can stop or delay',
      'Some control — sometimes I can, sometimes I can\'t',
      'Little control — I can rarely stop or delay',
      'No control — I have to complete them',
    ],
  ),
];

// ── Symptom checklist ──────────────────────────────────────────────────────

class YbocsSymptomItem {
  final String id;
  final String label;
  const YbocsSymptomItem(this.id, this.label);
}

class YbocsSymptomCategory {
  final String id;
  final String title;
  final YbocsDimension kind;
  final List<YbocsSymptomItem> items;

  const YbocsSymptomCategory({
    required this.id,
    required this.title,
    required this.kind,
    required this.items,
  });
}

const ybocsCategories = <YbocsSymptomCategory>[
  // ── Obsessions ──
  YbocsSymptomCategory(
    id: 'aggressive',
    title: 'Aggressive / harm',
    kind: YbocsDimension.obsessions,
    items: [
      YbocsSymptomItem('agg_harm_self', 'Fear I might harm myself'),
      YbocsSymptomItem('agg_harm_others', 'Fear I might harm someone else'),
      YbocsSymptomItem('agg_violent', 'Violent or horrific images in my mind'),
      YbocsSymptomItem('agg_blurt', 'Fear I\'ll blurt out insults or obscenities'),
      YbocsSymptomItem('agg_impulse', 'Fear I\'ll act on an unwanted impulse'),
      YbocsSymptomItem('agg_responsible', 'Fear I\'ll be responsible for something terrible happening'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'contamination',
    title: 'Contamination',
    kind: YbocsDimension.obsessions,
    items: [
      YbocsSymptomItem('con_dirt', 'Concern with dirt or germs'),
      YbocsSymptomItem('con_bodily', 'Disgust with bodily waste or secretions'),
      YbocsSymptomItem('con_chemicals', 'Concern about household chemicals or cleaners'),
      YbocsSymptomItem('con_ill', 'Fear I\'ll get ill from contamination'),
      YbocsSymptomItem('con_spread', 'Fear I\'ll spread contamination to others'),
      YbocsSymptomItem('con_sticky', 'Bothered by sticky substances or residues'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'sexual',
    title: 'Sexual',
    kind: YbocsDimension.obsessions,
    items: [
      YbocsSymptomItem('sex_forbidden', 'Forbidden or unwanted sexual thoughts or images'),
      YbocsSymptomItem('sex_others', 'Sexual thoughts involving others that disturb me'),
      YbocsSymptomItem('sex_orientation', 'Unwanted doubts about my sexual orientation'),
      YbocsSymptomItem('sex_aggressive', 'Aggressive sexual thoughts toward others'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'hoarding_obs',
    title: 'Hoarding / saving',
    kind: YbocsDimension.obsessions,
    items: [
      YbocsSymptomItem('hoard_discard', 'Fear of throwing away something I might need'),
      YbocsSymptomItem('hoard_value', 'Feeling objects have value I can\'t let go of'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'religious',
    title: 'Religious / moral (scrupulosity)',
    kind: YbocsDimension.obsessions,
    items: [
      YbocsSymptomItem('rel_sacrilege', 'Concern with sacrilege or blasphemy'),
      YbocsSymptomItem('rel_rightwrong', 'Excessive concern with right and wrong, or morality'),
      YbocsSymptomItem('rel_punish', 'Fear of punishment by God or fate'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'symmetry_obs',
    title: 'Symmetry / exactness',
    kind: YbocsDimension.obsessions,
    items: [
      YbocsSymptomItem('sym_even', 'Need things even, balanced, or "just right"'),
      YbocsSymptomItem('sym_exact', 'Need for exactness, order, or precision'),
      YbocsSymptomItem('sym_incomplete', 'A feeling of incompleteness until things feel right'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'somatic',
    title: 'Body / illness',
    kind: YbocsDimension.obsessions,
    items: [
      YbocsSymptomItem('som_illness', 'Excessive concern with illness or disease'),
      YbocsSymptomItem('som_body', 'Excessive concern with a body part or appearance'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'misc_obs',
    title: 'Other obsessions',
    kind: YbocsDimension.obsessions,
    items: [
      YbocsSymptomItem('misc_know', 'Need to know or remember things'),
      YbocsSymptomItem('misc_saywrong', 'Fear of saying the wrong thing'),
      YbocsSymptomItem('misc_lucky', 'Lucky or unlucky numbers, words, or colours'),
      YbocsSymptomItem('misc_sounds', 'Intrusive sounds, words, or music I can\'t stop'),
      YbocsSymptomItem('misc_lose', 'Fear of losing things'),
    ],
  ),
  // ── Compulsions ──
  YbocsSymptomCategory(
    id: 'washing',
    title: 'Washing / cleaning',
    kind: YbocsDimension.compulsions,
    items: [
      YbocsSymptomItem('wash_hands', 'Excessive or ritualised hand-washing'),
      YbocsSymptomItem('wash_shower', 'Excessive showering, bathing, or grooming'),
      YbocsSymptomItem('wash_clean', 'Excessive cleaning of household items'),
      YbocsSymptomItem('wash_avoid', 'Avoiding things I see as contaminated'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'checking',
    title: 'Checking',
    kind: YbocsDimension.compulsions,
    items: [
      YbocsSymptomItem('chk_locks', 'Checking locks, appliances, taps, or the stove'),
      YbocsSymptomItem('chk_harm', 'Checking I didn\'t or won\'t harm someone'),
      YbocsSymptomItem('chk_mistake', 'Checking I didn\'t make a mistake'),
      YbocsSymptomItem('chk_body', 'Checking my body for signs of illness'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'repeating',
    title: 'Repeating rituals',
    kind: YbocsDimension.compulsions,
    items: [
      YbocsSymptomItem('rep_reread', 'Re-reading or re-writing'),
      YbocsSymptomItem('rep_routine', 'Repeating routine actions (in/out doors, up/down)'),
      YbocsSymptomItem('rep_untilright', 'Repeating until it feels "just right"'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'counting',
    title: 'Counting',
    kind: YbocsDimension.compulsions,
    items: [
      YbocsSymptomItem('cnt_count', 'Counting objects, steps, or actions'),
      YbocsSymptomItem('cnt_numbers', 'Doing things a certain number of times'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'ordering',
    title: 'Ordering / arranging',
    kind: YbocsDimension.compulsions,
    items: [
      YbocsSymptomItem('ord_arrange', 'Arranging things until they\'re symmetrical or exact'),
      YbocsSymptomItem('ord_align', 'Aligning or straightening objects repeatedly'),
    ],
  ),
  YbocsSymptomCategory(
    id: 'misc_comp',
    title: 'Other compulsions',
    kind: YbocsDimension.compulsions,
    items: [
      YbocsSymptomItem('mc_mental', 'Mental rituals (silent prayers, phrases, reviewing)'),
      YbocsSymptomItem('mc_reassure', 'Asking for reassurance, or confessing, repeatedly'),
      YbocsSymptomItem('mc_touch', 'Needing to touch, tap, or rub things'),
      YbocsSymptomItem('mc_lists', 'Excessive list-making'),
      YbocsSymptomItem('mc_avoid', 'Avoiding situations to prevent an urge'),
    ],
  ),
];

// ── Severity band presentation ─────────────────────────────────────────────

extension YbocsSeverityDisplay on YbocsSeverity {
  String get label => switch (this) {
    YbocsSeverity.subclinical => 'Subclinical',
    YbocsSeverity.mild => 'Mild',
    YbocsSeverity.moderate => 'Moderate',
    YbocsSeverity.severe => 'Severe',
    YbocsSeverity.extreme => 'Extreme',
  };

  String get range => switch (this) {
    YbocsSeverity.subclinical => '0–7',
    YbocsSeverity.mild => '8–15',
    YbocsSeverity.moderate => '16–23',
    YbocsSeverity.severe => '24–31',
    YbocsSeverity.extreme => '32–40',
  };

  String get blurb => switch (this) {
    YbocsSeverity.subclinical =>
      'Symptoms in this range are usually below the level seen in OCD. If they still bother you, it\'s worth mentioning to a professional.',
    YbocsSeverity.mild =>
      'Symptoms are present but you can mostly work around them. Early tools and support tend to help most here.',
    YbocsSeverity.moderate =>
      'Symptoms are taking real time and getting in the way. This is a common range for people who benefit from ERP and professional support.',
    YbocsSeverity.severe =>
      'Symptoms are demanding a lot of your day and energy. Working with a clinician is strongly worth it.',
    YbocsSeverity.extreme =>
      'Symptoms sound overwhelming and disabling. Please consider reaching out to a professional soon — you don\'t have to manage this alone.',
  };

  Color get color => switch (this) {
    YbocsSeverity.subclinical => const Color(0xFF6FBF73),
    YbocsSeverity.mild => const Color(0xFF9CCC65),
    YbocsSeverity.moderate => AppTheme.warmYellow,
    YbocsSeverity.severe => const Color(0xFFFFB74D),
    YbocsSeverity.extreme => const Color(0xFFE57373),
  };
}
