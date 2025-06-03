#!/bin/bash
set -e

PROJECT_NAME="Nexadew"

echo "🚀 Creating Vite + React project: $PROJECT_NAME"
npm create vite@latest $PROJECT_NAME -- --template react

cd $PROJECT_NAME

echo "📦 Installing project dependencies..."
npm install

echo "🧪 Installing Jest and testing dependencies..."
npm install --save-dev jest babel-jest @babel/preset-env @babel/preset-react @testing-library/react @testing-library/jest-dom @testing-library/user-event identity-obj-proxy jest-environment-jsdom

# Create Babel config for Jest
cat > babel.config.js <<EOL
module.exports = {
  presets: [
    '@babel/preset-env',
    ['@babel/preset-react', { runtime: 'automatic' }]
  ],
};
EOL

# Create Jest config
cat > jest.config.cjs <<EOL
module.exports = {
  testEnvironment: 'jest-environment-jsdom',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  transform: {
    '^.+\\\\.[jt]sx?$': 'babel-jest'
  },
  moduleNameMapper: {
    '\\\\.(css|less|scss|sass)$': 'identity-obj-proxy'
  }
};
EOL

# Jest setup file to include testing-library matchers
cat > jest.setup.js <<EOL
import '@testing-library/jest-dom';
EOL

echo "📘 Initializing Storybook..."
npx sb init

echo "📦 Installing Storybook Vite builder and addons..."
npm install --save-dev @storybook/react @storybook/builder-vite @storybook/addon-essentials

echo "⚙️ Configuring Storybook for Vite..."

mkdir -p .storybook
cat > .storybook/main.js <<EOL
/** @type { import('@storybook/react-vite').StorybookConfig } */
const config = {
  stories: ['../src/**/*.stories.@(js|jsx|ts|tsx)'],
  addons: ['@storybook/addon-essentials'],
  framework: {
    name: '@storybook/react',
    options: {},
  },
  core: {
    builder: 'vite',
  },
};
export default config;
EOL

# Sample component and Storybook story
mkdir -p src/components

cat > src/components/Button.jsx <<EOL
export function Button({ label }) {
  return <button style={{ backgroundColor: '#3b82f6', color: 'white', padding: '0.5rem 1rem', borderRadius: '0.375rem' }}>
    {label}
  </button>;
}
EOL

cat > src/components/Button.stories.jsx <<EOL
import React from 'react';
import { Button } from './Button';

export default {
  title: 'Example/Button',
  component: Button,
};

export const Primary = {
  args: {
    label: 'Click Me',
  },
};
EOL

# Add useful scripts
npm pkg set scripts.dev="vite"
npm pkg set scripts.test="jest"
npm pkg set scripts.storybook="start-storybook -p 6006"
npm pkg set scripts["build-storybook"]="build-storybook"

echo ""
echo "✅ Setup complete! To get started:"
echo "--------------------------------------------------"
echo "cd $PROJECT_NAME"
echo "npm run dev             # Start Vite dev server"
echo "npm test                # Run Jest tests"
echo "npm run storybook       # Start Storybook"
echo "npm run build-storybook # Build static Storybook"
echo "--------------------------------------------------"