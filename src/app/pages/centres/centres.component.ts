import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService, Centre } from '../../core/services/api';

@Component({
  selector: 'app-centres',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Centres d'état civil</div>
        <div class="topbar__sub">{{ centres.length }} centres connectés</div>
      </div>
      <div class="topbar__right">
        <button class="btn btn--primary" (click)="openModal()">+ Nouveau centre</button>
      </div>
    </div>

    <div class="page">
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;">
        <div class="card fade-up" *ngFor="let c of centres; let i = index" [class]="'delay-' + (i % 4)">
          <div style="padding:20px;">
            <div style="display:flex;justify-content:space-between;margin-bottom:14px;">
              <div style="width:44px;height:44px;border-radius:12px;background:var(--primary-light);display:flex;align-items:center;justify-content:center;font-size:22px;">🏢</div>
              <div *ngIf="c.taux_fraude != null" class="risk-pill" [class]="riskClass(c.taux_fraude)">{{ c.taux_fraude }}%</div>
            </div>
            <div style="font-weight:700;font-size:15px;">{{ c.nom }}</div>
            <div style="font-size:12px;color:var(--muted);">{{ c.region }} · {{ c.commune }}</div>
            <div class="mono" style="font-size:10px;color:var(--muted);margin-top:4px;">{{ c.code }}</div>
            <div style="margin-top:14px;padding-top:14px;border-top:1px solid var(--border);display:flex;justify-content:space-between;">
              <span style="font-size:12px;color:var(--muted);">Actes</span>
              <span style="font-size:12px;font-weight:700;">{{ c.nb_actes || 0 }}</span>
            </div>
            <div style="display:flex;gap:8px;margin-top:14px;">
              <button class="btn btn--ghost btn--sm" style="flex:1;" (click)="editCentre(c)">✏️ Modifier</button>
              <button class="btn btn--danger btn--sm btn--icon" (click)="deleteCentre(c.id)">🗑</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="modal-backdrop" *ngIf="showModal" (click)="closeModal()">
      <div class="modal" (click)="$event.stopPropagation()">
        <div class="modal__title">{{ editing ? 'Modifier' : 'Nouveau' }} centre</div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-top:16px;">
          <div class="form-group" style="grid-column:span 2;">
            <label>NOM</label>
            <input class="form-control" [(ngModel)]="form.nom" />
          </div>
          <div class="form-group"><label>CODE</label><input class="form-control" [(ngModel)]="form.code" /></div>
          <div class="form-group"><label>TÉLÉPHONE</label><input class="form-control" [(ngModel)]="form.telephone" /></div>
          <div class="form-group">
            <label>RÉGION</label>
            <select class="form-control" [(ngModel)]="form.region">
              <option *ngFor="let r of regions" [value]="r.id">{{ r.nom }}</option>
            </select>
          </div>
          <div class="form-group">
            <label>COMMUNE</label>
            <select class="form-control" [(ngModel)]="form.commune">
              <option *ngFor="let c of communes" [value]="c.id">{{ c.nom }}</option>
            </select>
          </div>
          <div class="form-group" style="grid-column:span 2;">
            <label>ADRESSE</label>
            <input class="form-control" [(ngModel)]="form.adresse" />
          </div>
        </div>
        <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;">
          <button class="btn btn--ghost" (click)="closeModal()">Annuler</button>
          <button class="btn btn--primary" (click)="save()" [disabled]="saving">{{ saving ? '...' : 'Enregistrer' }}</button>
        </div>
      </div>
    </div>
  `,
})
export class CentresComponent implements OnInit {
  centres: Centre[] = [];
  regions: { id: string; nom: string }[] = [];
  communes: { id: string; nom: string }[] = [];
  showModal = false;
  saving = false;
  editing: Centre | null = null;
  form: Partial<Centre> = {};

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.api.getCentres().subscribe(c => this.centres = c);
    this.api.getRegions().subscribe(r => this.regions = r);
    this.api.getCommunes().subscribe(c => this.communes = c);
  }

  riskClass(t: number): string {
    return t >= 70 ? 'risk-pill risk-pill--high' : t >= 40 ? 'risk-pill risk-pill--medium' : 'risk-pill risk-pill--low';
  }

  openModal(): void { this.showModal = true; this.editing = null; this.form = {}; }
  editCentre(c: Centre): void { this.editing = c; this.form = { ...c }; this.showModal = true; }
  closeModal(): void { this.showModal = false; }

  save(): void {
    this.saving = true;
    const obs = this.editing
      ? this.api.updateCentre(this.editing.id, this.form)
      : this.api.createCentre(this.form);
    obs.subscribe({
      next: () => { this.saving = false; this.closeModal(); this.api.getCentres().subscribe(c => this.centres = c); },
      error: () => { this.saving = false; },
    });
  }

  deleteCentre(id: string): void {
    if (confirm('Supprimer ce centre ?')) {
      this.api.deleteCentre(id).subscribe(() => this.api.getCentres().subscribe(c => this.centres = c));
    }
  }
}
