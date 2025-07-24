const { test, expect } = require('@playwright/test');

test.describe('Animal Exploration Features', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the application
    await page.goto('/');
    
    // Wait for the app to load
    await page.waitForSelector('[data-testid="app-container"]');
  });

  test('should display the home page with animal cards', async ({ page }) => {
    // Check if the main title is visible
    await expect(page.locator('h1')).toContainText('Vision Week Virtual Exploration');
    
    // Check if animal cards are displayed
    const animalCards = page.locator('[data-testid="animal-card"]');
    await expect(animalCards).toHaveCountGreaterThan(0);
    
    // Check if each card has required elements
    const firstCard = animalCards.first();
    await expect(firstCard.locator('[data-testid="animal-name"]')).toBeVisible();
    await expect(firstCard.locator('[data-testid="animal-image"]')).toBeVisible();
    await expect(firstCard.locator('[data-testid="animal-description"]')).toBeVisible();
  });

  test('should filter animals by category', async ({ page }) => {
    // Click on category filter
    await page.click('[data-testid="category-filter"]');
    
    // Select "Mammals" category
    await page.click('[data-testid="category-mammals"]');
    
    // Wait for filtering to complete
    await page.waitForTimeout(1000);
    
    // Check that only mammal cards are displayed
    const animalCards = page.locator('[data-testid="animal-card"]');
    const cardCount = await animalCards.count();
    
    for (let i = 0; i < cardCount; i++) {
      const card = animalCards.nth(i);
      const category = await card.getAttribute('data-category');
      expect(category).toBe('mammals');
    }
  });

  test('should search for animals', async ({ page }) => {
    // Type in search box
    const searchInput = page.locator('[data-testid="search-input"]');
    await searchInput.fill('lion');
    
    // Wait for search results
    await page.waitForTimeout(1000);
    
    // Check that search results contain "lion"
    const animalCards = page.locator('[data-testid="animal-card"]');
    const cardCount = await animalCards.count();
    
    expect(cardCount).toBeGreaterThan(0);
    
    // Check that at least one result contains "lion"
    const firstCardName = await animalCards.first().locator('[data-testid="animal-name"]').textContent();
    expect(firstCardName.toLowerCase()).toContain('lion');
  });

  test('should open animal detail modal', async ({ page }) => {
    // Click on the first animal card
    const firstCard = page.locator('[data-testid="animal-card"]').first();
    await firstCard.click();
    
    // Check if modal is opened
    const modal = page.locator('[data-testid="animal-modal"]');
    await expect(modal).toBeVisible();
    
    // Check modal content
    await expect(modal.locator('[data-testid="modal-animal-name"]')).toBeVisible();
    await expect(modal.locator('[data-testid="modal-animal-image"]')).toBeVisible();
    await expect(modal.locator('[data-testid="modal-animal-description"]')).toBeVisible();
    await expect(modal.locator('[data-testid="modal-scientific-name"]')).toBeVisible();
    await expect(modal.locator('[data-testid="modal-habitat"]')).toBeVisible();
    await expect(modal.locator('[data-testid="modal-conservation-status"]')).toBeVisible();
  });

  test('should close animal detail modal', async ({ page }) => {
    // Open modal
    await page.click('[data-testid="animal-card"]');
    
    // Wait for modal to be visible
    await expect(page.locator('[data-testid="animal-modal"]')).toBeVisible();
    
    // Close modal by clicking close button
    await page.click('[data-testid="modal-close-button"]');
    
    // Check if modal is closed
    await expect(page.locator('[data-testid="animal-modal"]')).not.toBeVisible();
  });

  test('should navigate through animal cards with keyboard', async ({ page }) => {
    // Focus on first animal card
    await page.keyboard.press('Tab');
    
    // Check if first card is focused
    const firstCard = page.locator('[data-testid="animal-card"]').first();
    await expect(firstCard).toBeFocused();
    
    // Navigate to next card with arrow key
    await page.keyboard.press('ArrowRight');
    
    // Check if second card is focused
    const secondCard = page.locator('[data-testid="animal-card"]').nth(1);
    await expect(secondCard).toBeFocused();
    
    // Open modal with Enter key
    await page.keyboard.press('Enter');
    
    // Check if modal is opened
    await expect(page.locator('[data-testid="animal-modal"]')).toBeVisible();
  });

  test('should work on mobile viewport', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    
    // Check if mobile layout is applied
    const container = page.locator('[data-testid="app-container"]');
    await expect(container).toHaveClass(/mobile/);
    
    // Check if hamburger menu is visible
    const hamburgerMenu = page.locator('[data-testid="hamburger-menu"]');
    await expect(hamburgerMenu).toBeVisible();
    
    // Open mobile menu
    await hamburgerMenu.click();
    
    // Check if mobile navigation is visible
    const mobileNav = page.locator('[data-testid="mobile-navigation"]');
    await expect(mobileNav).toBeVisible();
  });

  test('should toggle dark mode', async ({ page }) => {
    // Click dark mode toggle
    const darkModeToggle = page.locator('[data-testid="dark-mode-toggle"]');
    await darkModeToggle.click();
    
    // Check if dark mode is applied
    const body = page.locator('body');
    await expect(body).toHaveClass(/dark-mode/);
    
    // Toggle back to light mode
    await darkModeToggle.click();
    
    // Check if light mode is restored
    await expect(body).not.toHaveClass(/dark-mode/);
  });

  test('should load more animals on scroll', async ({ page }) => {
    // Get initial number of animal cards
    const initialCards = await page.locator('[data-testid="animal-card"]').count();
    
    // Scroll to bottom of page
    await page.evaluate(() => {
      window.scrollTo(0, document.body.scrollHeight);
    });
    
    // Wait for new cards to load
    await page.waitForTimeout(2000);
    
    // Check if more cards are loaded
    const newCards = await page.locator('[data-testid="animal-card"]').count();
    expect(newCards).toBeGreaterThan(initialCards);
  });

  test('should handle network errors gracefully', async ({ page }) => {
    // Intercept API calls and simulate network error
    await page.route('/api/animals', route => {
      route.abort('failed');
    });
    
    // Reload page to trigger API call
    await page.reload();
    
    // Check if error message is displayed
    const errorMessage = page.locator('[data-testid="error-message"]');
    await expect(errorMessage).toBeVisible();
    await expect(errorMessage).toContainText('Unable to load animals');
    
    // Check if retry button is available
    const retryButton = page.locator('[data-testid="retry-button"]');
    await expect(retryButton).toBeVisible();
  });

  test('should submit feedback form', async ({ page }) => {
    // Scroll to feedback section
    await page.locator('[data-testid="feedback-section"]').scrollIntoViewIfNeeded();
    
    // Fill feedback form
    await page.fill('[data-testid="feedback-name"]', 'Test User');
    await page.fill('[data-testid="feedback-email"]', 'test@example.com');
    await page.fill('[data-testid="feedback-message"]', 'This is a test feedback message.');
    
    // Submit form
    await page.click('[data-testid="feedback-submit"]');
    
    // Check for success message
    const successMessage = page.locator('[data-testid="feedback-success"]');
    await expect(successMessage).toBeVisible();
    await expect(successMessage).toContainText('Thank you for your feedback');
  });

  test('should validate feedback form', async ({ page }) => {
    // Scroll to feedback section
    await page.locator('[data-testid="feedback-section"]').scrollIntoViewIfNeeded();
    
    // Try to submit empty form
    await page.click('[data-testid="feedback-submit"]');
    
    // Check for validation errors
    const nameError = page.locator('[data-testid="feedback-name-error"]');
    const emailError = page.locator('[data-testid="feedback-email-error"]');
    const messageError = page.locator('[data-testid="feedback-message-error"]');
    
    await expect(nameError).toBeVisible();
    await expect(emailError).toBeVisible();
    await expect(messageError).toBeVisible();
    
    // Fill invalid email
    await page.fill('[data-testid="feedback-email"]', 'invalid-email');
    await page.click('[data-testid="feedback-submit"]');
    
    // Check for email validation error
    await expect(emailError).toContainText('Please enter a valid email');
  });

  test('should be accessible', async ({ page }) => {
    // Check for proper heading hierarchy
    const h1 = page.locator('h1');
    await expect(h1).toHaveCount(1);
    
    // Check for alt text on images
    const images = page.locator('img');
    const imageCount = await images.count();
    
    for (let i = 0; i < imageCount; i++) {
      const img = images.nth(i);
      const alt = await img.getAttribute('alt');
      expect(alt).toBeTruthy();
    }
    
    // Check for proper form labels
    const inputs = page.locator('input');
    const inputCount = await inputs.count();
    
    for (let i = 0; i < inputCount; i++) {
      const input = inputs.nth(i);
      const id = await input.getAttribute('id');
      if (id) {
        const label = page.locator(`label[for="${id}"]`);
        await expect(label).toBeVisible();
      }
    }
    
    // Check for skip link
    const skipLink = page.locator('[data-testid="skip-link"]');
    await expect(skipLink).toBeVisible();
  });

  test('should work offline', async ({ page, context }) => {
    // Go offline
    await context.setOffline(true);
    
    // Reload page
    await page.reload();
    
    // Check if offline message is displayed
    const offlineMessage = page.locator('[data-testid="offline-message"]');
    await expect(offlineMessage).toBeVisible();
    
    // Check if cached content is still available
    const cachedCards = page.locator('[data-testid="animal-card"]');
    await expect(cachedCards).toHaveCountGreaterThan(0);
    
    // Go back online
    await context.setOffline(false);
    
    // Check if online functionality is restored
    await page.reload();
    await expect(offlineMessage).not.toBeVisible();
  });

  test('should handle different languages', async ({ page }) => {
    // Change language to French
    await page.click('[data-testid="language-selector"]');
    await page.click('[data-testid="language-fr"]');
    
    // Check if content is translated
    const title = page.locator('h1');
    await expect(title).toContainText('Exploration Virtuelle');
    
    // Check if animal descriptions are translated
    const animalCard = page.locator('[data-testid="animal-card"]').first();
    const description = animalCard.locator('[data-testid="animal-description"]');
    const descriptionText = await description.textContent();
    
    // Should contain French text (basic check)
    expect(descriptionText).toMatch(/[àâäéèêëïîôöùûüÿç]/);
  });
});

