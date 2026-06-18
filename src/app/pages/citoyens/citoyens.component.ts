import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService, Citoyen, Acte } from '../../core/services/api';

@Component({
  selector: 'app-citoyens',
  standalone: true,
  imports: [CommonModule, FormsModule, DatePipe],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Citoyens</div>
        <div class="topbar__sub">{{ citoyens.length }} citoyens enregistrés</div>
      </div>
    </div>

    <div class="page">
      <div class="card fade-up" style="margin-bottom:20px;">
        <div class="card__body">
          <div style="display:grid;grid-template-columns:2fr 1fr 1fr auto;gap:12px;align-items:end;">
            <div class="form-group" style="margin:0;">
              <label>RECHERCHE PAR NOM</label>
              <input class="form-control" [(ngModel)]="searchNom" placeholder="Nom ou prénom..." (keyup.enter)="search()" />
            </div>
            <div class="form-group" style="margin:0;">
              <label>DATE NAISSANCE</label>
              <input class="form-control" type="date" [(ngModel)]="searchDate" />
            </div>
            <div class="form-group" style="margin:0;">
              <label>N° IDENTIFICATION</label>
              <input class="form-control" [(ngModel)]="searchNumero" placeholder="SN..." />
            </div>
            <button class="btn btn--primary" (click)="search()">🔍 Rechercher</button>
          </div>
        </div>
      </div>

      <div class="card fade-up delay-1">
        <div class="card__body" style="padding:0;">
          <table class="ds-table">
            <thead>
              <tr>
                <th>Nom</th><th>Prénom</th><th>Date naissance</th><th>N° ID</th><th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let c of citoyens">
                <td style="font-weight:600;">{{ c.nom }}</td>
                <td>{{ c.prenom }}</td>
                <td>{{ c.date_naissance | date:'dd/MM/yyyy' }}</td>
                <td class="mono" style="font-size:11px;">{{ c.numero_identification }}</td>
                <td><button class="btn btn--ghost btn--sm" (click)="voirFiche(c)">Voir →</button></td>
              </tr>
              <tr *ngIf="citoyens.length === 0">
                <td colspan="5" style="text-align:center;padding:32px;color:var(--muted);">Aucun citoyen trouvé</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="modal-backdrop" *ngIf="selected" (click)="selected=null">
      <div class="modal" style="max-width:560px;" (click)="$event.stopPropagation()">
        <div class="modal__title">Fiche citoyen</div>
        <div class="modal__sub">{{ selected!.nom }} {{ selected!.prenom }}</div>

        <div style="display:grid;gap:14px;margin-top:16px;">
          <div><span style="color:var(--muted);font-size:12px;">DATE DE NAISSANCE</span><br><strong>{{ selected!.date_naissance | date:'dd/MM/yyyy' }}</strong></div>
          <div><span style="color:var(--muted);font-size:12px;">N° IDENTIFICATION</span><br><strong class="mono">{{ selected!.numero_identification }}</strong></div>

          <div>
            <span style="color:var(--muted);font-size:12px;">ACTES ASSOCIÉS</span>
            <div style="margin-top:8px;display:flex;flex-wrap:gap:8px;">
              <span class="badge badge--blue" *ngFor="let a of actesAssocies">{{ typeLabel(a.type_acte) }}</span>
              <span *ngIf="actesAssocies.length===0" style="color:var(--muted);font-size:13px;">Aucun acte</span>
            </div>
          </div>

          <div>
            <span style="color:var(--muted);font-size:12px;">HISTORIQUE IA</span>
            <div style="margin-top:6px;">
              <span class="badge badge--green" *ngIf="!hasAnomalie">Aucune anomalie</span>
              <span class="badge badge--red" *ngIf="hasAnomalie">Anomalie détectée</span>
            </div>
          </div>
        </div>

        <div style="display:flex;justify-content:flex-end;margin-top:24px;">
          <button class="btn btn--ghost" (click)="selected=null">Fermer</button>
        </div>
      </div>
    </div>
  `,
})
export class CitoyensComponent implements OnInit {
  citoyens: Citoyen[] = [];
  searchNom = '';
  searchDate = '';
  searchNumero = '';
  selected: Citoyen | null = null;
  actesAssocies: Acte[] = [];
  hasAnomalie = false;

  constructor(private api: ApiService) {}

  ngOnInit(): void { this.load(); }

  load(params?: Record<string, string>): void {
    this.api.getCitoyens(params).subscribe({
      next: res => {
        this.citoyens = Array.isArray(res) ? res : (res.results ?? []);
      },
      error: () => { this.citoyens = []; },
    });
  }

  search(): void {
    const p: Record<string, string> = {};
    if (this.searchNom) p['nom'] = this.searchNom;
    if (this.searchDate) p['date_naissance'] = this.searchDate;
    if (this.searchNumero) p['numero_identification'] = this.searchNumero;
    this.load(p);
  }

  voirFiche(c: Citoyen): void {
    this.api.getCitoyen(c.id).subscribe({
      next: detail => {
        this.selected = detail;
        this.actesAssocies = detail.actes ?? [];
        this.hasAnomalie = this.actesAssocies.some(a => a.statut === 'SUSPECT' || a.statut === 'FRAUDE');
      },
      error: () => { this.selected = c; this.actesAssocies = []; },
    });
  }

  typeLabel(t: string): string {
    return { NAISSANCE: 'Naissance', MARIAGE: 'Mariage', DECES: 'Décès', DIVORCE: 'Divorce' }[t] ?? t;
  }
}
