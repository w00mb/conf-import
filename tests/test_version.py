import unittest
import os

class TestVersion(unittest.TestCase):
    def test_readme_exists(self):
        """Check that README.md exists in the project root."""
        self.assertTrue(os.path.isfile(os.path.join(os.path.dirname(__file__), '..', 'README.md')))

    def test_src_exists(self):
        """Check that src/zone-import.py exists."""
        self.assertTrue(os.path.isfile(os.path.join(os.path.dirname(__file__), '..', 'src', 'zone-import.py')))

if __name__ == '__main__':
    unittest.main()
