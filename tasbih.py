import json
import os
from datetime import datetime, timedelta

class Counter:
    def __init__(self, name, current_count=0, target=None, history=None):
        self.name = name
        self.current_count = current_count
        self.target = target
        self.history = history if history is not None else []

    def increment(self):
        self.current_count += 1
        self.history.append(datetime.now().isoformat())

    def reset(self):
        self.current_count = 0

    def to_dict(self):
        return {
            "name": self.name,
            "current_count": self.current_count,
            "target": self.target,
            "history": self.history
        }

    @classmethod
    def from_dict(cls, data):
        return cls(
            name=data["name"],
            current_count=data["current_count"],
            target=data.get("target"),
            history=data.get("history", [])
        )

class TasbihApp:
    def __init__(self, storage_file="tasbih_data.json"):
        self.storage_file = storage_file
        self.counters = []
        self.load_data()
        if not self.counters:
            self.add_default_counters()

    def add_default_counters(self):
        self.add_counter("SubhanAllah", target=33)
        self.add_counter("Alhamdulillah", target=33)
        self.add_counter("Allahu Akbar", target=33)
        self.add_counter("La ilaha illallah", target=100)
        self.add_counter("Astaghfirullah", target=100)

    def add_counter(self, name, target=None):
        self.counters.append(Counter(name, target=target))
        self.save_data()

    def load_data(self):
        if os.path.exists(self.storage_file):
            try:
                with open(self.storage_file, 'r') as f:
                    data = json.load(f)
                    self.counters = [Counter.from_dict(c) for c in data.get("counters", [])]
            except (json.JSONDecodeError, KeyError):
                self.counters = []

    def save_data(self):
        data = {
            "counters": [c.to_dict() for c in self.counters]
        }
        with open(self.storage_file, 'w') as f:
            json.dump(data, f, indent=4)
            f.write('\n')

    def get_stats(self):
        now = datetime.now()
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        week_start = today_start - timedelta(days=now.weekday())
        month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

        stats = {
            "today": 0,
            "week": 0,
            "month": 0,
            "history_last_7_days": [0] * 7
        }

        for counter in self.counters:
            for timestamp_str in counter.history:
                dt = datetime.fromisoformat(timestamp_str)
                if dt >= today_start:
                    stats["today"] += 1
                if dt >= week_start:
                    stats["week"] += 1
                if dt >= month_start:
                    stats["month"] += 1

                days_ago = (now.date() - dt.date()).days
                if 0 <= days_ago < 7:
                    stats["history_last_7_days"][6 - days_ago] += 1

        return stats

def main():
    app = TasbihApp()

    while True:
        print("\n=== Digital Tasbih ===")
        print("1. View Counters")
        print("2. Statistics")
        print("3. Add New Counter")
        print("4. Exit")

        choice = input("Select an option: ")

        if choice == '1':
            while True:
                print("\n--- My Counters ---")
                for i, counter in enumerate(app.counters):
                    target_str = f"/{counter.target}" if counter.target else ""
                    print(f"{i+1}. {counter.name}: {counter.current_count}{target_str}")
                print(f"{len(app.counters)+1}. Back")

                print("Options: <number> to increment, r <number> to reset, b to go back")
                c_choice = input("Selection: ").strip().lower()

                if c_choice == 'b':
                    break

                try:
                    if c_choice.startswith('r '):
                        idx = int(c_choice[2:]) - 1
                        if 0 <= idx < len(app.counters):
                            app.counters[idx].reset()
                            app.save_data()
                            print(f"Reset {app.counters[idx].name}!")
                        else:
                            print("Invalid selection.")
                        continue

                    idx = int(c_choice) - 1
                    if 0 <= idx < len(app.counters):
                        app.counters[idx].increment()
                        app.save_data()
                        print(f"Incremented {app.counters[idx].name}!")
                    elif idx == len(app.counters):
                        break
                    else:
                        print("Invalid selection.")
                except ValueError:
                    print("Please enter a number.")

        elif choice == '2':
            stats = app.get_stats()
            print("\n--- Statistics ---")
            print(f"Today: {stats['today']}")
            print(f"This Week: {stats['week']}")
            print(f"This Month: {stats['month']}")
            print("Last 7 Days (history):", stats['history_last_7_days'])
            input("\nPress Enter to return...")

        elif choice == '3':
            name = input("Enter counter name: ")
            target_input = input("Enter target (optional, press Enter for none): ")
            target = int(target_input) if target_input.isdigit() else None
            app.add_counter(name, target)
            print(f"Added counter '{name}'!")

        elif choice == '4':
            print("JazakAllah Khair! Goodbye.")
            break
        else:
            print("Invalid option.")

if __name__ == "__main__":
    main()
