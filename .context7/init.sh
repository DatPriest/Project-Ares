#!/bin/bash
# Context7 and MCP Server Initialization Script for Project Ares

set -e

echo "Initializing Context7 and MCP servers for Project Ares..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if context7 is available
if ! command -v context7 &> /dev/null; then
    echo -e "${YELLOW}Warning: context7 not found in PATH${NC}"
    echo "Please install context7 for full functionality"
    echo "See: https://github.com/context7/context7"
fi

# Validate configuration files
echo "Validating configuration files..."

if [ -f "config.json" ]; then
    echo -e "${GREEN}✓ Context7 config found${NC}"
    
    # Validate JSON syntax
    if command -v jq &> /dev/null; then
        if jq empty config.json 2>/dev/null; then
            echo -e "${GREEN}✓ Config JSON is valid${NC}"
        else
            echo -e "${RED}✗ Config JSON is invalid${NC}"
            exit 1
        fi
    fi
else
    echo -e "${RED}✗ Context7 config not found${NC}"
    exit 1
fi

if [ -f "mcp-servers.json" ]; then
    echo -e "${GREEN}✓ MCP servers config found${NC}"
    
    # Validate JSON syntax
    if command -v jq &> /dev/null; then
        if jq empty mcp-servers.json 2>/dev/null; then
            echo -e "${GREEN}✓ MCP servers JSON is valid${NC}"
        else
            echo -e "${RED}✗ MCP servers JSON is invalid${NC}"
            exit 1
        fi
    fi
else
    echo -e "${RED}✗ MCP servers config not found${NC}"
    exit 1
fi

if [ -f "workflows.json" ]; then
    echo -e "${GREEN}✓ Workflows config found${NC}"
    
    # Validate JSON syntax
    if command -v jq &> /dev/null; then
        if jq empty workflows.json 2>/dev/null; then
            echo -e "${GREEN}✓ Workflows JSON is valid${NC}"
        else
            echo -e "${RED}✗ Workflows JSON is invalid${NC}"
            exit 1
        fi
    fi
else
    echo -e "${RED}✗ Workflows config not found${NC}"
    exit 1
fi

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p logs cache temp

echo -e "${GREEN}✓ Directories created${NC}"

# Check Godot project structure
echo "Validating Godot project structure..."

if [ -f "../project.godot" ]; then
    echo -e "${GREEN}✓ Godot project file found${NC}"
else
    echo -e "${RED}✗ Godot project file not found${NC}"
    exit 1
fi

# Check for essential project components
REQUIRED_DIRS=(
    "../scenes/component"
    "../scenes/autoload"
    "../scenes/test/dps_benchmark"
    "../resources/upgrades"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓ $dir exists${NC}"
    else
        echo -e "${YELLOW}⚠ $dir not found${NC}"
    fi
done

# Test context7 initialization if available
if command -v context7 &> /dev/null; then
    echo "Testing context7 initialization..."
    
    if context7 validate-config 2>/dev/null; then
        echo -e "${GREEN}✓ Context7 configuration valid${NC}"
    else
        echo -e "${YELLOW}⚠ Context7 configuration validation failed${NC}"
        echo "This may be normal if MCP servers are not yet installed"
    fi
fi

echo ""
echo -e "${GREEN}Context7 and MCP initialization complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Install required MCP servers (see agents.md for details)"
echo "2. Configure your IDE to use the MCP servers"
echo "3. Test workflows with: context7 test-workflow component_development"
echo ""
echo "For more information, see:"
echo "- agents.md - Detailed agent configuration guide"
echo "- .context7/config.json - Main configuration"
echo "- .context7/mcp-servers.json - MCP server definitions"
echo "- .context7/workflows.json - Development workflows"