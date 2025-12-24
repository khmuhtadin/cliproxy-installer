#!/usr/bin/env python3
"""
CLIProxy Quota Fetcher
Fetches real-time quota data from Antigravity API for all authenticated accounts.
Saves results to quota-cache.json for dashboard to read.
"""

import json
import os
import time
import glob
import requests
from datetime import datetime

# Configuration
AUTH_DIR = os.path.expanduser("~/.cli-proxy-api")
STATIC_DIR = os.path.join(AUTH_DIR, "static")
DASHBOARD_FILE = os.path.join(STATIC_DIR, "dashboard.html")
ANTIGRAVITY_API = "https://daily-cloudcode-pa.sandbox.googleapis.com/v1internal:fetchAvailableModels"
USER_AGENT = "antigravity/1.11.5 windows/amd64"
REFRESH_INTERVAL = 30  # seconds


def load_auth_files():
    """Load all antigravity auth files."""
    auth_files = []
    pattern = os.path.join(AUTH_DIR, "antigravity-*.json")

    for filepath in glob.glob(pattern):
        try:
            with open(filepath, 'r') as f:
                data = json.load(f)
                data['_filepath'] = filepath
                data['_filename'] = os.path.basename(filepath)
                auth_files.append(data)
        except Exception as e:
            print(f"Error loading {filepath}: {e}")

    return auth_files


def fetch_quota(access_token):
    """Fetch quota from Antigravity API."""
    try:
        response = requests.post(
            ANTIGRAVITY_API,
            headers={
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json',
                'User-Agent': USER_AGENT
            },
            json={},
            timeout=10
        )

        if response.status_code == 200:
            return response.json()
        else:
            print(f"API error: {response.status_code}")
            return None
    except Exception as e:
        print(f"Request error: {e}")
        return None


def parse_quota_data(models):
    """Parse quota data from models response."""
    result = {
        'geminiPro': {'remaining': 0, 'resetTime': None, 'count': 0},
        'claude': {'remaining': 0, 'resetTime': None, 'count': 0},
        'geminiFlash': {'remaining': 0, 'resetTime': None, 'count': 0},
        'geminiImage': {'remaining': 0, 'resetTime': None, 'count': 0}
    }

    for name, info in models.items():
        quota_info = info.get('quotaInfo', {})
        remaining = quota_info.get('remainingFraction', 0)
        reset_time = quota_info.get('resetTime')

        name_lower = name.lower()

        if 'claude' in name_lower:
            result['claude']['remaining'] += remaining
            result['claude']['count'] += 1
            if reset_time:
                result['claude']['resetTime'] = reset_time
        elif 'image' in name_lower:
            result['geminiImage']['remaining'] += remaining
            result['geminiImage']['count'] += 1
            if reset_time:
                result['geminiImage']['resetTime'] = reset_time
        elif 'flash' in name_lower:
            result['geminiFlash']['remaining'] += remaining
            result['geminiFlash']['count'] += 1
            if reset_time:
                result['geminiFlash']['resetTime'] = reset_time
        elif 'pro' in name_lower or '2.5' in name_lower or '3-' in name_lower:
            result['geminiPro']['remaining'] += remaining
            result['geminiPro']['count'] += 1
            if reset_time:
                result['geminiPro']['resetTime'] = reset_time

    # Average out remaining fractions
    for key in result:
        if result[key]['count'] > 0:
            result[key]['remaining'] /= result[key]['count']

    return result


def refresh_token_if_needed(auth_data):
    """Refresh OAuth token if expired."""
    expired_str = auth_data.get('expired', '')
    if not expired_str:
        return auth_data.get('access_token')

    try:
        # Parse expiry time
        expired_time = datetime.fromisoformat(expired_str.replace('Z', '+00:00'))
        now = datetime.now(expired_time.tzinfo)

        # If token expires in less than 5 minutes, refresh it
        if (expired_time - now).total_seconds() < 300:
            print(f"Token for {auth_data.get('email')} needs refresh...")
            new_token = refresh_oauth_token(auth_data)
            if new_token:
                return new_token
    except Exception as e:
        print(f"Error checking token expiry: {e}")

    return auth_data.get('access_token')


