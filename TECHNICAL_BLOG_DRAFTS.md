# Technical Blog Drafts for Patterns

These drafts are based on the architecture and stack of Patterns, focusing on Flutter, Riverpod, SQLite, and local-first development.

---

## Draft 1: Building a Local-First Flutter App with Riverpod and SQLite

**Title: Building a Local-First Flutter App: Bridging SQLite and Riverpod**

In a world obsessed with cloud sync, sometimes the most important feature you can offer your users is absolute privacy. When building Patterns, an OCD and journaling application, keeping sensitive mental health data strictly on the device wasn't just a nice-to-have; it was a foundational requirement.

But "local-first" often introduces a specific UI challenge in Flutter: how do you build a fluid, reactive interface over a traditional, imperative SQLite database without drowning in boilerplate?

The answer lies in combining the robustness of `sqflite` with the modern state management capabilities of Riverpod, specifically using `AsyncNotifier`.

### The Problem with Imperative Databases
SQLite is inherently imperative. You ask for data, you wait for the disk, and you get a list of rows. But Flutter builds best reactively. You want your UI to automatically update the moment a new journal entry is saved, without having to manually tell five different widgets to refresh their state.

### The Riverpod Bridge
To solve this, we used Riverpod's `AsyncNotifier`. This allows us to treat our SQLite database almost like a reactive stream.

Here is a look at how we manage the Journal state:

```dart
class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    final entries = await DbHelper.instance.getJournalEntries();
    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  Future<void> saveEntry(String date, String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final entry = JournalEntry(
        date: date,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await DbHelper.instance.upsertJournalEntry(entry);
      final entries = await DbHelper.instance.getJournalEntries();
      entries.sort((a, b) => a.date.compareTo(b.date));
      return entries;
    });
  }
}
```

### The Magic of AsyncValue.guard
The secret sauce here is `AsyncValue.guard`. When a user saves an entry, we immediately set the state to `AsyncLoading()`. This allows the UI to show a subtle loading indicator if needed. 

Then, `guard` handles the asynchronous database insertion. If it succeeds, it fetches the fresh list of entries, sorts them, and updates the state. If the database throws an error, `guard` automatically catches it and transitions the state to an error state, which our UI can respond to elegantly.

This pattern eliminates manual `try/catch` blocks cluttering our business logic and completely decouples the UI from the database operations. The UI just listens to `ref.watch(journalProvider)`, and Riverpod ensures it always has the latest, correctly ordered data straight from the local disk.

---

## Draft 2: Client-Side PDF Generation in Flutter: Creating Offline Reports

**Title: Generating Complex PDFs Offline in Flutter: A Client-Side Approach**

Generating detailed PDF reports is usually a job reserved for the backend. You send the data to a server, spin up a template engine, generate the file, and send a download link back to the client.

But what if you don't have a backend? 

For Patterns, a privacy-focused mental health app, sending sensitive tracking data to a server just to generate a report was out of the question. We had to build robust, multi-page PDF reports entirely on the device.

### The Tools
We relied heavily on the `pdf` package in Flutter. Unlike standard Flutter widgets, the `pdf` package has its own layout engine. It feels similar to writing Flutter code (using Rows, Columns, and Containers), but it renders directly to a PDF canvas.

### The Challenge of Custom Fonts
One of the first hurdles with client-side PDF generation is typography. System fonts aren't guaranteed, and standard PDF fonts look clinical. 

To maintain our app's aesthetic, we had to bundle our custom fonts (like Inter and PlusJakartaSans) into the PDF layout.

```dart
// Example of loading fonts for the PDF
final font = await rootBundle.load("assets/fonts/Inter-Regular.ttf");
final ttf = Font.ttf(font);

// Using it in a PDF Widget
pw.Text("Journal Entry", style: pw.TextStyle(font: ttf, fontSize: 14));
```

### Formatting the Data
The real work happens in translating SQLite rows into a readable document. We take raw journal entries and OCD tracking data and format them into sections. The `pdf` package handles page breaks automatically, which is a lifesaver when dealing with variable-length text like journal entries.

### The Save UX
Once the PDF is generated in memory as a `Uint8List`, we need to save it. Because Patterns is available on iOS, macOS, Windows, and Linux, the save experience varies wildly.

We combined `path_provider` (for finding sensible default directories like the Documents folder) and `file_picker` (to allow users to choose exactly where the file goes). 

