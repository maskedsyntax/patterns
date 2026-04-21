import json
from datetime import datetime, timedelta
import random

def generate_data():
    start_date = datetime(2026, 3, 1)
    end_date = datetime(2026, 4, 20)
    current_date = start_date
    
    journal_entries = []
    ocd_entries = []
    
    journal_topics = [
        "Reflecting on the morning routine. I've noticed that if I start with 10 minutes of mindfulness before checking my phone, the rest of my day feels significantly more anchored. Today was a good example of that.",
        "Had a challenging meeting at work today. There was a lot of back-and-forth about the new project direction, and I felt my heart rate climbing. In the past, this would have spiraled into a day-long anxiety loop, but I used the grounding techniques we discussed.",
        "The weather is finally starting to turn. I spent some time in the park today just observing the changes. It's a good reminder that progress is often slow and incremental, much like my own journey with mental clarity.",
        "Struggled with sleep last night. My mind was racing with 'what-ifs' about the upcoming deadline. I tried writing them down in a physical notebook first, then transitioning to this digital journal to structure them into actionable steps.",
        "Spent the evening with friends. It's interesting how social interaction can both drain and recharge me at the same time. I need to be more mindful of my social battery and give myself permission to leave early if I need to.",
        "Thinking a lot about the concept of 'perfection' today. It's a trap I often fall into—feeling like if a task isn't done perfectly, it wasn't worth doing at all. I'm trying to reframe 'good enough' as a success.",
        "A very productive day, but I feel a bit hollow. I think I pushed myself too hard to check off every single item on my to-do list. Tomorrow, I want to focus more on the quality of my presence rather than just the quantity of my output.",
        "Noticed a recurring thought pattern today related to my self-worth and my productivity. It's a deep-seated belief that I'm only valuable if I'm producing something. Journaling this out helps me see how irrational that actually is.",
    ]

    while current_date <= end_date:
        # 90% chance of a journal entry (decreasing missing entries)
        if random.random() < 0.9:
            date_str = current_date.strftime("%Y-%m-%d")
            content = random.choice(journal_topics) + "\n\n" + random.choice(journal_topics) + "\n\n" + random.choice(journal_topics)
            journal_entries.append({
                "date": date_str,
                "content": content,
                "created_at": current_date.strftime("%Y-%m-%dT09:00:00Z"),
                "updated_at": current_date.strftime("%Y-%m-%dT09:00:00Z")
            })
        
        # 70% chance of an OCD entry on any given day
        if random.random() < 0.7:
            num_events = random.randint(1, 3)
            for _ in range(num_events):
                dt = current_date + timedelta(hours=random.randint(8, 22), minutes=random.randint(0, 59))
                ocd_type = random.randint(0, 1)
                
                if ocd_type == 0: # Compulsion/Symmetry/Checking
                    content = random.choice(["Checking the locks", "Organizing the desk", "Washing hands", "Repeating a phrase"])
                    response = "Performed the ritual " + str(random.randint(3, 8)) + " times."
                    action = "Used grounding techniques to stop."
                else: # Obsession/Intrusive Thought
                    content = random.choice(["Intrusive thought about safety", "Worry about contamination", "Fear of making a mistake", "Doubt about a conversation"])
                    response = "Mental rumination for " + str(random.randint(10, 40)) + " minutes."
                    action = "Logged the thought and redirected focus."

                ocd_entries.append({
                    "type": ocd_type,
                    "datetime": dt.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    "content": content,
                    "distress_level": random.randint(2, 9),
                    "response": response,
                    "action_taken": action,
                    "created_at": dt.strftime("%Y-%m-%dT%H:%M:%SZ")
                })

        current_date += timedelta(days=1)
        
    data = {
        "journal": journal_entries,
        "ocd": ocd_entries
    }
    
    with open('patterns_example_data.json', 'w') as f:
        json.dump(data, f, indent=2)

if __name__ == "__main__":
    generate_data()
