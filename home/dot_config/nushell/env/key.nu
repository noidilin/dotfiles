$env.ANTHROPIC_API_KEY = ( open ($nu.home-path | path join '.config' 'api' 'ANTHROPIC_API_KEY') | str trim )
$env.TAVILY_API_KEY = ( open ($nu.home-path | path join '.config' 'api' 'TAVILY_API_KEY') | str trim )
