import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { ApiService } from '../../core/services/api';
import { AuthService } from '../../core/services/auth.service';

interface NavItem {
  label: string;
  icon: string;
  route: string;
  badge?: number;
}

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <nav class="sidebar">
      <div class="sidebar__logo">
        <div class="sidebar__logo-icon">🛡️</div>
        <div>
          <div class="sidebar__logo-text">DetectSen</div>
          <div class="sidebar__logo-sub">Admin Console</div>
        </div>
      </div>

      <div class="sidebar__nav">
        <a *ngFor="let item of navItems"
           [routerLink]="item.route"
           routerLinkActive="active"
           class="sidebar__item">
          <span class="sidebar__icon">{{ item.icon }}</span>
          {{ item.label }}
          <span class="sidebar__badge" *ngIf="item.badge">{{ item.badge }}</span>
        </a>
      </div>

      <div class="sidebar__footer">
        <div class="sidebar__user">
          <div class="sidebar__avatar">{{ userInitial }}</div>
          <div>
            <div class="sidebar__user-name">{{ userName }}</div>
            <div class="sidebar__user-role">Administrateur</div>
          </div>
        </div>
        <button class="sidebar__logout" (click)="logout()">
          <span>🚪</span> Déconnexion
        </button>
      </div>
    </nav>
  `,
  styles: [`
    .sidebar__logout {
      width: 100%;
      margin-top: 10px;
      padding: 10px;
      border: none;
      border-radius: 10px;
      background: var(--dark-3);
      color: #78909C;
      font-family: 'Montserrat', sans-serif;
      font-size: 13px;
      font-weight: 500;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: all .2s;
    }
    .sidebar__logout:hover { background: var(--danger); color: #fff; }
  `],
})
export class SidebarComponent implements OnInit {
  alertesBadge = 0;
  userName = 'Admin';

  navItems: NavItem[] = [
    { label: 'Dashboard',       icon: '📊', route: '/dashboard' },
    { label: 'Citoyens',        icon: '👥', route: '/citoyens' },
    { label: 'Actes',           icon: '📄', route: '/actes' },
    { label: 'Documents',       icon: '📁', route: '/documents' },
    { label: 'Analyses IA',     icon: '🤖', route: '/analyses' },
    { label: 'Alertes',         icon: '🚨', route: '/alertes' },
    { label: 'Copilot IA',      icon: '💬', route: '/copilot' },
    { label: 'Centres',         icon: '🏢', route: '/centres' },
    { label: 'Utilisateurs',    icon: '🔐', route: '/utilisateurs' },
    { label: 'Audit Logs',      icon: '📋', route: '/audit' },
    { label: 'Synchronisation', icon: '🔄', route: '/sync' },
  ];

  get userInitial(): string {
    return this.userName.charAt(0).toUpperCase();
  }

  constructor(
    private api: ApiService,
    private auth: AuthService,
    private router: Router,
  ) {}

  ngOnInit(): void {
    this.userName = this.auth.getUserName();
    this.api.getDashboardStats().subscribe({
      next: s => {
        this.alertesBadge = s.alertes_critiques ?? s.fraudes_detectees ?? 0;
        const item = this.navItems.find(i => i.route === '/alertes');
        if (item) item.badge = this.alertesBadge;
      },
      error: () => {},
    });
  }

  logout(): void {
    this.auth.logout();
    this.router.navigate(['/login']);
  }
}
