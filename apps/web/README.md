# Daybreak Health - Parent Onboarding Web App

Next.js 15 web application for parent onboarding with AI-powered intake.

## Mobile-First Responsive Design

This application is built with a **mobile-first approach** using Tailwind CSS. All components are designed to work seamlessly across devices from mobile phones to desktop computers.

### Responsive Breakpoints

- **Mobile**: Default (0px+) - Single column layouts, stacked elements
- **Tablet**: `sm:` (640px+) - Two-column grids, side-by-side buttons
- **Desktop**: `md:` (768px+) - Three-column grids, full navigation
- **Large Desktop**: `lg:` (1024px+) - Maximum content width

### Key Mobile Optimizations

1. **Touch Targets**: All interactive elements meet the minimum 44x44px touch target size
2. **Safe Area Insets**: Support for iOS safe areas (notch, home indicator)
3. **Text Size**: Prevents iOS text size adjustment
4. **Smooth Scrolling**: Native smooth scrolling on mobile devices
5. **Viewport Meta**: Proper viewport configuration in layout

### Component Responsive Patterns

- **Stepper**: Horizontal on desktop, vertical on mobile
- **Forms**: Single column on mobile, two-column on tablet+
- **Buttons**: Full width on mobile, auto width on desktop
- **Cards**: Stacked on mobile, grid layout on larger screens
- **Navigation**: Collapsed on mobile, expanded on desktop

### Testing Responsive Design

1. Use browser DevTools responsive mode
2. Test on real devices (iOS Safari, Android Chrome)
3. Verify touch targets are easily tappable
4. Check text readability at all sizes
5. Ensure no horizontal scrolling

## Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## Accessibility

All components follow WCAG AA guidelines:
- Proper ARIA labels and roles
- Keyboard navigation support
- Screen reader compatibility
- Color contrast ratios
- Focus indicators
