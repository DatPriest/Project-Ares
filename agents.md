# AI Agents for Project Ares

This document describes the AI agent configurations and workflows for developing Project Ares, a 2D Top-Down Survivor Roguelite game built with Godot Engine 4.

## Overview

Project Ares uses AI agents and Model Context Protocol (MCP) servers to enhance development workflows, code quality, and productivity. This setup enables intelligent assistance for Godot-specific development tasks, GDScript coding, game design, and testing.

## Agent Configurations

### 1. Godot Development Agent

**Purpose**: Specialized assistance for Godot Engine 4 development, GDScript coding, and scene management.

**Capabilities**:
- GDScript code analysis and refactoring
- Component-based architecture assistance
- Scene structure optimization
- Signal and event system guidance
- Performance optimization for 2D games

**Context**: Uses project-specific patterns and conventions defined in `.github/copilot-instructions.md`

### 2. Game Design Agent

**Purpose**: Assists with game mechanics, balance, and progression systems.

**Capabilities**:
- Ability system design and balancing
- Enemy behavior and AI patterns
- Progression system optimization
- Multiplayer synchronization guidance
- Performance tuning for survival games

### 3. Testing and Quality Assurance Agent

**Purpose**: Automated testing, code quality, and performance monitoring.

**Capabilities**:
- DPS benchmark analysis
- Component integration testing
- Performance profiling assistance
- Bug detection and debugging
- Code review and style enforcement

## MCP Server Configurations

### Godot MCP Server

Provides context-aware assistance for Godot development:

```json
{
  "name": "godot-mcp-server",
  "command": "godot-mcp-server",
  "args": ["--project-path", "/home/runner/work/Project-Ares/Project-Ares"],
  "env": {
    "GODOT_VERSION": "4.2",
    "PROJECT_TYPE": "2d_survivor"
  }
}
```

**Features**:
- Scene file analysis
- GDScript AST parsing
- Resource dependency tracking
- Performance monitoring integration

### Game Development Context Server

Specialized for game development patterns:

```json
{
  "name": "gamedev-context-server", 
  "command": "context7",
  "args": ["--domain", "gamedev", "--engine", "godot"],
  "env": {
    "GAME_GENRE": "survivor_roguelite",
    "ARCHITECTURE": "component_based"
  }
}
```

**Features**:
- Game design pattern recognition
- Component architecture guidance
- Performance optimization suggestions
- Multiplayer development assistance

## Development Workflows

### 1. Component Development Workflow

When creating new components:
1. Agent analyzes existing component patterns
2. Suggests component structure based on project conventions
3. Validates component integration with existing systems
4. Provides testing strategies

### 2. Enemy Design Workflow

For new enemy types:
1. Game Design Agent analyzes balance requirements
2. Suggests stats and abilities based on progression curve
3. Godot Agent provides implementation guidance
4. Testing Agent creates benchmark scenarios

### 3. Performance Optimization Workflow

For performance improvements:
1. Testing Agent identifies bottlenecks using DPS benchmarks
2. Godot Agent suggests engine-specific optimizations
3. Game Design Agent evaluates impact on gameplay
4. Automated validation through CI/CD integration

## Integration with Existing Tools

### DPS Benchmark Integration

The AI agents leverage the existing DPS benchmark system (`scenes/test/dps_benchmark/`) for:
- Performance regression detection
- Ability balancing validation
- Automated performance testing
- CI/CD performance monitoring

### Event System Integration

Agents understand the GameEvents singleton pattern and can:
- Suggest appropriate event emission points
- Validate event listener implementations
- Optimize event-driven architecture
- Debug event flow issues

### Meta Progression Integration

For meta progression features:
- Analyze upgrade balance and progression curves
- Suggest new meta upgrade types
- Validate upgrade integration
- Balance testing assistance

## Context7 Configuration

Context7 is configured to provide enhanced context awareness for:

### Project Structure Context
- Understands component-based architecture
- Recognizes Godot-specific patterns
- Maintains knowledge of project conventions

