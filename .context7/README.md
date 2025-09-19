# Context7 and MCP Configuration for Project Ares

This directory contains the Context7 and Model Context Protocol (MCP) server configurations for Project Ares, providing intelligent development assistance for Godot Engine 4 development.

## Quick Start

1. **Initialize the configuration:**
   ```bash
   cd .context7
   ./init.sh
   ```

2. **Install context7 (if not already installed):**
   ```bash
   npm install -g context7
   # or
   pip install context7
   ```

3. **Validate configuration:**
   ```bash
   context7 validate-config
   ```

## Configuration Files

### `config.json`
Main Context7 configuration defining:
- Project structure and patterns
- Development contexts (Godot, game design, components)
- Quality gates and validation rules
- Workflow definitions

### `mcp-servers.json`
MCP server definitions for specialized development assistance:
- **godot-dev**: Godot Engine specific development support
- **gamedev-patterns**: Game design patterns and balancing
- **performance-monitor**: Performance monitoring and optimization
- **code-quality**: Static analysis and code quality enforcement
- **git-workflow**: Git workflow and project management

### `workflows.json`
Automated development workflows:
- Component development workflow
- Enemy design workflow
- Ability system development
- Performance optimization workflow
- Multiplayer integration workflow

## Usage Examples

### Component Development
When creating a new component in `scenes/component/`:

```bash
# Context7 automatically triggers component development workflow
context7 workflow run component_development --file scenes/component/new_component.gd
```

The workflow will:
1. Analyze existing component patterns
2. Validate component structure and typing
3. Suggest integration points
4. Generate testing strategy

### Performance Analysis
For performance optimization:

```bash
# Run performance analysis workflow
context7 workflow run performance_optimization --trigger manual
```

This integrates with the existing DPS benchmark system in `scenes/test/dps_benchmark/`.

### Enemy Balance Validation
When creating new enemies:

```bash
# Validate enemy balance and implementation
context7 workflow run enemy_design --file resources/enemy_data/new_enemy.tres
```

## Integration with Existing Systems

### DPS Benchmark Integration
Context7 integrates with the existing DPS benchmark system:
- Automatic performance regression detection
- Balance validation through benchmarking
- Optimization suggestions based on benchmark results

### GameEvents Integration
The MCP servers understand the project's event-driven architecture:
- Validates proper GameEvents usage
- Suggests event emission points
- Optimizes event listener implementations

### Component Architecture
Specialized support for the component-based architecture:
- Validates component composition patterns
- Suggests component interactions
- Ensures architectural consistency

## Development Workflows

### 1. New Feature Development
```bash
# Start feature development with AI assistance
context7 start-session --context godot_development
```

### 2. Code Review
```bash
# Run automated code review
context7 review --files "scenes/component/*.gd"
```

### 3. Performance Optimization
```bash
# Analyze performance and get optimization suggestions
context7 optimize --benchmark-integration
```

### 4. Balance Testing
```bash
# Test game balance with AI assistance
context7 balance-test --enemy-data resources/enemy_data/
```

## Customization

### Adding New Contexts
Edit `config.json` to add new development contexts:

```json
{
  "name": "custom_context",
  "patterns": ["custom/path/*.gd"],
  "rules": ["custom_rule"],
  "priority": "medium"
}
```

### Adding New MCP Servers
Edit `mcp-servers.json` to add new specialized servers:

```json
{
  "custom-server": {
    "command": "custom-mcp-server",
    "args": ["--project", "."],
    "capabilities": ["custom_capability"]
  }
}
```

### Adding New Workflows
Edit `workflows.json` to add custom development workflows.

## Troubleshooting

### Common Issues

1. **Context7 not found**
   ```bash
   # Install context7
   npm install -g context7
   ```

2. **MCP server connection failed**
   ```bash
   # Check server configuration
   context7 test-connection --server godot-dev
   ```

3. **Configuration validation failed**
   ```bash
   # Validate configuration files
   jq empty config.json
   jq empty mcp-servers.json
   jq empty workflows.json
   ```

### Debug Commands

```bash
# Test all configurations
./init.sh

# Validate specific workflow
context7 validate-workflow component_development

# Monitor workflow execution
context7 monitor --workflow-logs
```

## Integration with IDEs

### VS Code
Install the Context7 extension and configure:
```json
{
  "context7.configPath": ".context7/config.json",
  "context7.enableMCP": true
}
```

### Godot Editor
Context7 can integrate with Godot through:
- Build hooks
- Script validation
- Performance monitoring during editor play

## Performance Considerations

- MCP servers run asynchronously to avoid blocking development
- Workflow execution is optimized for 2D game development patterns
- Performance monitoring integrates with existing benchmark system

## See Also

- [`../agents.md`](../agents.md) - Comprehensive AI agent documentation
- [`../scenes/test/dps_benchmark/`](../scenes/test/dps_benchmark/) - Performance benchmark system
- [`../.github/copilot-instructions.md`](../.github/copilot-instructions.md) - Development guidelines