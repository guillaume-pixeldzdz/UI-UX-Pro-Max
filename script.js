/* Punto Amor — interactions */

// Topbar : passe en mode "scrolled" après le hero
const topbar = document.getElementById('topbar');
const onScroll = () => {
  if (window.scrollY > 60) topbar.classList.add('scrolled');
  else topbar.classList.remove('scrolled');
};
window.addEventListener('scroll', onScroll, { passive: true });
onScroll();

// Menu plein écran
const menuToggle = document.getElementById('menuToggle');
const navOverlay = document.getElementById('navOverlay');
const setMenu = (open) => {
  menuToggle.classList.toggle('open', open);
  navOverlay.classList.toggle('open', open);
  menuToggle.setAttribute('aria-expanded', String(open));
  navOverlay.setAttribute('aria-hidden', String(!open));
  document.body.style.overflow = open ? 'hidden' : '';
};
menuToggle.addEventListener('click', () => setMenu(!navOverlay.classList.contains('open')));
navOverlay.querySelectorAll('a').forEach(a =>
  a.addEventListener('click', () => setMenu(false))
);
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && navOverlay.classList.contains('open')) setMenu(false);
});

// Reveal au scroll (IntersectionObserver)
const io = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      e.target.classList.add('visible');
      io.unobserve(e.target);
    }
  });
}, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
document.querySelectorAll('.reveal').forEach(el => io.observe(el));

// Date minimale = aujourd'hui
const dateInput = document.getElementById('r-date');
if (dateInput) {
  const today = new Date().toISOString().split('T')[0];
  dateInput.min = today;
}
