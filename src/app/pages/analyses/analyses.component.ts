import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { ApiService, AIAnalysis } from '../../core/services/api';

@Component({
  selector: 'app-analyses',
  standalone: true,
  imports: [CommonModule, DatePipe],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Analyses IA</div>
        <div class="topbar__sub">Résultats OCR et détection fraude · {{ analyses.length }} analyses</div>
      </div>
    </div>

    <div class="page">
      <div class="stat-grid" style="grid-template-columns:repeat(3,1fr);margin-bottom:22px;">
        <div class="stat-card blue fade-up">
          <div class="stat-card__value">{{ analyses.length }}</div>
          <div class="stat-card__label">Total analyses</div>
        </div>
        <div class="stat-card green fade-up delay-1">
          <div class="stat-card__value">{{ countDecision('VALID') }}</div>
          <div class="stat-card__label">Validés</div>
        </div>
        <div class="stat-card red fade-up delay-2">
          <div class="stat-card__value">{{ countDecision('FRAUD') + countDecision('SUSPECT') }}</div>
          <div class="stat-card__label">Suspects / Fraudes</div>
        </div>
      </div>

      <div class="card fade-up">
        <div class="card__body" style="padding:0;">
          <table class="ds-table">
            <thead>
              <tr><th>Acte</th><th>Score fraude</th><th>Similarité</th><th>Décision</th><th>Risque</th><th>Date</th><th></th></tr>
            </thead>
            <tbody>
              <tr *ngFor="let a of analyses">
                <td class="mono" style="font-weight:600;">{{ a.numero_acte || a.acte }}</td>
                <td><span class="risk-pill" [class]="riskClass(a.fraud_score)">{{ a.fraud_score }}%</span></td>
                <td>{{ a.similarity_score ?? '—' }}%</td>
                <td><span class="badge" [class]="decisionClass(a.decision)">{{ a.decision }}</span></td>
                <td><span class="badge" [class]="riskBadge(a.risk_level)">{{ a.risk_level }}</span></td>
                <td style="color:var(--muted);font-size:12px;">{{ a.created_at | date:'dd/MM/yyyy' }}</td>
                <td><button class="btn btn--ghost btn--sm" (click)="voirDetail(a)">Détail →</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="modal-backdrop" *ngIf="selected" (click)="selected=null">
      <div class="modal" style="max-width:640px;" (click)="$event.stopPropagation()">
        <div class="modal__title">Analyse IA</div>
        <div class="modal__sub">Acte {{ selected!.numero_acte || selected!.acte }}</div>

        <div style="margin-top:16px;">
          <label style="font-size:11px;color:var(--muted);font-weight:700;">TEXTE OCR</label>
          <pre style="background:var(--surface);padding:14px;border-radius:10px;font-size:12px;margin-top:8px;white-space:pre-wrap;max-height:150px;overflow:auto;">{{ selected!.ocr_text || '—' }}</pre>
        </div>

        <div style="margin-top:16px;">
          <label style="font-size:11px;color:var(--muted);font-weight:700;">DONNÉES EXTRAITES</label>
          <pre style="background:var(--surface);padding:14px;border-radius:10px;font-size:12px;margin-top:8px;">{{ selected!.extracted_data | json }}</pre>
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-top:16px;">
          <div><span style="color:var(--muted);font-size:11px;">FRAUD SCORE</span><br><strong style="font-size:24px;" [style.color]="scoreColor(selected!.fraud_score)">{{ selected!.fraud_score }}</strong></div>
          <div><span style="color:var(--muted);font-size:11px;">SIMILARITÉ</span><br><strong>{{ selected!.similarity_score ?? '—' }}%</strong></div>
          <div><span style="color:var(--muted);font-size:11px;">RISQUE</span><br><span class="badge" [class]="riskBadge(selected!.risk_level)">{{ selected!.risk_level }}</span></div>
        </div>

        <div style="display:flex;justify-content:flex-end;margin-top:20px;">
          <button class="btn btn--ghost" (click)="selected=null">Fermer</button>
        </div>
      </div>
    </div>
  `,
})
export class AnalysesComponent implements OnInit {
  analyses: AIAnalysis[] = [];
  selected: AIAnalysis | null = null;

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.api.getAnalyses().subscribe(a => this.analyses = a);
  }

  countDecision(d: string): number {
    return this.analyses.filter(a => a.decision === d).length;
  }

  voirDetail(a: AIAnalysis): void {
    this.api.getAnalyse(a.id).subscribe(d => this.selected = d);
  }

  riskClass(s: number): string {
    return s >= 70 ? 'risk-pill risk-pill--high' : s >= 40 ? 'risk-pill risk-pill--medium' : 'risk-pill risk-pill--low';
  }

  decisionClass(d: string): string {
    return { VALID: 'badge--green', SUSPECT: 'badge--orange', FRAUD: 'badge--red' }[d] ?? 'badge--gray';
  }

  riskBadge(r: string): string {
    return { HIGH: 'badge--red', MEDIUM: 'badge--orange', LOW: 'badge--green' }[r] ?? 'badge--gray';
  }

  scoreColor(s: number): string {
    return s >= 70 ? 'var(--danger)' : s >= 40 ? 'var(--warning)' : 'var(--green)';
  }
}
