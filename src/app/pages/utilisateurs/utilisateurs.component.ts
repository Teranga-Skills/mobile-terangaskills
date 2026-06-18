import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService, Utilisateur } from '../../core/services/api';

@Component({
  selector: 'app-utilisateurs',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Utilisateurs</div>
        <div class="topbar__sub">Gestion des agents et administrateurs</div>
      </div>
      <div class="topbar__right">
        <button class="btn btn--primary" (click)="openModal()">+ Créer agent</button>
      </div>
    </div>

    <div class="page">
      <div class="card fade-up">
        <div class="card__body" style="padding:0;">
          <table class="ds-table">
            <thead>
              <tr><th>Nom</th><th>Email</th><th>Rôle</th><th>Centre</th><th>Statut</th><th>Actions</th></tr>
            </thead>
            <tbody>
              <tr *ngFor="let u of users">
                <td style="font-weight:600;">{{ u.nom }}</td>
                <td>{{ u.email }}</td>
                <td><span class="badge" [class]="u.role==='ADMIN' ? 'badge--blue' : 'badge--gray'">{{ u.role }}</span></td>
                <td style="color:var(--muted);">{{ u.centre_nom || '—' }}</td>
                <td><span class="badge" [class]="u.is_active ? 'badge--green' : 'badge--red'">{{ u.is_active ? 'Actif' : 'Désactivé' }}</span></td>
                <td>
                  <button class="btn btn--ghost btn--sm" (click)="editUser(u)">Modifier</button>
                  <button class="btn btn--danger btn--sm" *ngIf="u.is_active" (click)="desactiver(u)">Désactiver</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="modal-backdrop" *ngIf="showModal" (click)="closeModal()">
      <div class="modal" (click)="$event.stopPropagation()">
        <div class="modal__title">{{ editing ? 'Modifier' : 'Créer' }} utilisateur</div>
        <div style="display:grid;gap:14px;margin-top:16px;">
          <div class="form-group"><label>NOM</label><input class="form-control" [(ngModel)]="form.nom" /></div>
          <div class="form-group"><label>EMAIL</label><input class="form-control" type="email" [(ngModel)]="form.email" /></div>
          <div class="form-group">
            <label>RÔLE</label>
            <select class="form-control" [(ngModel)]="form.role">
              <option value="ADMIN">ADMIN</option>
              <option value="AGENT">AGENT</option>
            </select>
          </div>
        </div>
        <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;">
          <button class="btn btn--ghost" (click)="closeModal()">Annuler</button>
          <button class="btn btn--primary" (click)="save()" [disabled]="saving">Enregistrer</button>
        </div>
      </div>
    </div>
  `,
})
export class UtilisateursComponent implements OnInit {
  users: Utilisateur[] = [];
  showModal = false;
  saving = false;
  editing: Utilisateur | null = null;
  form: Partial<Utilisateur> = { role: 'AGENT' };

  constructor(private api: ApiService) {}

  ngOnInit(): void { this.load(); }

  load(): void {
    this.api.getUsers().subscribe(u => this.users = u);
  }

  openModal(): void { this.showModal = true; this.editing = null; this.form = { role: 'AGENT' }; }
  editUser(u: Utilisateur): void { this.editing = u; this.form = { ...u }; this.showModal = true; }
  closeModal(): void { this.showModal = false; }

  save(): void {
    this.saving = true;
    const obs = this.editing
      ? this.api.updateUser(this.editing.id, this.form)
      : this.api.createUser(this.form);
    obs.subscribe({ next: () => { this.saving = false; this.closeModal(); this.load(); }, error: () => { this.saving = false; } });
  }

  desactiver(u: Utilisateur): void {
    if (confirm(`Désactiver ${u.nom} ?`)) {
      this.api.updateUser(u.id, { is_active: false }).subscribe(() => this.load());
    }
  }
}
