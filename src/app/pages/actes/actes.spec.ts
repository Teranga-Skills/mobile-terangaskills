import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ApiService, Acte } from '../../core/services/api';

@Component({
  selector: 'app-actes',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule, DatePipe],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Actes d'état civil</div>
        <div class="topbar__sub">Gestion complète · {{ totalCount }} actes</div>
      </div>
      <div class="topbar__right">
        <button class="btn btn--primary" (click)="openCreate()">+ Nouvel acte</button>
      </div>
    </div>

    <div class="page">

      <!-- FILTERS BAR -->
      <div class="card mb-6 fade-up">
        <div class="card__body" style="padding:16px 20px;">
          <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
            <div class="search-bar" style="min-width:260px;">
              <span>🔍</span>
              <input [(ngModel)]="filters.search" placeholder="Rechercher un acte, citoyen..."
                     (input)="onSearch()" />
            </div>

            <select class="form-control" style="width:auto;" [(ngModel)]="filters.type_acte" (change)="loadActes()">
              <option value="">Tous les types</option>
              <option value="NAISSANCE">Naissance</option>
              <option value="MARIAGE">Mariage</option>
              <option value="DECES">Décès</option>
              <option value="DIVORCE">Divorce</option>
            </select>

            <select class="form-control" style="width:auto;" [(ngModel)]="filters.statut" (change)="loadActes()">
              <option value="">Tous les statuts</option>
              <option value="EN_ATTENTE">En attente</option>
              <option value="VALIDE">Validé</option>
              <option value="SUSPECT">Suspect</option>
              <option value="FRAUDE">Fraude</option>
            </select>

            <select class="form-control" style="width:auto;" [(ngModel)]="filters.centre" (change)="loadActes()">
              <option value="">Tous les centres</option>
              <option *ngFor="let c of centres" [value]="c.id">{{ c.nom }}</option>
            </select>

            <button class="btn btn--ghost btn--sm" (click)="resetFilters()">Réinitialiser</button>

            <div style="margin-left:auto; display:flex; gap:8px;">
              <button class="btn btn--ghost btn--sm" (click)="viewMode='table'"
                      [style.background]="viewMode==='table' ? 'var(--primary-light)' : ''">☰ Tableau</button>
              <button class="btn btn--ghost btn--sm" (click)="viewMode='cards'"
                      [style.background]="viewMode==='cards' ? 'var(--primary-light)' : ''">⊞ Cartes</button>
            </div>
          </div>
        </div>
      </div>

      <!-- STATUS TABS -->
      <div style="display:flex; gap:8px; margin-bottom:18px;">
        <button *ngFor="let tab of statusTabs"
                class="btn btn--sm"
                [class]="activeTab === tab.key ? 'btn--primary' : 'btn--ghost'"
                (click)="setTab(tab.key)">
          {{ tab.label }} <span style="opacity:.7;font-size:11px;">({{ tab.count }})</span>
        </button>
      </div>

      <!-- TABLE VIEW -->
      <div class="card fade-up" *ngIf="viewMode === 'table'">
        <div class="card__body" style="padding:0;">
          <table class="ds-table" *ngIf="actes.length > 0; else emptyState">
            <thead>
              <tr>
                <th>N° Acte</th>
                <th>Type</th>
                <th>Citoyen</th>
                <th>Centre</th>
                <th>Score IA</th>
                <th>Statut</th>
                <th>Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let acte of actes">
                <td class="mono" style="font-size:11px;color:var(--muted);">{{ acte.numero_acte }}</td>
                <td>
                  <span class="badge badge--blue">{{ typeEmoji(acte.type_acte) }} {{ typeLabel(acte.type_acte) }}</span>
                </td>
                <td style="font-weight:600;">{{ acte.citoyen_nom || '—' }}</td>
                <td style="color:var(--muted);">{{ acte.centre_nom || '—' }}</td>
                <td>
                  <div *ngIf="acte.fraud_score !== undefined" style="display:flex;align-items:center;gap:8px;">
                    <div class="risk-pill" [class]="riskPillClass(acte.fraud_score)">{{ acte.fraud_score }}</div>
                    <span style="font-size:10px;color:var(--muted);">{{ acte.risk_level }}</span>
                  </div>
                  <span *ngIf="acte.fraud_score === undefined" style="color:var(--muted);font-size:12px;">—</span>
                </td>
                <td><span class="badge" [class]="statutBadge(acte.statut)">{{ statutLabel(acte.statut) }}</span></td>
                <td style="color:var(--muted);font-size:12px;">{{ acte.date_creation | date:'dd/MM/yyyy' }}</td>
                <td>
                  <div style="display:flex;gap:6px;">
                    <button class="btn btn--ghost btn--sm btn--icon" [routerLink]="['/actes', acte.id]" data-tooltip="Voir détail">👁</button>
                    <button class="btn btn--success btn--sm" (click)="valider(acte)" *ngIf="acte.statut === 'EN_ATTENTE'">✓ Valider</button>
                    <button class="btn btn--danger btn--sm" (click)="marquerFraude(acte)" *ngIf="acte.statut !== 'FRAUDE'">⚠ Fraude</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>

          <ng-template #emptyState>
            <div class="empty-state">
              <div class="empty-state__icon">📄</div>
              <div class="empty-state__text">Aucun acte trouvé</div>
              <div class="empty-state__sub">Essayez de modifier vos filtres</div>
            </div>
          </ng-template>
        </div>

        <!-- PAGINATION -->
        <div style="padding:14px 20px; border-top:1px solid var(--border); display:flex; align-items:center; justify-content:space-between;">
          <span style="font-size:12px;color:var(--muted);">{{ actes.length }} actes affichés sur {{ totalCount }}</span>
          <div style="display:flex;gap:6px;">
            <button class="btn btn--ghost btn--sm" [disabled]="page<=1" (click)="page=page-1;loadActes()">← Précédent</button>
            <span style="padding:7px 12px;font-size:13px;font-weight:600;">{{ page }}</span>
            <button class="btn btn--ghost btn--sm" (click)="page=page+1;loadActes()">Suivant →</button>
          </div>
        </div>
      </div>

      <!-- CARDS VIEW -->
      <div *ngIf="viewMode === 'cards'"
           style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;" class="fade-up">
        <div class="card" *ngFor="let acte of actes"
             style="cursor:pointer;transition:transform .2s,box-shadow .2s;"
             (mouseenter)="$any($event.target).closest('.card').style.transform='translateY(-3px)'"
             (mouseleave)="$any($event.target).closest('.card').style.transform='translateY(0)'">
          <div style="padding:18px;">
            <div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:12px;">
              <span class="badge" [class]="statutBadge(acte.statut)">{{ statutLabel(acte.statut) }}</span>
              <div class="risk-pill" *ngIf="acte.fraud_score" [class]="riskPillClass(acte.fraud_score)">{{ acte.fraud_score }}</div>
            </div>
            <div style="font-size:20px;margin-bottom:4px;">{{ typeEmoji(acte.type_acte) }}</div>
            <div style="font-weight:700;font-size:14px;">{{ typeLabel(acte.type_acte) }}</div>
            <div style="font-size:13px;color:var(--muted);margin-top:2px;">{{ acte.citoyen_nom || 'Citoyen' }}</div>
            <div style="margin-top:12px;padding-top:12px;border-top:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
              <span class="mono" style="font-size:10px;color:var(--muted);">{{ acte.numero_acte }}</span>
              <a [routerLink]="['/actes', acte.id]" class="btn btn--ghost btn--sm">Voir →</a>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- MODAL CREATE ACTE -->
    <div class="modal-backdrop" *ngIf="showModal" (click)="closeModal()">
      <div class="modal" (click)="$event.stopPropagation()">
        <div class="modal__title">Créer un nouvel acte</div>
        <div class="modal__sub">Remplissez les informations de l'acte d'état civil</div>

        <div class="form-group">
          <label>TYPE D'ACTE</label>
          <select class="form-control" [(ngModel)]="newActe.type_acte">
            <option value="NAISSANCE">🍼 Acte de naissance</option>
            <option value="MARIAGE">💍 Acte de mariage</option>
            <option value="DECES">🕊️ Acte de décès</option>
            <option value="DIVORCE">📋 Acte de divorce</option>
          </select>
        </div>

        <div class="form-group">
          <label>CITOYEN (ID ou recherche)</label>
          <input class="form-control" [(ngModel)]="newActe.citoyen" placeholder="UUID du citoyen..." />
        </div>

        <div class="form-group">
          <label>CENTRE D'ÉTAT CIVIL</label>
          <select class="form-control" [(ngModel)]="newActe.centre">
            <option value="">Sélectionner un centre...</option>
            <option *ngFor="let c of centres" [value]="c.id">{{ c.nom }}</option>
          </select>
        </div>

        <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:24px;">
          <button class="btn btn--ghost" (click)="closeModal()">Annuler</button>
          <button class="btn btn--primary" (click)="createActe()" [disabled]="creating">
            {{ creating ? '⏳ Création...' : '✓ Créer l\'acte' }}
          </button>
        </div>
      </div>
    </div>
  `
})
export class ActesComponent implements OnInit {
  actes: Acte[] = [];
  centres: any[] = [];
  totalCount = 0;
  page = 1;
  viewMode: 'table' | 'cards' = 'table';
  showModal = false;
  creating = false;
  activeTab = '';
  filters = { search: '', type_acte: '', statut: '', centre: '' };
  newActe = { type_acte: 'NAISSANCE', citoyen: '', centre: '' };

  statusTabs = [
    { key: '', label: 'Tous', count: 0 },
    { key: 'EN_ATTENTE', label: '⏳ En attente', count: 0 },
    { key: 'VALIDE', label: '✅ Validés', count: 0 },
    { key: 'SUSPECT', label: '⚠ Suspects', count: 0 },
    { key: 'FRAUDE', label: '🚨 Fraudes', count: 0 },
  ];

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.loadActes();
    this.api.getCentres().subscribe(c => this.centres = c);
  }

  loadActes() {
    const params: any = { page: this.page, ...this.filters };
    if (this.activeTab) params.statut = this.activeTab;
    this.api.getActes(params).subscribe((res: any) => {
      this.actes = Array.isArray(res) ? res : (res.results || []);
      this.totalCount = res.count || this.actes.length;
    });
  }

  onSearch() { clearTimeout((this as any)._t); (this as any)._t = setTimeout(() => this.loadActes(), 400); }
  setTab(key: string) { this.activeTab = key; this.filters.statut = ''; this.loadActes(); }
  resetFilters() { this.filters = { search:'', type_acte:'', statut:'', centre:'' }; this.activeTab = ''; this.loadActes(); }

  openCreate() { this.showModal = true; }
  closeModal() { this.showModal = false; }

  createActe() {
    this.creating = true;
    this.api.createActe(this.newActe).subscribe({
      next: () => { this.creating = false; this.closeModal(); this.loadActes(); },
      error: () => { this.creating = false; }
    });
  }

  valider(acte: Acte) { this.api.updateStatutActe(acte.id, 'VALIDE').subscribe(() => this.loadActes()); }
  marquerFraude(acte: Acte) { this.api.updateStatutActe(acte.id, 'FRAUDE').subscribe(() => this.loadActes()); }

  typeLabel(t: string) { return {NAISSANCE:'Naissance',MARIAGE:'Mariage',DECES:'Décès',DIVORCE:'Divorce'}[t] ?? t; }
  typeEmoji(t: string) { return {NAISSANCE:'🍼',MARIAGE:'💍',DECES:'🕊️',DIVORCE:'📋'}[t] ?? '📄'; }
  statutLabel(s: string) { return {EN_ATTENTE:'En attente',VALIDE:'Validé',SUSPECT:'Suspect',FRAUDE:'Fraude'}[s] ?? s; }
  statutBadge(s: string) { return {EN_ATTENTE:'badge--orange',VALIDE:'badge--green',SUSPECT:'badge--red',FRAUDE:'badge--red'}[s] ?? 'badge--gray'; }
  riskPillClass(score: number) { return score >= 70 ? 'risk-pill risk-pill--high' : score >= 40 ? 'risk-pill risk-pill--medium' : 'risk-pill risk-pill--low'; }
}