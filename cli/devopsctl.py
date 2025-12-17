#!/usr/bin/env python3
"""
devopsctl - Internal Developer CLI for DevOps Toolchain Pipeline

Provides a unified command interface for developers to interact with
the pipeline locally and consistently.

Usage:
    python devopsctl.py <command>

Commands:
    lint     Run linters (eslint, flake8)
    test     Execute unit tests (jest, pytest)
    build    Build packages
    docker   Build Docker image
    publish  Publish artifacts
    all      Run complete pipeline (lint -> test -> build -> docker -> publish)
    version  Show version information
    help     Show this help message
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

# Version information
VERSION = "0.1.0"
SCRIPT_DIR = Path(__file__).parent.absolute()
PROJECT_ROOT = SCRIPT_DIR.parent
SCRIPTS_DIR = PROJECT_ROOT / "scripts"

# Enable UTF-8 output on Windows
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except AttributeError:
        pass


class Colors:
    """ANSI color codes for terminal output."""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    
    # Check if colors are supported
    @staticmethod
    def enabled():
        return hasattr(sys.stdout, 'isatty') and sys.stdout.isatty()


def safe_print(message: str) -> None:
    """Print with fallback for encoding issues."""
    try:
        print(message)
    except UnicodeEncodeError:
        # Fallback: remove non-ASCII characters
        ascii_msg = message.encode('ascii', errors='ignore').decode('ascii')
        print(ascii_msg)


def print_header(message: str) -> None:
    """Print a formatted header message."""
    line = "=" * 60
    if Colors.enabled():
        safe_print(f"\n{Colors.BOLD}{Colors.CYAN}{line}{Colors.ENDC}")
        safe_print(f"{Colors.BOLD}{Colors.CYAN}  {message}{Colors.ENDC}")
        safe_print(f"{Colors.BOLD}{Colors.CYAN}{line}{Colors.ENDC}\n")
    else:
        safe_print(f"\n{line}")
        safe_print(f"  {message}")
        safe_print(f"{line}\n")


def print_success(message: str) -> None:
    """Print a success message."""
    if Colors.enabled():
        safe_print(f"{Colors.GREEN}[OK] {message}{Colors.ENDC}")
    else:
        safe_print(f"[OK] {message}")


def print_error(message: str) -> None:
    """Print an error message."""
    if Colors.enabled():
        safe_print(f"{Colors.FAIL}[FAIL] {message}{Colors.ENDC}")
    else:
        safe_print(f"[FAIL] {message}")


def print_info(message: str) -> None:
    """Print an info message."""
    if Colors.enabled():
        safe_print(f"{Colors.BLUE}[INFO] {message}{Colors.ENDC}")
    else:
        safe_print(f"[INFO] {message}")


def run_script(script_name: str) -> int:
    """
    Run a shell script from the scripts directory.
    
    Args:
        script_name: Name of the script to run (without .sh extension)
    
    Returns:
        Exit code from the script
    """
    script_path = SCRIPTS_DIR / f"{script_name}.sh"
    
    if not script_path.exists():
        print_error(f"Script not found: {script_path}")
        return 1
    
    print_info(f"Running {script_name}.sh ...")
    
    # Determine the shell to use
    shell_cmd = None
    
    if sys.platform == "win32":
        # Try Git Bash first, then WSL bash
        git_bash = Path("C:/Program Files/Git/bin/bash.exe")
        if git_bash.exists():
            shell_cmd = [str(git_bash), str(script_path)]
        else:
            # Try regular bash (might be in PATH from Git Bash or WSL)
            shell_cmd = ["bash", str(script_path)]
    else:
        shell_cmd = ["bash", str(script_path)]
    
    try:
        result = subprocess.run(
            shell_cmd,
            cwd=PROJECT_ROOT,
            check=False,
            env={**os.environ, "PYTHONIOENCODING": "utf-8"}
        )
        return result.returncode
    except FileNotFoundError:
        print_error("Bash not found!")
        print_info("On Windows, install Git Bash: https://git-scm.com/downloads")
        return 1


def cmd_lint() -> int:
    """Run linting checks."""
    print_header("LINT - Running Code Linters")
    return run_script("lint")


def cmd_test() -> int:
    """Run unit tests."""
    print_header("TEST - Running Unit Tests")
    return run_script("test")


def cmd_build() -> int:
    """Build the package."""
    print_header("BUILD - Building Packages")
    return run_script("build")


def cmd_docker() -> int:
    """Build Docker image."""
    print_header("DOCKER - Building Docker Image")
    return run_script("docker")


def cmd_publish() -> int:
    """Publish artifacts."""
    print_header("PUBLISH - Publishing Artifacts")
    return run_script("publish")


def cmd_all() -> int:
    """Run the complete pipeline."""
    print_header("PIPELINE - Running Complete CI/CD Pipeline")
    
    stages = [
        ("LINT", cmd_lint),
        ("TEST", cmd_test),
        ("BUILD", cmd_build),
        ("DOCKER", cmd_docker),
        ("PUBLISH", cmd_publish),
    ]
    
    for stage_name, stage_func in stages:
        safe_print(f"\n{'='*60}")
        print_info(f"Starting Stage: {stage_name}")
        safe_print(f"{'='*60}")
        
        result = stage_func()
        
        if result != 0:
            print_error(f"Pipeline FAILED at stage: {stage_name}")
            return result
        
        print_success(f"Stage {stage_name} completed")
    
    safe_print("")
    print_header("PIPELINE COMPLETED SUCCESSFULLY!")
    return 0


def cmd_version() -> int:
    """Show version information."""
    safe_print(f"devopsctl version {VERSION}")
    safe_print(f"Project root: {PROJECT_ROOT}")
    return 0


def cmd_help() -> int:
    """Show help message."""
    safe_print(__doc__)
    return 0


def main() -> int:
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(
        description="DevOps Toolchain CLI - Run CI/CD pipeline locally",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python devopsctl.py lint      Run code linters
  python devopsctl.py test      Run unit tests
  python devopsctl.py build     Build the package
  python devopsctl.py docker    Build Docker image
  python devopsctl.py publish   Publish artifacts
  python devopsctl.py all       Run complete pipeline
        """
    )
    
    parser.add_argument(
        "command",
        choices=["lint", "test", "build", "docker", "publish", "all", "version", "help"],
        help="Command to execute"
    )
    
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose output"
    )
    
    # Handle no arguments
    if len(sys.argv) == 1:
        parser.print_help()
        return 0
    
    args = parser.parse_args()
    
    # Command dispatch
    commands = {
        "lint": cmd_lint,
        "test": cmd_test,
        "build": cmd_build,
        "docker": cmd_docker,
        "publish": cmd_publish,
        "all": cmd_all,
        "version": cmd_version,
        "help": cmd_help,
    }
    
    # Execute the command
    cmd_func = commands.get(args.command)
    if cmd_func:
        return cmd_func()
    else:
        print_error(f"Unknown command: {args.command}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
