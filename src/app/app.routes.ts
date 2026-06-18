import { Routes } from '@angular/router';
import { authGuard, loginGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [loginGuard],
    loadComponent: () => import('./pages/login/login.component').then(m => m.LoginComponent),
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () => import('./shell/shell.component').then(m => m.ShellComponent),
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard',    loadComponent: () => import('./pages/dashboard/dashboard.component').then(m => m.DashboardComponent) },
      { path: 'citoyens',     loadComponent: () => import('./pages/citoyens/citoyens.component').then(m => m.CitoyensComponent) },
      { path: 'actes',        loadComponent: () => import('./pages/actes/actes.component').then(m => m.ActesComponent) },
      { path: 'actes/:id',    loadComponent: () => import('./pages/actes/acte-detail.component').then(m => m.ActeDetailComponent) },
      { path: 'documents',    loadComponent: () => import('./pages/documents/documents.component').then(m => m.DocumentsComponent) },
      { path: 'analyses',     loadComponent: () => import('./pages/analyses/analyses.component').then(m => m.AnalysesComponent) },
      { path: 'alertes',      loadComponent: () => import('./pages/alertes/alertes.component').then(m => m.AlertesComponent) },
      { path: 'copilot',      loadComponent: () => import('./pages/copilot/copilot.component').then(m => m.CopilotComponent) },
      { path: 'centres',      loadComponent: () => import('./pages/centres/centres.component').then(m => m.CentresComponent) },
      { path: 'utilisateurs', loadComponent: () => import('./pages/utilisateurs/utilisateurs.component').then(m => m.UtilisateursComponent) },
      { path: 'audit',        loadComponent: () => import('./pages/audit/audit.component').then(m => m.AuditComponent) },
      { path: 'sync',         loadComponent: () => import('./pages/sync/sync.component').then(m => m.SyncComponent) },
    ],
  },
  { path: '**', redirectTo: 'dashboard' },
];
