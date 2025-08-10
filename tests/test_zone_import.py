import unittest
import subprocess
import sys
import os

class TestZoneImport(unittest.TestCase):
    def test_help_message(self):
        """Test that zone-import.py prints help message."""
        script_path = os.path.join(os.path.dirname(__file__), '..', 'src', 'zone-import.py')
        result = subprocess.run([sys.executable, script_path, '-h'], capture_output=True, text=True)
        self.assertIn('usage', result.stdout.lower())
        self.assertEqual(result.returncode, 0)

if __name__ == '__main__':
    unittest.main()
