#!/bin/bash

# BreitlingApp Project Structure Setup Script
# Based on comprehensive JSON analysis for luxury ecommerce iOS app

echo "🏗️  Setting up BreitlingApp project structure..."
echo "📱 Creating luxury watch app architecture..."

# Navigate to project root (assuming script is run from project directory)
PROJECT_ROOT="."

# Create main directory structure
echo "📁 Creating main directories..."

# App - Main app entry point and configuration
mkdir -p "$PROJECT_ROOT/BreitlingApp/App"

# Core - Fundamental app infrastructure
mkdir -p "$PROJECT_ROOT/BreitlingApp/Core/Navigation"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Core/Services"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Core/Network"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Core/Storage"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Core/Utilities"

# Features - Main app features (7 main views from JSON)
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Home/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Home/ViewModels"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Collections/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Collections/ViewModels"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/ProductDetail/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/ProductDetail/ViewModels"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Search/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Search/ViewModels"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Boutiques/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Boutiques/ViewModels"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Wishlist/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Wishlist/ViewModels"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Profile/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Profile/ViewModels"

# Advanced Features from JSON analysis
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/AR/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/AR/ViewModels"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Appointments/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/Appointments/ViewModels"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/WatchConfigurator/Views"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Features/WatchConfigurator/ViewModels"

# Shared - Reusable components and models
mkdir -p "$PROJECT_ROOT/BreitlingApp/Shared/Models"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Shared/Components/Buttons"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Shared/Components/Cards"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Shared/Components/Navigation"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Shared/Components/Forms"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Shared/Extensions"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Shared/Constants"

# Design System - Based on extracted colors and typography from JSON
mkdir -p "$PROJECT_ROOT/BreitlingApp/DesignSystem/Colors"
mkdir -p "$PROJECT_ROOT/BreitlingApp/DesignSystem/Typography"
mkdir -p "$PROJECT_ROOT/BreitlingApp/DesignSystem/Spacing"
mkdir -p "$PROJECT_ROOT/BreitlingApp/DesignSystem/Components"

# Resources - Assets and configuration
mkdir -p "$PROJECT_ROOT/BreitlingApp/Resources/Assets/Images"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Resources/Assets/Icons"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Resources/Fonts"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Resources/Localization"
mkdir -p "$PROJECT_ROOT/BreitlingApp/Resources/Data"

echo "✅ Directory structure created successfully!"
echo ""
echo "📊 Project Structure Summary:"
echo "🚀 App/ - Main app entry point"
echo "⚙️ Core/ - Navigation, Services, Network, Storage"
echo "📱 Features/ - 7 main views + AR, Appointments, Configurator"
echo "🔄 Shared/ - Models, Components, Extensions"
echo "🎨 DesignSystem/ - Colors, Typography, Spacing"
echo "📁 Resources/ - Assets, Fonts, Localization"
echo ""
echo "🎯 Ready for step-by-step development!"
echo "Next: Create individual files as needed"