### Code Quality Context
- Enforces static typing requirements
- Validates naming conventions
- Ensures architectural consistency
- Monitors performance implications

### Game Design Context
- Understands survivor game mechanics
- Maintains balance considerations
- Tracks progression systems
- Monitors multiplayer implications

## Usage Guidelines

### For Developers

1. **Code Reviews**: AI agents automatically review GDScript for adherence to project standards
2. **Architecture Decisions**: Consult agents before major structural changes
3. **Performance Optimization**: Use agents to identify and resolve performance bottlenecks
4. **Testing Strategy**: Leverage agents for comprehensive test planning

### For Designers

1. **Balance Testing**: Use AI-assisted balance analysis for new abilities
2. **Progression Validation**: Validate progression curves with agent assistance
3. **Multiplayer Considerations**: Get guidance on multiplayer impact of design decisions

### For QA

1. **Automated Testing**: Configure agents to run comprehensive test suites
2. **Performance Monitoring**: Set up continuous performance tracking
3. **Regression Detection**: Use agents for automated regression testing

## Configuration Files

### .context7/config.json

```json
{
  "project": {
    "name": "Project Ares",
    "type": "godot_game",
    "version": "4.2",
    "architecture": "component_based"
  },
  "contexts": [
    {
      "name": "godot_development",
      "patterns": ["*.gd", "*.tscn", "*.tres"],
      "rules": [
        "enforce_static_typing",
        "component_architecture",
        "event_driven_design"
      ]
    },
    {
      "name": "game_design",
      "patterns": ["resources/upgrades/*", "resources/enemy_data/*"],
      "rules": [
        "balance_validation",
        "progression_curves",
        "multiplayer_compatibility"
      ]
    }
  ]
}
```

### MCP Server Registry

```json
{
  "servers": {
    "godot": {
      "command": "godot-mcp-server",
      "args": ["--project", "."],
      "description": "Godot Engine 4 development assistance"
    },
    "gamedev": {
      "command": "gamedev-mcp-server", 
      "args": ["--genre", "survivor"],
      "description": "Game development patterns and best practices"
    },
    "performance": {
      "command": "performance-mcp-server",
      "args": ["--benchmark-dir", "scenes/test/dps_benchmark"],
      "description": "Performance monitoring and optimization"
    }
  }
}
```

## Best Practices

### 1. Agent Interaction
- Always provide clear context about the specific problem
- Reference existing code patterns when seeking assistance
- Validate agent suggestions against project requirements

### 2. Code Quality
- Use agents to enforce static typing requirements
- Leverage agents for architectural consistency checks
- Integrate agent feedback into code review process

### 3. Performance Monitoring
- Regularly use agents to analyze performance metrics
- Set up automated performance regression detection
- Use agent insights for optimization prioritization

### 4. Documentation
- Keep agent configurations updated with project evolution
- Document any custom agent behaviors or configurations
- Share agent insights with the development team

## Troubleshooting

### Common Issues

1. **Agent Context Loss**: Ensure proper context configuration in `.context7/config.json`
2. **MCP Server Connectivity**: Verify server configurations and environment variables
3. **Performance Degradation**: Check agent resource usage and optimize configurations
4. **Inconsistent Suggestions**: Update agent training data with latest project patterns

### Debug Commands

```bash
# Test MCP server connectivity
context7 test-connection --server godot

# Validate agent configurations
context7 validate-config

# Monitor agent performance
context7 monitor --server all
```

## Future Enhancements

### Planned Features
- Automated code generation for common component patterns
- Real-time multiplayer testing assistance
- Advanced performance profiling integration
- Steam integration testing support

### Integration Opportunities
- GitHub Actions workflow integration
- Automated PR review assistance
- Continuous integration performance testing
- Community contribution guidance

---

This configuration enables intelligent, context-aware assistance throughout the Project Ares development lifecycle, from initial code development to performance optimization and quality assurance.