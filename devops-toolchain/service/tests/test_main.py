"""
Unit tests for main module.
"""

import pytest
import sys
import os

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from main import get_config, health_check, process_task


class TestGetConfig:
    """Tests for get_config function."""
    
    def test_returns_dict(self):
        """Config should return a dictionary."""
        config = get_config()
        assert isinstance(config, dict)
    
    def test_has_required_keys(self):
        """Config should have required keys."""
        config = get_config()
        required_keys = ["app_name", "environment", "log_level", "version"]
        for key in required_keys:
            assert key in config
    
    def test_default_app_name(self):
        """Default app name should be devops-toolchain."""
        config = get_config()
        assert config["app_name"] == "devops-toolchain"
    
    def test_default_environment(self):
        """Default environment should be development."""
        config = get_config()
        assert config["environment"] == "development"


class TestHealthCheck:
    """Tests for health_check function."""
    
    def test_returns_dict(self):
        """Health check should return a dictionary."""
        health = health_check()
        assert isinstance(health, dict)
    
    def test_status_healthy(self):
        """Health status should be healthy."""
        health = health_check()
        assert health["status"] == "healthy"
    
    def test_has_version(self):
        """Health check should include version."""
        health = health_check()
        assert "version" in health
    
    def test_has_checks(self):
        """Health check should include checks."""
        health = health_check()
        assert "checks" in health
        assert "python" in health["checks"]
        assert "platform" in health["checks"]


class TestProcessTask:
    """Tests for process_task function."""
    
    def test_returns_dict(self):
        """Process task should return a dictionary."""
        result = process_task("test-001", {"key": "value"})
        assert isinstance(result, dict)
    
    def test_includes_task_id(self):
        """Result should include task ID."""
        task_id = "test-002"
        result = process_task(task_id, {})
        assert result["task_id"] == task_id
    
    def test_status_completed(self):
        """Status should be completed."""
        result = process_task("test-003", {})
        assert result["status"] == "completed"
    
    def test_includes_input(self):
        """Result should include input data."""
        data = {"message": "test"}
        result = process_task("test-004", data)
        assert result["input"] == data
    
    def test_includes_output(self):
        """Result should include output."""
        result = process_task("test-005", {"a": 1, "b": 2})
        assert "output" in result
        assert result["output"]["processed"] is True
        assert result["output"]["items_count"] == 2

