import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService, ScanResult } from '../../core/services/api';

type ScanPhase = 'idle' | 'uploading' | 'ocr' | 'matching' | 'scoring' | 'done' | 'error';

@Component({
  selector: 'app-scan',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">🔍 Scanner IA</div>
        <div class="topbar__sub">Analyse OCR + Détection de fraude par intelligence artificielle</div>
      </div>
    </div>

    <div class="page" style="max-width:960px;">

      <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px; align-items:start;">

        <!-- LEFT: UPLOAD -->
        <div>
          <div class="card fade-up">
            <div class="card__header">
              <div>
                <div class="card__title">Document à analyser</div>
                <div class="card__sub">Image JPG/PNG ou PDF (max 10 Mo)</div>
              </div>
            </div>
            <div class="card__body">

              <!-- DROP ZONE -->
              <div class="drop-zone" [class.drag-over]="isDragging"
                   (dragover)="$event.preventDefault(); isDragging=true"
                   (dragleave)="isDragging=false"
                   (drop)="onDrop($event)"
                   (click)="fileInput.click()">
                <ng-container *ngIf="!selectedFile">
                  <div class="drop-zone__icon">📂</div>
                  <div class="drop-zone__text">
                    Glisser-déposer un fichier ici<br>
                    ou <strong>cliquer pour parcourir</strong>
                  </div>
                </ng-container>
                <ng-container *ngIf="selectedFile">
                  <div style="font-size:36px; margin-bottom:10px;">
                    {{ selectedFile.name.endsWith('.pdf') ? '📄' : '🖼️' }}
                  </div>
                  <div style="font-size:13px; font-weight:600; color:var(--text);">{{ selectedFile.name }}</div>
                  <div style="font-size:11px; color:var(--muted);">{{ (selectedFile.size / 1024).toFixed(1) }} Ko</div>
                </ng-container>
              </div>
              <input #fileInput type="file" accept=".jpg,.jpeg,.png,.pdf" style="display:none" (change)="onFile($event)" />

              <div class="form-group mt-3">
                <label>ID DE L'ACTE (optionnel)</label>
                <input class="form-control" [(ngModel)]="acteId" placeholder="UUID de l'acte lié..." />
              </div>

              <button class="btn btn--primary w-full mt-2" style="justify-content:center;"
                      (click)="startScan()" [disabled]="!selectedFile || phase !== 'idle'">
                <span *ngIf="phase === 'idle'">🚀 Lancer l'analyse IA</span>
                <span *ngIf="phase !== 'idle' && phase !== 'done' && phase !== 'error'">⏳ Analyse en cours...</span>
                <span *ngIf="phase === 'done'">✅ Analyse terminée</span>
              </button>
              <button class="btn btn--ghost w-full mt-2" style="justify-content:center;"
                      *ngIf="phase === 'done'" (click)="reset()">
                🔄 Nouvelle analyse
              </button>
            </div>
          </div>

          <!-- PIPELINE STEPS -->
          <div class="card mt-4 fade-up delay-1">
            <div class="card__header">
              <div class="card__title">Pipeline d'analyse</div>
            </div>
            <div class="card__body">
              <div *ngFor="let step of pipelineSteps; let i = index"
                   style="display:flex; align-items:center; gap:12px; padding:10px 0; border-bottom:1px solid var(--border);"
                   [style.border-bottom]="i === pipelineSteps.length-1 ? 'none' : ''">
                <div style="width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;"
                     [style.background]="stepBg(step.key)"
                     [style.color]="stepColor(step.key)">
                  <span *ngIf="stepStatus(step.key) === 'done'">✓</span>
                  <span *ngIf="stepStatus(step.key) === 'active'">⟳</span>
                  <span *ngIf="stepStatus(step.key) === 'pending'">{{ i + 1 }}</span>
                </div>
                <div style="flex:1;">
                  <div style="font-size:13px;font-weight:600;"
                       [style.color]="stepStatus(step.key) === 'pending' ? 'var(--muted)' : 'var(--text)'">
                    {{ step.label }}
                  </div>
                  <div style="font-size:11px;color:var(--muted);">{{ step.sub }}</div>
                </div>
                <div *ngIf="stepStatus(step.key) === 'active'" style="width:12px;height:12px;border:2px solid var(--primary);border-top-color:transparent;border-radius:50%;animation:spin .6s linear infinite;"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- RIGHT: RESULTS -->
        <div>
          <!-- IDLE STATE -->
          <div class="card fade-up" *ngIf="phase === 'idle'" style="text-align:center; padding:48px;">
            <div style="font-size:56px; opacity:.3; margin-bottom:16px;">🤖</div>
            <div style="font-size:16px; font-weight:700; color:var(--muted);">En attente d'un document</div>
            <div style="font-size:13px; color:var(--muted); margin-top:6px;">Uploadez un acte pour démarrer l'analyse IA</div>
          </div>

          <!-- SCANNING ANIMATION -->
          <div class="card fade-up" *ngIf="phase !== 'idle' && phase !== 'done' && phase !== 'error'">
            <div class="card__header">
              <div class="card__title">Analyse en cours...</div>
            </div>
            <div class="card__body">
              <div style="background:var(--dark);border-radius:10px;padding:20px;font-family:'JetBrains Mono',monospace;font-size:12px;color:#a8d8a8;line-height:2;min-height:300px;">
                <div *ngFor="let line of terminalLines">
                  <span style="color:#82AAFF;">{{ line.prefix }}</span>
                  <span [style.color]="line.color || '#a8d8a8'">{{ line.text }}</span>
                </div>
                <span style="border-right:2px solid #a8d8a8;animation:blink .7s infinite;margin-left:2px;">&nbsp;</span>
              </div>
            </div>
          </div>

          <!-- RESULTS -->
          <ng-container *ngIf="phase === 'done' && result">

            <!-- FRAUD SCORE HERO -->
            <div class="card fade-up mb-4"
                 [style.border-color]="result.fraud_score >= 70 ? 'var(--danger)' : result.fraud_score >= 40 ? 'var(--warning)' : 'var(--green)'"
                 style="border-width:2px;">
              <div class="card__body" style="text-align:center;padding:28px;">
                <div style="font-size:13px;font-weight:600;color:var(--muted);letter-spacing:1px;text-transform:uppercase;margin-bottom:12px;">
                  Score de risque de fraude
                </div>
                <div style="font-size:72px;font-weight:800;letter-spacing:-4px;line-height:1;"
                     [style.color]="result.fraud_score >= 70 ? 'var(--danger)' : result.fraud_score >= 40 ? 'var(--warning)' : 'var(--green)'">
                  {{ result.fraud_score }}
                </div>
                <div style="font-size:16px;color:var(--muted);">/ 100</div>
                <div class="badge mt-3" style="font-size:14px;padding:8px 20px;"
                     [class]="result.decision === 'FRAUD' ? 'badge--red' : result.decision === 'SUSPECT' ? 'badge--orange' : 'badge--green'">
                  {{ decisionLabel(result.decision) }}
                </div>
              </div>
            </div>

            <!-- EXTRACTED DATA -->
            <div class="card fade-up delay-1 mb-4">
              <div class="card__header">
                <div class="card__title">📋 Données extraites (OCR)</div>
                <span class="badge badge--blue">JSON</span>
              </div>
              <div class="card__body" style="padding:0;">
                <div class="scan-result" style="border-radius:0 0 14px 14px;">
                  <div><span class="key">"nom"</span>: <span class="str">"{{ result.extracted_data?.nom || 'Non détecté' }}"</span>,</div>
                  <div><span class="key">"prenom"</span>: <span class="str">"{{ result.extracted_data?.prenom || 'Non détecté' }}"</span>,</div>
                  <div><span class="key">"date_naissance"</span>: <span class="str">"{{ result.extracted_data?.date_naissance || '—' }}"</span>,</div>
                  <div><span class="key">"lieu_naissance"</span>: <span class="str">"{{ result.extracted_data?.lieu_naissance || '—' }}"</span>,</div>
                  <div><span class="key">"numero"</span>: <span class="str">"{{ result.extracted_data?.numero || '—' }}"</span>,</div>
                  <div><span class="key">"fraud_score"</span>: <span [class]="result.fraud_score >= 70 ? 'score-high' : result.fraud_score >= 40 ? 'score-medium' : 'score-low'">{{ result.fraud_score }}</span>,</div>
                  <div><span class="key">"risk_level"</span>: <span class="str">"{{ result.risk_level }}"</span>,</div>
                  <div><span class="key">"decision"</span>: <span class="str">"{{ result.decision }}"</span></div>
                </div>
              </div>
            </div>

            <!-- MOTIFS -->
            <div class="card fade-up delay-2" *ngIf="result.motifs && result.motifs.length > 0">
              <div class="card__header">
                <div class="card__title">⚠️ Motifs de suspicion</div>
              </div>
              <div class="card__body">
                <div *ngFor="let motif of result.motifs"
                     style="display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid var(--border);">
                  <span style="color:var(--danger);font-size:16px;">●</span>
                  <span style="font-size:13px;">{{ motif }}</span>
                </div>
              </div>
            </div>

            <!-- ACTIONS -->
            <div style="display:flex;gap:10px;margin-top:14px;" class="fade-up delay-3">
              <button class="btn btn--success" style="flex:1;justify-content:center;" (click)="validerActe()">
                ✓ Valider l'acte
              </button>
              <button class="btn btn--danger" style="flex:1;justify-content:center;" (click)="signalerFraude()">
                🚨 Signaler fraude
              </button>
            </div>
          </ng-container>

        </div>
      </div>
    </div>
  `,
  styles: [`
    @keyframes spin { to { transform: rotate(360deg); } }
    @keyframes blink { 50% { opacity: 0; } }
  `]
})
export class ScanComponent {
  selectedFile: File | null = null;
  acteId = '';
  isDragging = false;
  phase: ScanPhase = 'idle';
  result: ScanResult | null = null;
  terminalLines: { prefix: string; text: string; color?: string }[] = [];

  pipelineSteps = [
    { key: 'uploading', label: 'Upload du document', sub: 'Envoi sécurisé au serveur' },
    { key: 'ocr',       label: 'Extraction OCR', sub: 'Lecture des données textuelles' },
    { key: 'matching',  label: 'Matching base de données', sub: 'Comparaison avec actes existants' },
    { key: 'scoring',   label: 'Calcul du score IA', sub: 'Détection anomalies et fraudes' },
    { key: 'done',      label: 'Résultat final', sub: 'Décision et rapport généré' },
  ];

  phaseOrder: ScanPhase[] = ['idle', 'uploading', 'ocr', 'matching', 'scoring', 'done'];

  stepStatus(key: string): 'done' | 'active' | 'pending' {
    const phases = ['uploading', 'ocr', 'matching', 'scoring', 'done'];
    const current = phases.indexOf(this.phase);
    const step    = phases.indexOf(key);
    if (step < current) return 'done';
    if (step === current) return 'active';
    return 'pending';
  }

  stepBg(key: string) {
    const s = this.stepStatus(key);
    return s === 'done' ? 'var(--green-light)' : s === 'active' ? 'var(--primary-light)' : '#F3F4F6';
  }
  stepColor(key: string) {
    const s = this.stepStatus(key);
    return s === 'done' ? 'var(--green)' : s === 'active' ? 'var(--primary)' : 'var(--muted)';
  }

  onFile(event: any) {
    this.selectedFile = event.target.files[0] || null;
  }
  onDrop(event: DragEvent) {
    event.preventDefault(); this.isDragging = false;
    this.selectedFile = event.dataTransfer?.files[0] || null;
  }

  addTerminalLine(prefix: string, text: string, color?: string) {
    this.terminalLines.push({ prefix, text, color });
  }

  async startScan() {
    if (!this.selectedFile) return;
    this.terminalLines = [];
    this.result = null;

    // SIMULATED PIPELINE (replace with real API call below)
    this.phase = 'uploading';
    this.addTerminalLine('[INFO] ', 'Connexion sécurisée établie...');
    await this.delay(700);
    this.addTerminalLine('[OK]   ', 'Document reçu: ' + this.selectedFile.name, '#82AAFF');

    this.phase = 'ocr';
    await this.delay(600);
    this.addTerminalLine('[OCR]  ', 'Initialisation moteur Tesseract...');
    await this.delay(900);
    this.addTerminalLine('[OCR]  ', 'Extraction texte en cours...', '#FFCB6B');
    await this.delay(1100);
    this.addTerminalLine('[OCR]  ', 'Nom: DIOP | Prénom: Moussa | DoB: 01/01/1990', '#a8d8a8');

    this.phase = 'matching';
    await this.delay(600);
    this.addTerminalLine('[MATCH] ', 'Requête base citoyens...');
    await this.delay(900);
    this.addTerminalLine('[MATCH] ', '2 correspondances trouvées (similarité > 80%)', '#FFCB6B');

    this.phase = 'scoring';
    await this.delay(700);
    this.addTerminalLine('[AI]   ', 'Calcul vecteurs d\'anomalie...');
    await this.delay(800);
    this.addTerminalLine('[AI]   ', 'Anomalie détectée: date incohérente', '#F78C6C');
    await this.delay(600);
    this.addTerminalLine('[AI]   ', 'Doublon probable avec ACT-2025-0312', '#F78C6C');
    await this.delay(500);
    this.addTerminalLine('[SCORE] ', '████████████████░░░░ 82/100 — HIGH RISK', '#C0392B');

    this.phase = 'done';
    this.result = {
      ocr_text: 'Extrait...',
      extracted_data: { nom: 'DIOP', prenom: 'Moussa', date_naissance: '01/01/1990', lieu_naissance: 'Dakar', numero: 'SN-1990-0082' },
      fraud_score: 82,
      risk_level: 'HIGH',
      decision: 'FRAUD',
      motifs: ['Doublon détecté avec ACT-2025-0312', 'Date de naissance incohérente', 'Document similaire dans base', 'Numéro de registre non conforme']
    };

    // REAL API CALL (uncomment when backend ready):
    /*
    this.api.scanDocument(this.acteId, this.selectedFile).subscribe({
      next: (r) => { this.result = r; this.phase = 'done'; },
      error: ()  => { this.phase = 'error'; }
    });
    */
  }

  delay(ms: number) { return new Promise(r => setTimeout(r, ms)); }
  reset() { this.phase = 'idle'; this.selectedFile = null; this.result = null; this.terminalLines = []; }

  decisionLabel(d: string) {
    return { VALID: '✅ Document valide', SUSPECT: '⚠️ Acte suspect', FRAUD: '🚨 Fraude confirmée' }[d] ?? d;
  }

  validerActe()   { alert('Acte validé !'); }
  signalerFraude() { alert('Fraude signalée — alerte créée.'); }

  constructor(private api: ApiService) {}
}