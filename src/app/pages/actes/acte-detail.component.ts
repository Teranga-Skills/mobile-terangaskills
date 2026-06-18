import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { ApiService, Acte } from '../../core/services/api';

@Component({
  selector: 'app-acte-detail',
  standalone: true,
  imports: [CommonModule, DatePipe, RouterModule],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Acte {{ acte?.numero_acte }}</div>
        <div class="topbar__sub">Détail et analyse IA</div>
      </div>
      <div class="topbar__right">
        <button class="btn btn--ghost btn--sm" routerLink="/actes">← Retour</button>
      </div>
    </div>

    <div class="page" *ngIf="acte">
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">
        <div class="card fade-up">
          <div class="card__header"><div class="card__title">Informations</div></div>
          <div class="card__body">
            <p><span style="color:var(--muted);">Citoyen</span><br><strong>{{ acte.citoyen_nom }}</strong></p>
            <p style="margin-top:12px;"><span style="color:var(--muted);">Centre</span><br><strong>{{ acte.centre_nom || acte.centre }}</strong></p>
            <p style="margin-top:12px;"><span style="color:var(--muted);">Type</span><br><strong>{{ acte.type_acte }}</strong></p>
            <p style="margin-top:12px;"><span style="color:var(--muted);">Date</span><br><strong>{{ acte.date_creation | date:'dd/MM/yyyy' }}</strong></p>
            <p style="margin-top:12px;">
              <span style="color:var(--muted);">Statut</span><br>
              <span class="badge" [class]="statutClass(acte.statut)">{{ acte.statut }}</span>
            </p>
          </div>
        </div>

        <div class="card fade-up delay-1">
          <div class="card__header"><div class="card__title">Document</div></div>
          <div class="card__body" style="text-align:center;">
            <div *ngIf="acte.document_url" style="background:var(--surface);border-radius:12px;padding:20px;">
              <img [src]="acte.document_url" alt="Document" style="max-width:100%;border-radius:8px;" />
            </div>
            <div *ngIf="!acte.document_url" style="padding:40px;color:var(--muted);">
              📄 Aucun document uploadé
            </div>
          </div>
        </div>
      </div>

      <div class="card fade-up delay-2" style="margin-top:20px;" *ngIf="analyse">
        <div class="card__header">
          <div class="card__title">Analyse IA</div>
          <div class="card__sub">Résultat OCR et détection fraude</div>
        </div>
        <div class="card__body">
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">
            <div>
              <label style="font-size:11px;color:var(--muted);font-weight:700;">TEXTE OCR EXTRAIT</label>
              <pre style="background:var(--surface);padding:14px;border-radius:10px;font-size:12px;margin-top:8px;white-space:pre-wrap;">{{ analyse.ocr_text || '—' }}</pre>
            </div>
            <div>
              <div style="margin-bottom:16px;">
                <span style="color:var(--muted);font-size:12px;">SCORE FRAUDE</span>
                <div style="font-size:36px;font-weight:800;" [style.color]="scoreColor(analyse.fraud_score)">{{ analyse.fraud_score }}%</div>
              </div>
              <div style="margin-bottom:16px;">
                <span style="color:var(--muted);font-size:12px;">DÉCISION</span><br>
                <span class="badge" [class]="decisionClass(analyse.decision)">{{ analyse.decision }}</span>
              </div>
              <div>
                <span style="color:var(--muted);font-size:12px;">MOTIFS</span>
                <div style="margin-top:8px;display:flex;flex-wrap:gap:6px;">
                  <span class="reason-tag" *ngFor="let m of analyse.motifs">{{ m }}</span>
                  <span *ngIf="!analyse.motifs?.length" style="color:var(--muted);">Aucun motif</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div style="display:flex;gap:12px;margin-top:20px;">
        <button class="btn btn--success" (click)="valider()" [disabled]="saving">✓ Valider</button>
        <button class="btn btn--danger" (click)="marquerFraude()" [disabled]="saving">🚨 Marquer fraude</button>
      </div>
    </div>
  `,
})
export class ActeDetailComponent implements OnInit {
  acte: Acte | null = null;
  analyse: Acte['analyse'] | null = null;
  saving = false;

  constructor(private api: ApiService, private route: ActivatedRoute, private router: Router) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.api.getActe(id).subscribe({
      next: a => { this.acte = a; this.analyse = a.analyse ?? null; },
      error: () => this.router.navigate(['/actes']),
    });
  }

  valider(): void {
    if (!this.acte) return;
    this.saving = true;
    this.api.updateStatutActe(this.acte.id, 'VALIDE').subscribe({
      next: a => { this.acte = a; this.saving = false; },
      error: () => { this.saving = false; },
    });
  }

  marquerFraude(): void {
    if (!this.acte) return;
    this.saving = true;
    this.api.updateStatutActe(this.acte.id, 'FRAUDE').subscribe({
      next: a => { this.acte = a; this.saving = false; },
      error: () => { this.saving = false; },
    });
  }

  statutClass(s: string): string {
    return { VALIDE: 'badge--green', SUSPECT: 'badge--orange', FRAUDE: 'badge--red' }[s] ?? 'badge--gray';
  }

  decisionClass(d: string): string {
    return { VALID: 'badge--green', SUSPECT: 'badge--orange', FRAUD: 'badge--red' }[d] ?? 'badge--gray';
  }

  scoreColor(score: number): string {
    return score >= 70 ? 'var(--danger)' : score >= 40 ? 'var(--warning)' : 'var(--green)';
  }
}
