# Accessibility (WCAG AA) Compliance Guide

This document outlines the accessibility features and testing procedures for the Parent Onboarding application.

## WCAG AA Compliance Status

The application is designed to meet **WCAG 2.1 Level AA** standards. Below is a checklist of implemented features:

### ✅ Perceivable

- [x] **Text Alternatives**: All images have alt text or are decorative with aria-hidden
- [x] **Time-based Media**: No auto-playing media, all videos have controls
- [x] **Adaptable**: Content can be presented without losing information (responsive design)
- [x] **Distinguishable**: 
  - Color contrast ratios meet 4.5:1 for normal text, 3:1 for large text
  - Text can be resized up to 200% without loss of functionality
  - Focus indicators are clearly visible

### ✅ Operable

- [x] **Keyboard Accessible**: 
  - All functionality available via keyboard
  - No keyboard traps
  - Logical tab order
- [x] **Enough Time**: 
  - No time limits on forms
  - Auto-save functionality prevents data loss
- [x] **Seizures**: No flashing content
- [x] **Navigable**:
  - Skip links to main content
  - Clear page titles and headings
  - Focus order is logical
  - Multiple ways to navigate (stepper, buttons)

### ✅ Understandable

- [x] **Readable**: 
  - Language declared in HTML (`lang="en"`)
  - Clear, simple language
- [x] **Predictable**:
  - Consistent navigation
  - Consistent labeling
  - No unexpected context changes
- [x] **Input Assistance**:
  - Clear error messages
  - Required fields marked with asterisk
  - Form validation with helpful messages

### ✅ Robust

- [x] **Compatible**:
  - Valid HTML5
  - Proper ARIA attributes
  - Screen reader compatible

## Accessibility Features Implemented

### 1. ARIA Labels and Roles

All interactive elements have proper ARIA labels:

```tsx
// Example from Stepper component
<div role="navigation" aria-label="Onboarding progress">
  <div aria-current={isCurrent ? 'step' : undefined}>
```

### 2. Keyboard Navigation

- All buttons and links are keyboard accessible
- Tab order follows visual flow
- Focus indicators are visible (ring-2 ring-ring)
- Enter/Space activate buttons
- Escape closes dialogs

### 3. Screen Reader Support

- Semantic HTML elements (`<main>`, `<nav>`, `<form>`)
- ARIA live regions for dynamic content
- Proper heading hierarchy (h1 → h2 → h3)
- Descriptive link text

### 4. Focus Management

- Skip links for main content
- Focus trapped in modals/dialogs
- Focus returns to trigger after closing dialogs
- Visible focus indicators on all interactive elements

### 5. Color Contrast

All text meets WCAG AA contrast ratios:
- Normal text: 4.5:1 minimum
- Large text (18pt+): 3:1 minimum
- UI components: 3:1 minimum

### 6. Form Accessibility

- Labels associated with inputs (`htmlFor` and `id`)
- Required fields marked with asterisk and `aria-required`
- Error messages linked to inputs with `aria-describedby`
- Fieldset and legend for grouped inputs

### 7. Responsive and Adaptive

- Content reflows without horizontal scrolling
- Touch targets minimum 44x44px
- Text can be zoomed to 200% without issues

## Testing Procedures

### Automated Testing

1. **axe DevTools** (Browser Extension)
   ```bash
   # Install axe DevTools browser extension
   # Run scan on each page
   ```

2. **Lighthouse** (Chrome DevTools)
   ```bash
   # Open Chrome DevTools → Lighthouse
   # Run Accessibility audit
   # Target: 90+ score
   ```

3. **WAVE** (Web Accessibility Evaluation Tool)
   ```bash
   # Use WAVE browser extension or online tool
   # Check for errors and warnings
   ```

### Manual Testing

1. **Keyboard Navigation**
   - [ ] Tab through all interactive elements
   - [ ] Verify logical tab order
   - [ ] Check focus indicators are visible
   - [ ] Test Enter/Space on buttons
   - [ ] Test Escape on dialogs

2. **Screen Reader Testing**
   - [ ] **NVDA** (Windows) or **VoiceOver** (Mac)
   - [ ] Navigate through entire flow
   - [ ] Verify all content is announced
   - [ ] Check form labels are read correctly
   - [ ] Verify error messages are announced

3. **Visual Testing**
   - [ ] Zoom to 200% - verify no horizontal scroll
   - [ ] Check color contrast with contrast checker
   - [ ] Verify focus indicators are visible
   - [ ] Test in high contrast mode

4. **Mobile Accessibility**
   - [ ] Test with TalkBack (Android) or VoiceOver (iOS)
   - [ ] Verify touch targets are adequate
   - [ ] Check landscape/portrait orientations

## Known Issues and Remediations

### Current Status: ✅ No Critical Issues

All critical accessibility issues have been addressed. Ongoing monitoring recommended.

## Accessibility Testing Checklist

Before deploying, verify:

- [ ] All images have alt text
- [ ] All forms have labels
- [ ] All buttons have accessible names
- [ ] Color is not the only means of conveying information
- [ ] Focus indicators are visible
- [ ] Keyboard navigation works throughout
- [ ] Screen reader announces content correctly
- [ ] Page has proper heading hierarchy
- [ ] Language is declared in HTML
- [ ] No keyboard traps
- [ ] Error messages are clear and helpful
- [ ] Skip links work correctly

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [axe DevTools](https://www.deque.com/axe/devtools/)
- [WAVE](https://wave.webaim.org/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

## Reporting Accessibility Issues

If you encounter accessibility issues, please report them with:
- Browser and version
- Screen reader (if applicable)
- Steps to reproduce
- Expected vs actual behavior

