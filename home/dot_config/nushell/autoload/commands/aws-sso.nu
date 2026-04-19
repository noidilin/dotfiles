# aws-sso.nu — Nushell port of aws-sso shell integration
# [nushell support for shell-helpers · Issue #1132 · synfinatic/aws-sso-cli](https://github.com/synfinatic/aws-sso-cli/issues/1132)
#   - reply thread: https://github.com/synfinatic/aws-sso-cli/issues/1132#issuecomment-4034608246

# ── internal helper ──────────────────────────────────────────────────────────

def _sso_args [] {
    let val = $env.AWS_SSO_HELPER_ARGS?
    if ($val | is-empty) { ["-L" "error"] } else { $val | split words }
}

# ── completions ──────────────────────────────────────────────────────────────

# Completion driver for the aws-sso command (uses COMP_LINE protocol)
def _aws-sso-nu-complete [context: string, offset: int] {
    let line = if ($context | str ends-with " ") { $context } else { $"($context) " }
    with-env { COMP_LINE: $line, __NO_ESCAPE_COLONS: "1" } {
        ^aws-sso | lines | where { |it| ($it | str trim) != "" }
    }
}

# SSO instance (session) completions for --sso flag
def _aws-sso-session-nu-complete [context: string, offset: int] {
    ^aws-sso list ...(_sso_args) --csv SSO
        | lines
        | where { |it| ($it | str trim) != "" }
}

# Profile completions for aws-sso-profile
def _aws-sso-profile-nu-complete [context: string, offset: int] {
    let cur = $context | split row " " | last
    ^aws-sso list ...(_sso_args) --csv -P $"Profile=($cur)" Profile
        | lines
        | where { |it| ($it | str trim) != "" }
}

# Attach completions to the aws-sso external command
export extern aws-sso [...args: string@_aws-sso-nu-complete]

# ── commands ─────────────────────────────────────────────────────────────────

# Assume an AWS SSO profile, loading credentials into the environment
export def --env aws-sso-profile [
    --sso (-S): string@_aws-sso-session-nu-complete  # SSO instance name
    profile: string@_aws-sso-profile-nu-complete     # Profile to assume
] {
    if ($env.AWS_PROFILE? | default "" | is-not-empty) {
        error make { msg: "Unable to assume a role while AWS_PROFILE is set" }
    }

    let creds = if ($sso | is-not-empty) {
        ^aws-sso ...(_sso_args) -S $sso process -p $profile | from json
    } else {
        ^aws-sso ...(_sso_args) process -p $profile | from json
    }

    load-env {
        AWS_ACCESS_KEY_ID:     $creds.AccessKeyId
        AWS_SECRET_ACCESS_KEY: $creds.SecretAccessKey
        AWS_SESSION_TOKEN:     $creds.SessionToken
        AWS_SSO_PROFILE:       $profile
    }
}

# Clear current AWS SSO credentials from the environment
export def --env aws-sso-clear [] {
    if ($env.AWS_SSO_PROFILE? | default "" | is-empty) {
        error make { msg: "AWS_SSO_PROFILE is not set" }
    }

    hide-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SSO_PROFILE
}
hide _sso_args
hide _aws-sso-session-nu-complete
hide _aws-sso-profile-nu-complete
hide _aws-sso-nu-complete
