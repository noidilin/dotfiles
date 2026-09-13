"""MetaAge AWS Estimator v2 — DXT Entry Point."""
import sys, os, runpy

# PATCHED (not upstream). Claude Desktop launches this server with a bare
# `python3`, which resolves to /opt/homebrew/bin/python3 — no mcp/boto3/
# openpyxl, and its site-packages are replaced by every `brew upgrade python`.
# Re-exec into the mise-managed venv instead. That venv and this patch are both
# owned by ~/.local/share/metaage-aws-estimator/mise.toml: `mise run install`
# rebuilds the venv, and `mise run patch` re-asserts this file after an
# extension update overwrites it.
VENV_PY = os.path.expanduser('~/.local/share/metaage-aws-estimator/.venv/bin/python')
try:
    import mcp.server.fastmcp  # noqa: F401
    import boto3  # noqa: F401
    import openpyxl  # noqa: F401
except ImportError:
    # execv keeps the PID and the inherited stdio pipes, which the MCP stdio
    # transport is already talking over. The realpath check stops an exec loop
    # if the venv itself is incomplete: one clean traceback instead.
    if os.path.exists(VENV_PY) and os.path.realpath(sys.executable) != os.path.realpath(VENV_PY):
        os.execv(VENV_PY, [VENV_PY, os.path.abspath(__file__), *sys.argv[1:]])
    raise

server_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'server')
sys.path.insert(0, server_dir)
runpy.run_path(os.path.join(server_dir, 'server.py'), run_name='__main__')
