// ============================================================================
// GYM MANAGEMENT - MAIN JAVASCRIPT
// Enhanced functionality for interactive elements
// ============================================================================

document.addEventListener('DOMContentLoaded', function() {
  
  // ============================================================================
  // FLASH MESSAGES - Auto-hide after 5 seconds
  // ============================================================================
  const flashMessages = document.querySelectorAll('.alert');
  if (flashMessages.length > 0) {
    setTimeout(function() {
      flashMessages.forEach(function(alert) {
        const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
        bsAlert.close();
      });
    }, 5000);
  }
  
  
  // ============================================================================
  // NAVIGATION - Active link highlighting
  // ============================================================================
  const currentPath = window.location.pathname;
  const navLinks = document.querySelectorAll('.nav-link');
  
  navLinks.forEach(function(link) {
    if (link.getAttribute('href') === currentPath) {
      link.classList.add('active');
    }
  });
  
  
  // ============================================================================
  // FORM VALIDATION - Enhanced validation feedback
  // ============================================================================
  const forms = document.querySelectorAll('form');
  
  forms.forEach(function(form) {
    form.addEventListener('submit', function(event) {
      if (!form.checkValidity()) {
        event.preventDefault();
        event.stopPropagation();
      }
      form.classList.add('was-validated');
    });
  });
  
  
  // ============================================================================
  // ANIMATIONS - Scroll reveal for cards
  // ============================================================================
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };
  
  const observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '0';
        entry.target.style.transform = 'translateY(20px)';
        
        setTimeout(function() {
          entry.target.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'translateY(0)';
        }, 100);
        
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);
  
  // Observe all cards
  const cards = document.querySelectorAll('.card, .pricing-card');
  cards.forEach(function(card) {
    observer.observe(card);
  });
  
  
  // ============================================================================
  // TOOLTIPS - Initialize Bootstrap tooltips
  // ============================================================================
  const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  tooltipTriggerList.map(function(tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });
  
  
  // ============================================================================
  // SMOOTH SCROLL - For anchor links
  // ============================================================================
  document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
    anchor.addEventListener('click', function(e) {
      const targetId = this.getAttribute('href');
      if (targetId !== '#' && targetId.length > 1) {
        const targetElement = document.querySelector(targetId);
        if (targetElement) {
          e.preventDefault();
          targetElement.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      }
    });
  });
  
  
  // ============================================================================
  // TABLE ENHANCEMENTS - Row click handlers
  // ============================================================================
  const tableRows = document.querySelectorAll('table tbody tr');
  tableRows.forEach(function(row) {
    row.style.cursor = 'pointer';
    row.addEventListener('click', function(e) {
      // Only if clicking on the row itself, not buttons
      if (e.target.tagName !== 'BUTTON' && e.target.tagName !== 'A' && !e.target.closest('button') && !e.target.closest('a')) {
        this.classList.toggle('table-active');
      }
    });
  });
  
  
  // ============================================================================
  // DYNAMIC LOADING - Show loading state for async operations
  // ============================================================================
  function showLoading(element) {
    const originalContent = element.innerHTML;
    element.dataset.originalContent = originalContent;
    element.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Chargement...';
    element.disabled = true;
  }
  
  function hideLoading(element) {
    if (element.dataset.originalContent) {
      element.innerHTML = element.dataset.originalContent;
      delete element.dataset.originalContent;
    }
    element.disabled = false;
  }
  
  // Export functions for use in other scripts
  window.gymUtils = {
    showLoading: showLoading,
    hideLoading: hideLoading
  };
  
  
  // ============================================================================
  // CONFIRM DIALOGS - For destructive actions
  // ============================================================================
  const dangerButtons = document.querySelectorAll('.btn-danger, [data-confirm]');
  dangerButtons.forEach(function(button) {
    button.addEventListener('click', function(e) {
      const message = this.dataset.confirm || 'Êtes-vous sûr de vouloir continuer ?';
      if (!confirm(message)) {
        e.preventDefault();
        return false;
      }
    });
  });
  
  
  // ============================================================================
  // DATE & TIME INPUTS - Set minimum date to today
  // ============================================================================
  const dateInputs = document.querySelectorAll('input[type="date"]');
  const today = new Date().toISOString().split('T')[0];
  
  dateInputs.forEach(function(input) {
    if (!input.hasAttribute('min')) {
      input.setAttribute('min', today);
    }
  });
  
  
  // ============================================================================
  // STATISTICS ANIMATION - Animate numbers on stat cards
  // ============================================================================
  function animateValue(element, start, end, duration) {
    const range = end - start;
    const increment = range / (duration / 16);
    let current = start;
    
    const timer = setInterval(function() {
      current += increment;
      if ((increment > 0 && current >= end) || (increment < 0 && current <= end)) {
        current = end;
        clearInterval(timer);
      }
      
      // Check if it's a decimal number
      if (end % 1 !== 0) {
        element.textContent = current.toFixed(2);
      } else {
        element.textContent = Math.floor(current);
      }
    }, 16);
  }
  
  // Animate stat values when they come into view
  const statValues = document.querySelectorAll('.card-stat-value');
  const statObserver = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting && !entry.target.dataset.animated) {
        const value = parseFloat(entry.target.textContent.replace(/[^0-9.]/g, ''));
        if (!isNaN(value)) {
          entry.target.dataset.animated = 'true';
          animateValue(entry.target, 0, value, 1000);
        }
      }
    });
  });
  
  statValues.forEach(function(stat) {
    statObserver.observe(stat);
  });
  
  
  // ============================================================================
  // CONSOLE MESSAGE - Developer info
  // ============================================================================
  console.log('%cGym Management System', 'color: #6366f1; font-size: 20px; font-weight: bold;');
  console.log('%cModern gym management with Flask & Oracle DB', 'color: #94a3b8; font-size: 12px;');
  
});


// ============================================================================
// UTILITY FUNCTIONS - Available globally
// ============================================================================

/**
 * Format currency
 */
function formatCurrency(amount) {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'EUR'
  }).format(amount);
}

/**
 * Format date
 */
function formatDate(dateString) {
  const date = new Date(dateString);
  return new Intl.DateTimeFormat('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  }).format(date);
}

/**
 * Show toast notification
 */
function showToast(message, type = 'info') {
  const toastHTML = `
    <div class="alert alert-${type} alert-dismissible fade show animate-slide-down" role="alert" style="position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;">
      <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'danger' ? 'exclamation-circle' : type === 'warning' ? 'exclamation-triangle' : 'info-circle'}"></i>
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  `;
  
  const tempDiv = document.createElement('div');
  tempDiv.innerHTML = toastHTML;
  document.body.appendChild(tempDiv.firstElementChild);
  
  // Auto-remove after 5 seconds
  setTimeout(function() {
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert) {
      if (alert.style.position === 'fixed') {
        const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
        bsAlert.close();
      }
    });
  }, 5000);
}

// Make utility functions available globally
window.formatCurrency = formatCurrency;
window.formatDate = formatDate;
window.showToast = showToast;