def refresh_oauth_token(auth_data):
    """Refresh OAuth token using refresh_token."""
    refresh_token = auth_data.get('refresh_token')
    if not refresh_token:
        return None

    try:
        response = requests.post(
            'https://oauth2.googleapis.com/token',
            headers={
                'Content-Type': 'application/x-www-form-urlencoded',
                'User-Agent': USER_AGENT
            },
            data={
                'client_id': '1071006060591-tmhssin2h21lcre235vtolojh4g403ep.apps.googleusercontent.com',
                'client_secret': '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',
                'grant_type': 'refresh_token',
                'refresh_token': refresh_token
            },
            timeout=10
        )

        if response.status_code == 200:
            token_data = response.json()
            new_access_token = token_data.get('access_token')

            # Update the auth file
            auth_data['access_token'] = new_access_token
            auth_data['expires_in'] = token_data.get('expires_in', 3599)
            auth_data['timestamp'] = int(time.time() * 1000)

            # Calculate new expiry
            from datetime import timedelta
            new_expiry = datetime.now() + timedelta(seconds=token_data.get('expires_in', 3599))
            auth_data['expired'] = new_expiry.isoformat()

            # Save updated auth file
            filepath = auth_data.get('_filepath')
            if filepath:
                save_data = {k: v for k, v in auth_data.items() if not k.startswith('_')}
                with open(filepath, 'w') as f:
                    json.dump(save_data, f, indent=4)
                print(f"Token refreshed for {auth_data.get('email')}")

            return new_access_token
        else:
            print(f"Token refresh failed: {response.status_code}")
            return None
    except Exception as e:
        print(f"Token refresh error: {e}")
        return None


def fetch_all_quotas():
    """Fetch quota for all accounts and save to cache."""
    auth_files = load_auth_files()

    if not auth_files:
        print("No auth files found")
        return

    print(f"Found {len(auth_files)} auth files")

    quota_cache = {
        'lastUpdated': datetime.now().isoformat(),
        'accounts': {}
    }

    for auth in auth_files:
        email = auth.get('email', 'unknown')
        filename = auth.get('_filename', '')

        print(f"Fetching quota for {email}...")

        # Get valid access token
        access_token = refresh_token_if_needed(auth)

        if not access_token:
            print(f"  No access token for {email}")
            continue

        # Fetch quota
        quota_response = fetch_quota(access_token)

        if quota_response:
            models = quota_response.get('models', {})
            parsed_quota = parse_quota_data(models)

            quota_cache['accounts'][filename] = {
                'email': email,
                'quota': parsed_quota,
                'fetchedAt': datetime.now().isoformat()
            }

            # Print summary
            print(f"  Gemini Pro: {parsed_quota['geminiPro']['remaining']*100:.0f}%")
            print(f"  Claude: {parsed_quota['claude']['remaining']*100:.0f}%")
            print(f"  Gemini Flash: {parsed_quota['geminiFlash']['remaining']*100:.0f}%")
            print(f"  Gemini Image: {parsed_quota['geminiImage']['remaining']*100:.0f}%")
        else:
            print(f"  Failed to fetch quota for {email}")

    # Save cache by embedding into dashboard.html
    os.makedirs(STATIC_DIR, exist_ok=True)

    # Read current dashboard.html
    if os.path.exists(DASHBOARD_FILE):
        with open(DASHBOARD_FILE, 'r') as f:
            dashboard_content = f.read()

        # Find and replace the quota cache marker
        cache_json = json.dumps(quota_cache)
        marker_start = '// QUOTA_CACHE_START'
        marker_end = '// QUOTA_CACHE_END'

        if marker_start in dashboard_content and marker_end in dashboard_content:
            # Replace existing cache
            import re
            pattern = re.escape(marker_start) + r'.*?' + re.escape(marker_end)
            replacement = f"{marker_start}\n        const EMBEDDED_QUOTA_CACHE = {cache_json};\n        {marker_end}"
            dashboard_content = re.sub(pattern, replacement, dashboard_content, flags=re.DOTALL)

            with open(DASHBOARD_FILE, 'w') as f:
                f.write(dashboard_content)
            print(f"\nQuota cache embedded into {DASHBOARD_FILE}")
        else:
            print(f"\nMarkers not found in dashboard.html - cannot embed cache")
    else:
        print(f"\nDashboard file not found: {DASHBOARD_FILE}")

    print(f"Last updated: {quota_cache['lastUpdated']}")


def run_daemon():
    """Run as daemon, refreshing quota every REFRESH_INTERVAL seconds."""
    print(f"Starting quota fetcher daemon (refresh every {REFRESH_INTERVAL}s)")
    print(f"Dashboard file: {DASHBOARD_FILE}")
    print("-" * 50)

    while True:
        try:
            fetch_all_quotas()
        except Exception as e:
            print(f"Error: {e}")

        print(f"\nNext refresh in {REFRESH_INTERVAL} seconds...")
        time.sleep(REFRESH_INTERVAL)


if __name__ == '__main__':
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == '--daemon':
        run_daemon()
    else:
        # Single run
        fetch_all_quotas()
