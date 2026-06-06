import unittest
import os
import json
from datetime import datetime, timedelta
from tasbih import TasbihApp, Counter

class TestTasbih(unittest.TestCase):
    def setUp(self):
        self.test_file = "test_tasbih_data.json"
        if os.path.exists(self.test_file):
            os.remove(self.test_file)
        self.app = TasbihApp(storage_file=self.test_file)

    def tearDown(self):
        if os.path.exists(self.test_file):
            os.remove(self.test_file)

    def test_initialization(self):
        self.assertTrue(len(self.app.counters) >= 5)
        self.assertEqual(self.app.counters[0].name, "SubhanAllah")

    def test_increment(self):
        counter = self.app.counters[0]
        initial_count = counter.current_count
        counter.increment()
        self.assertEqual(counter.current_count, initial_count + 1)
        self.assertEqual(len(counter.history), 1)

    def test_persistence(self):
        self.app.counters[0].increment()
        self.app.save_data()

        new_app = TasbihApp(storage_file=self.test_file)
        self.assertEqual(new_app.counters[0].current_count, 1)
        self.assertEqual(len(new_app.counters[0].history), 1)

    def test_statistics(self):
        # Mock some history
        now = datetime.now()
        yesterday = now - timedelta(days=1)
        last_week = now - timedelta(days=8)

        counter = self.app.counters[0]
        counter.increment() # Today
        counter.history.append(yesterday.isoformat())
        counter.history.append(last_week.isoformat())

        stats = self.app.get_stats()
        self.assertEqual(stats['today'], 1)
        # Yesterday is still within 'this week' if today is not Monday
        # And within 'this month'
        self.assertTrue(stats['week'] >= 1)
        self.assertTrue(stats['month'] >= 2)
        self.assertEqual(sum(stats['history_last_7_days']), 2)

    def test_add_counter(self):
        self.app.add_counter("Test Counter", target=50)
        self.assertEqual(self.app.counters[-1].name, "Test Counter")
        self.assertEqual(self.app.counters[-1].target, 50)

if __name__ == "__main__":
    unittest.main()
