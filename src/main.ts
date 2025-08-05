// Smooth scrolling for navigation links
for (const anchor of document.querySelectorAll('a[href^="#"]')) {
  anchor.addEventListener('click', (e) => {
    e.preventDefault();
    const href = (e.currentTarget as HTMLAnchorElement).getAttribute('href');
    if (href) {
      const target = document.querySelector(href);
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    }
  });
}

// Add animation on scroll
const observerOptions = {
  threshold: 0.1,
  rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
  for (const entry of entries) {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
    }
  }
}, observerOptions);

// Observe all feature cards and steps
for (const el of document.querySelectorAll('.feature-card, .step')) {
  el.classList.add('animate-on-scroll');
  observer.observe(el);
}

// Add copy functionality to code blocks
for (const codeBlock of document.querySelectorAll('code')) {
  codeBlock.addEventListener('click', async () => {
    const text = codeBlock.textContent || '';
    try {
      await navigator.clipboard.writeText(text);

      // Show feedback
      const originalText = codeBlock.textContent;
      codeBlock.textContent = '✓ Скопировано!';
      codeBlock.style.backgroundColor = '#27ae60';
      codeBlock.style.color = 'white';

      setTimeout(() => {
        codeBlock.textContent = originalText;
        codeBlock.style.backgroundColor = '';
        codeBlock.style.color = '';
      }, 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  });

  // Add hover effect
  codeBlock.style.cursor = 'pointer';
  codeBlock.title = 'Нажмите для копирования';
}

// Add styles for animations
const style = document.createElement('style');
style.textContent = `
  .animate-on-scroll {
    opacity: 0;
    transform: translateY(30px);
    transition: opacity 0.6s ease, transform 0.6s ease;
  }

  .animate-on-scroll.visible {
    opacity: 1;
    transform: translateY(0);
  }

  code {
    transition: all 0.3s ease;
  }

  code:hover {
    transform: translateX(5px);
  }
`;
document.head.appendChild(style);

// Log initialization
console.log('n8n Telegram Bot landing page initialized');

export {};