The result? A user can instantly generate a comprehensive, beautifully styled report of their mental health trends over the last 90 days, save it locally, and print it for their therapist—all without a single byte of data ever leaving their device.

---

## Draft 3: Implementing On-Device Biometric Security in Flutter

**Title: Locking Down Local Data: Biometric Security in Flutter Without a Backend**

When you build an app that tracks sensitive data—like daily distress levels and intrusive thoughts—security isn't just about preventing hacks over the network. Often, the biggest threat to privacy is someone picking up an unlocked phone left on a table.

For Patterns, we needed an "App Lock" feature. We needed to ensure that even if the device was unlocked, the app itself required explicit permission to open. And we had to do it completely offline, using the device's native biometric capabilities.

### The Implementation
Flutter's `local_auth` package makes interacting with FaceID, TouchID, and Android biometrics straightforward. But the actual API call is the easy part. The real challenge is lifecycle management.

We created a central service to handle the authentication state. When the app initializes, it checks local storage (`shared_preferences`) to see if the user has opted into the App Lock feature.

### Handling the App Lifecycle
A secure app must lock itself when it's pushed to the background. You can't let the OS capture a sensitive screenshot for the app switcher, and you can't leave the app unlocked if the user switches to a messaging app for five minutes.

By listening to the `AppLifecycleState`, we can detect when the app is paused or inactive. When this happens, we immediately overlay a secure, blurred screen over the UI. 

When the app returns to the `resumed` state, we trigger the `local_auth` prompt.

```dart
// A conceptual look at the lifecycle hook
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
    // Show blur overlay immediately
    ref.read(authProvider.notifier).requireAuthentication();
  } else if (state == AppLifecycleState.resumed) {
    // Prompt for biometrics
    _promptBiometrics();
  }
}
```

### The UX Balance
Security is often the enemy of low-friction UX. If a user is having a panic attack and wants to log an entry quickly, failing a FaceID check twice is incredibly frustrating. 

We had to carefully tune the implementation to ensure the fallback (device passcode) was easily accessible, and that the authentication screen itself felt calm and un-intimidating, maintaining the core design principles of the app. It's a delicate balance between rigorous privacy and accessibility during moments of distress.

---

## Draft 4: Designing a "Calm" UI: Escaping Default Material Design

**Title: Escaping Material Design: Building a "Calm" UI in Flutter**

Flutter is an incredible framework, but out of the box, it wants your app to look like a Google product. The default Material Design components—with their prominent AppBars, heavy drop shadows, and bright Floating Action Buttons—are excellent for complex dashboards and utility apps. 

But when we set out to build Patterns, an app for OCD tracking and journaling, those defaults felt too loud, too corporate, and too stressful. We needed a UI that felt like a quiet, private notebook. 

Here is how we stripped away the defaults to build a custom, "calm" UI.

### Ditching the Dashboard
Our first rule was: no dashboards. Mental health tracking shouldn't feel like analyzing quarterly sales metrics. 

Instead of a home screen packed with charts and stats, Patterns opens to a simple prompt: "How are you feeling right now?" accompanied by a clean distress slider. The cognitive load is kept as close to zero as possible. If a user is distressed, they don't need to parse a grid of data; they just need to log their feelings and move on.

### Custom Navigation
The default `BottomNavigationBar` in Flutter is functional but stiff. We replaced it with a custom floating tab bar.

Our tab bar is a floating pill shape with a slight translucent background. It restricts choices to just four elements, with a central "add" button. It hovers above the content rather than boxing it in, making the screen feel expansive and unconstrained.

### The Journal Experience
Have you ever tried to write a long, emotional journal entry in a standard `TextField`? It feels like you are filling out a government form.

For our journaling screen, we removed borders, labels, and rigid constraints. The editor takes up the entire screen. We used generous line spacing and soft, readable typography (like Inter and Fraunces). We implemented silent autosaves so the user never has to worry about losing their thoughts or clicking a massive "SAVE" button. 

### Color and Hierarchy
Pure blacks and stark whites can cause eye strain. We opted for a deep charcoal background with cards that are only slightly lighter. Borders are low-opacity, and our accent color is a warm yellow rather than a sharp primary blue or red. 

By aggressively customizing Flutter's `ThemeData` and building bespoke widgets instead of relying on default Material components, we created an environment that feels less like software and more like a safe space for reflection.