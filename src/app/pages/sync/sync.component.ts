import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { ApiService, SyncStatus } from '../../core/services/api';

@Component({
  selector: 'app-sync',
  standalone: true,
  imports: [CommonModule, DatePipe],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Synchronisation Offline</div>
        <div class="topbar__sub">État de synchronisation des centres terrain</div>
      </div>
      <div class="topbar__right">
        <button class="btn btn--ghost btn--sm" (click)="refresh()">🔄 Actualiser</button>
      </div>
    </div>

    <div class="page">
      <div class="card fade-up">
        <div class="card__body" style="padding:0;">
          <table class="ds-table">
            <thead>
              <tr><th>Centre</th><th>Dernière synchro</th><th>Statut</th></tr>
            </thead>
            <tbody>
              <tr *ngFor="let s of statuses">
                <td style="font-weight:600;">{{ s.centre_nom || s.centre }}</td>
                <td style="color:var(--muted);">{{ s.derniere_synchro | date:'dd/MM/yyyy HH:mm' }}</td>
                <td><span class="badge" [class]="statutClass(s.statut)">{{ s.statut }}</span></td>
              </tr>
              <tr *ngIf="statuses.length===0">
                <td colspan="3" style="text-align:center;padding:32px;color:var(--muted);">Aucune donnée de synchronisation</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `,
})
export class SyncComponent implements OnInit {
  statuses: SyncStatus[] = [];

  constructor(private api: ApiService) {}

  ngOnInit(): void { this.refresh(); }

  refresh(): void {
    this.api.getSyncStatus().subscribe({
      next: s => this.statuses = Array.isArray(s) ? s : [],
      error: () => { this.statuses = []; },
    });
  }

  statutClass(s: string): string {
    return { SYNCED: 'badge--green', PENDING: 'badge--orange', ERROR: 'badge--red' }[s] ?? 'badge--gray';
  }
}
