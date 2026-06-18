import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { ApiService, Document } from '../../core/services/api';

@Component({
  selector: 'app-documents',
  standalone: true,
  imports: [CommonModule, DatePipe],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Documents</div>
        <div class="topbar__sub">{{ documents.length }} documents archivés</div>
      </div>
    </div>

    <div class="page">
      <div class="card fade-up">
        <div class="card__body" style="padding:0;">
          <table class="ds-table">
            <thead>
              <tr><th>ID</th><th>Acte</th><th>Fichier</th><th>Date upload</th><th>Actions</th></tr>
            </thead>
            <tbody>
              <tr *ngFor="let d of documents">
                <td class="mono" style="font-size:11px;">{{ d.id | slice:0:8 }}...</td>
                <td class="mono">{{ d.acte | slice:0:8 }}...</td>
                <td><a [href]="d.fichier" target="_blank" class="btn btn--ghost btn--sm">📄 Voir</a></td>
                <td style="color:var(--muted);">{{ d.created_at | date:'dd/MM/yyyy HH:mm' }}</td>
                <td><button class="btn btn--danger btn--sm" (click)="supprimer(d.id)">🗑</button></td>
              </tr>
              <tr *ngIf="documents.length===0">
                <td colspan="5" style="text-align:center;padding:32px;color:var(--muted);">Aucun document</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `,
})
export class DocumentsComponent implements OnInit {
  documents: Document[] = [];

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.api.getDocuments().subscribe(d => this.documents = d);
  }

  supprimer(id: string): void {
    if (confirm('Supprimer ce document ?')) {
      this.api.deleteDocument(id).subscribe(() => this.api.getDocuments().subscribe(d => this.documents = d));
    }
  }
}
