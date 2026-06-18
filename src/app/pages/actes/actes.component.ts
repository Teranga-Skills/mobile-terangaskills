import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { ApiService, Acte } from '../../core/services/api';

@Component({
  selector: 'app-actes',
  standalone: true,
  imports: [CommonModule, FormsModule, DatePipe, RouterModule],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Actes d'état civil</div>
        <div class="topbar__sub">Gestion et validation des actes</div>
      </div>
    </div>

    <div class="page">
      <div class="card fade-up" style="margin-bottom:20px;">
        <div class="card__body">
          <div style="display:flex;gap:12px;flex-wrap:wrap;">
            <select class="form-control" style="width:auto;" [(ngModel)]="filterStatut" (change)="load()">
              <option value="">Tous statuts</option>
              <option value="VALIDE">Valide</option>
              <option value="SUSPECT">Suspect</option>
              <option value="FRAUDE">Fraude</option>
              <option value="EN_ATTENTE">En attente</option>
            </select>
            <input class="form-control" style="width:200px;" [(ngModel)]="filterCentre" placeholder="Centre..." (keyup.enter)="load()" />
            <button class="btn btn--ghost" (click)="load()">Filtrer</button>
          </div>
        </div>
      </div>

      <div class="card fade-up delay-1">
        <div class="card__body" style="padding:0;">
          <table class="ds-table">
            <thead>
              <tr>
                <th>Numéro acte</th><th>Citoyen</th><th>Centre</th><th>Date</th><th>Statut IA</th><th>Score</th><th></th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let a of actes">
                <td class="mono" style="font-weight:600;">{{ a.numero_acte }}</td>
                <td>{{ a.citoyen_nom || '—' }}</td>
                <td style="color:var(--muted);">{{ a.centre_nom || a.centre }}</td>
                <td>{{ a.date_creation | date:'dd/MM/yyyy' }}</td>
                <td><span class="badge" [class]="statutClass(a.statut)">{{ a.statut }}</span></td>
                <td>
                  <span *ngIf="a.fraud_score" class="risk-pill" [class]="riskClass(a.fraud_score)">{{ a.fraud_score }}%</span>
                  <span *ngIf="!a.fraud_score" style="color:var(--muted);">—</span>
                </td>
                <td><a class="btn btn--ghost btn--sm" [routerLink]="['/actes', a.id]">Détail →</a></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `,
})
export class ActesComponent implements OnInit {
  actes: Acte[] = [];
  filterStatut = '';
  filterCentre = '';

  constructor(private api: ApiService) {}

  ngOnInit(): void { this.load(); }

  load(): void {
    const p: Record<string, string> = {};
    if (this.filterStatut) p['statut'] = this.filterStatut;
    if (this.filterCentre) p['centre'] = this.filterCentre;
    this.api.getActes(p).subscribe({
      next: res => { this.actes = Array.isArray(res) ? res : (res.results ?? []); },
      error: () => { this.actes = []; },
    });
  }

  statutClass(s: string): string {
    return { VALIDE: 'badge--green', SUSPECT: 'badge--orange', FRAUDE: 'badge--red', EN_ATTENTE: 'badge--gray' }[s] ?? 'badge--gray';
  }

  riskClass(score: number): string {
    return score >= 70 ? 'risk-pill risk-pill--high' : score >= 40 ? 'risk-pill risk-pill--medium' : 'risk-pill risk-pill--low';
  }
}
