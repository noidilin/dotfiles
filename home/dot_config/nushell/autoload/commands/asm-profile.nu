const ASM_PROFILES = {
    aws: "github:aws/agent-toolkit-for-aws"
    addy: "github:addyosmani/agent-skills"
}
const ASM_PROFILE_PROVIDERS = [claude agents]

def _asm-profile-names [] { $ASM_PROFILES | columns }

def _asm-profile-skills [profile: string] {
    let source = $ASM_PROFILES | get --optional $profile
    if $source == null {
        error make { msg: $"Unknown profile '($profile)'. Known: (_asm-profile-names | str join ', ')" }
    }
    $nu.home-dir | path join '.config' 'agent-skill-manager' 'library' 'library-lock.json'
        | open
        | get skills
        | values
        | where source == $source
        | get libraryPath
        | path basename
        | sort
}

def _asm-profile-run [action: string, profiles: list<string>, benign: string] {
    $profiles | each {|profile|
        _asm-profile-skills $profile | each {|skill|
            $ASM_PROFILE_PROVIDERS | each {|provider|
                let res = ^asm $action $skill -p $provider -s project --json | complete
                let out = $"($res.stdout)($res.stderr)"
                let status = if $res.exit_code == 0 { "ok" } else if ($out | str contains $benign) { "skipped" } else { "failed" }
                { profile: $profile, skill: $skill, provider: $provider, status: $status }
            }
        }
    } | flatten | flatten
}

def _asm-profile-summary [] {
    let rows = $in
    let failed = $rows | where status == "failed"
    if ($failed | is-not-empty) { $failed } else {
        $rows | group-by status | transpose status count | update count { length }
    }
}

# List profiles, or the library skills a profile resolves to
def "asm-profile list" [profile?: string@_asm-profile-names] {
    if $profile == null {
        _asm-profile-names | each {|p| { profile: $p, source: ($ASM_PROFILES | get $p), skills: (_asm-profile-skills $p | length) } }
    } else {
        _asm-profile-skills $profile
    }
}

# Activate every skill of the profiles into this project's .claude/skills and .agents/skills
def "asm-profile add" [...profiles: string@_asm-profile-names] {
    _asm-profile-run activate $profiles "already exists" | _asm-profile-summary
}

# Deactivate every skill of the profiles from this project's .claude/skills and .agents/skills
def "asm-profile remove" [...profiles: string@_asm-profile-names] {
    _asm-profile-run deactivate $profiles "is not active" | _asm-profile-summary
}
