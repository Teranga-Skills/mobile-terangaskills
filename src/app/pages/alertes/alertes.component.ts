import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { ApiService, Alerte } from '../../core/services/api';

@Component({
  selector: 'app-alertes',
  standalone: true,
  imports: [CommonModule, FormsModule, DatePipe, RouterModule],
  template: `
    <div class="topbar">
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="pulse-dot"></span>
        <div>
          <div class="topbar__title">Alertes fraude</div>
          <div class="topbar__sub">Surveillance en temps réel · IA active</div>
        </div>
      </div>
      <div class="topbar__right">
        <select class="form-control" style="width:auto;" [(ngModel)]="filterSeverite" (change)="applyFilter()">
          <option value="">Toutes sévérités</option>
          <option value="CRITIQUE">🔴 Critique</option>
          <option value="HIGH">Risque élevé</option>
          <option value="MEDIUM">Risque moyen</option>
        </select>
      </div>
    </div>

    <div class="page">
      <div class="stat-grid" style="grid-template-columns:repeat(4,1fr);margin-bottom:22px;">
        <div class="stat-card red fade-up">
          <div class="stat-card__icon">🚨</div>
          <div class="stat-card__value">{{ alertes.length }}</div>
          <div class="stat-card__label">Total alertes</div>
        </div>
        <div class="stat-card red fade-up delay-1">
          <div class="stat-card__icon">🔴</div>
          <div class="stat-card__value">{{ countSeverite('CRITIQUE') + countSeverite('HIGH') }}</div>
          <div class="stat-card__label">Critiques</div>
        </div>
        <div class="stat-card orange fade-up delay-2">
          <div class="stat-card__icon">⏳</div>
          <div class="stat-card__value">{{ countNonResolu() }}</div>
          <div class="stat-card__label">En cours</div>
        </div>
        <div class="stat-card green fade-up delay-3">
          <div class="stat-card__icon">✓</div>
          <div class="stat-card__value">{{ countResolu() }}</div>
          <div class="stat-card__label">Résolues</div>
        </div>
      </div>

      <div style="display:grid;gap:14px;">
        <div class="card fade-up" *ngFor="let a of filtered">
          <div class="card__body" style="display:flex;align-items:center;gap:16px;">
            <div class="risk-pill" [class]="severiteClass(a.severite)">{{ a.fraud_score ?? '!' }}</div>
            <div style="flex:1;">
              <div style="font-weight:700;font-size:15px;">ALERTE FRAUDE — {{ a.numero_acte || a.acte }}</div>
              <div style="font-size:13px;color:var(--muted);margin-top:4px;">
                Type: <strong>{{ a.type }}</strong> · Sévérité: <span class="badge" [class]="severiteBadge(a.severite)">{{ a.severite }}</span>
              </div>
              <div style="font-size:12px;color:var(--muted);margin-top:4px;">
                {{ a.centre_nom || a.centre }} · {{ a.date | date:'dd/MM/yyyy' }}
              </div>
            </div>
            <div style="display:flex;gap:8px;">
              <a class="btn btn--ghost btn--sm" [routerLink]="['/actes', a.acte]">Voir acte</a>
              <button class="btn btn--success btn--sm" *ngIf="!a.resolu" (click)="resoudre(a)">Résoudre</button>
              <span class="badge badge--green" *ngIf="a.resolu">Résolu</span>
            </div>
          </div>
        </div>
        <div *ngIf="filtered.length===0" class="card" style="text-align:center;padding:40px;color:var(--muted);">
          Aucune alerte active
        </div>
      </div>
    </div>
  `,
})
export class AlertesComponent implements OnInit {
  alertes: Alerte[] = [];
  filtered: Alerte[] = [];
  filterSeverite = '';

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.api.getAlertes().subscribe({
      next: a => { this.alertes = a; this.applyFilter(); },
      error: () => { this.alertes = []; this.filtered = []; },
    });
  }

  applyFilter(): void {
    this.filtered = this.alertes.filter(a => !this.filterSeverite || a.severite === this.filterSeverite);
  }

  countSeverite(s: string): number { return this.alertes.filter(a => a.severite === s).length; }
  countResolu(): number { return this.alertes.filter(a => a.resolu).length; }
  countNonResolu(): number { return this.alertes.filter(a => !a.resolu).length; }

  resoudre(a: Alerte): void {
    this.api.resoudreAlerte(a.id).subscribe(updated => {
      a.resolu = updated.resolu;
    });
  }

  severiteClass(s: string): string {
    return s === 'CRITIQUE' || s === 'HIGH' ? 'risk-pill risk-pill--high' : s === 'MEDIUM' ? 'risk-pill risk-pill--medium' : 'risk-pill risk-pill--low';
  }

  severiteBadge(s: string): string {
    return s === 'CRITIQUE' || s === 'HIGH' ? 'badge--red' : s === 'MEDIUM' ? 'badge--orange' : 'badge--green';
  }
}
