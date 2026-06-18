import { Component, ViewChild, ElementRef, AfterViewChecked } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService, CopilotMessage } from '../../core/services/api';
import { AuthService } from '../../core/services/auth.service';

const SUGGESTIONS = [
  'Combien de fraudes détectées cette semaine ?',
  'Quel centre est le plus risqué ?',
  'Montre-moi les actes suspects.',
  'Pourquoi cet acte est suspect ?',
  'Quels centres ont le plus de fraudes ce mois ?',
];

@Component({
  selector: 'app-copilot',
  standalone: true,
  imports: [CommonModule, FormsModule, DatePipe],
  template: `
    <div class="topbar">
      <div style="display:flex;align-items:center;gap:14px;">
        <div style="width:42px;height:42px;border-radius:12px;background:var(--dark);display:flex;align-items:center;justify-content:center;font-size:20px;">🤖</div>
        <div>
          <div class="topbar__title">Assistant décisionnel DetectSen</div>
          <div class="topbar__sub">
            <span style="display:inline-flex;align-items:center;gap:6px;">
              <span style="width:7px;height:7px;border-radius:50%;background:var(--green);display:inline-block;"></span>
              Copilot IA · Analyse en langage naturel
            </span>
          </div>
        </div>
      </div>
      <div class="topbar__right">
        <button class="btn btn--ghost btn--sm" (click)="clearChat()">🗑 Effacer</button>
      </div>
    </div>

    <div class="page" style="max-width:860px;display:flex;flex-direction:column;height:calc(100vh - 64px);padding-bottom:0;">
      <div #msgContainer style="flex:1;overflow-y:auto;padding-bottom:20px;">
        <div *ngIf="messages.length === 0" style="text-align:center;padding:56px 24px 32px;">
          <div style="font-size:56px;margin-bottom:16px;">🛡️</div>
          <div style="font-size:22px;font-weight:800;margin-bottom:8px;">Bonjour {{ userName }}.</div>
          <div style="font-size:14px;color:var(--muted);max-width:420px;margin:0 auto 32px;">
            Posez une question sur les fraudes, centres, actes suspects et statistiques — l'IA interroge la base DetectSen.
          </div>
          <div style="display:flex;flex-wrap:wrap;gap:10px;justify-content:center;">
            <button *ngFor="let s of suggestions" class="btn btn--ghost btn--sm" style="border-radius:20px;font-size:12px;" (click)="sendSuggestion(s)">{{ s }}</button>
          </div>
        </div>

        <div class="copilot-messages" *ngIf="messages.length > 0" style="padding:24px 0;">
          <div *ngFor="let msg of messages" class="message" [class]="'message--' + msg.role">
            <div class="message__avatar">{{ msg.role === 'user' ? 'A' : '🤖' }}</div>
            <div>
              <div class="message__bubble" [innerHTML]="formatMessage(msg.content)"></div>
              <div style="font-size:10px;color:var(--muted);margin-top:4px;">{{ msg.timestamp | date:'HH:mm' }}</div>
            </div>
          </div>
          <div class="message message--ai" *ngIf="isLoading">
            <div class="message__avatar">🤖</div>
            <div class="message__bubble" style="padding:14px 16px;">
              <span class="typing-dot"></span><span class="typing-dot"></span><span class="typing-dot"></span>
            </div>
          </div>
        </div>
      </div>

      <div style="padding:0 0 24px;">
        <div style="display:flex;gap:10px;align-items:flex-end;background:var(--card);border:1.5px solid var(--border);border-radius:var(--radius-lg);padding:12px 14px;">
          <textarea [(ngModel)]="userInput" (keydown.enter)="onEnter($any($event))" placeholder="Posez une question..."
            style="flex:1;border:none;outline:none;resize:none;font-family:'Montserrat',sans-serif;font-size:14px;background:transparent;min-height:24px;" rows="1"></textarea>
          <button class="btn btn--primary btn--sm" [disabled]="!userInput.trim() || isLoading" (click)="send()">
            {{ isLoading ? '⏳' : '↑ Envoyer' }}
          </button>
        </div>
      </div>
    </div>
  `,
})
export class CopilotComponent implements AfterViewChecked {
  @ViewChild('msgContainer') msgContainer!: ElementRef;

  messages: CopilotMessage[] = [];
  userInput = '';
  isLoading = false;
  suggestions = SUGGESTIONS;
  userName = 'Admin';

  constructor(private api: ApiService, private auth: AuthService) {
    this.userName = this.auth.getUserName();
  }

  ngAfterViewChecked(): void {
    try { this.msgContainer.nativeElement.scrollTop = this.msgContainer.nativeElement.scrollHeight; } catch {}
  }

  onEnter(e: KeyboardEvent): void {
    if (!e.shiftKey) { e.preventDefault(); this.send(); }
  }

  sendSuggestion(s: string): void { this.userInput = s; this.send(); }

  send(): void {
    const q = this.userInput.trim();
    if (!q || this.isLoading) return;
    this.userInput = '';
    this.messages.push({ role: 'user', content: q, timestamp: new Date() });
    this.isLoading = true;

    this.api.askCopilot(q, this.messages.slice(0, -1)).subscribe({
      next: res => {
        this.isLoading = false;
        this.messages.push({ role: 'assistant', content: res.response, timestamp: new Date() });
      },
      error: () => {
        this.isLoading = false;
        this.messages.push({ role: 'assistant', content: this.demoResponse(q), timestamp: new Date() });
      },
    });
  }

  demoResponse(q: string): string {
    const l = q.toLowerCase();
    if (l.includes('fraude') && l.includes('semaine')) {
      return '**18 fraudes** détectées cette semaine.\n\n**Répartition :**\n- Dakar Centre : 8\n- Thiès : 5\n- Saint-Louis : 3\n\n> Recommandation : Renforcer le contrôle manuel à Dakar Centre.';
    }
    if (l.includes('centre') && l.includes('risqu')) {
      return '**Centre le plus risqué : Dakar Centre**\n\n- 42 fraudes ce mois\n- Taux de fraude : 78%\n\n> Recommandation : Audit prioritaire des agents.';
    }
    if (l.includes('suspect')) {
      return '**Actes suspects récents :**\n\n1. SN-2026-002 — Fatou Ndiaye — Score 87% — Thiès\n2. SN-2026-001 — Mamadou Diop — Score 92% — Dakar\n\n> Consultez la page Alertes pour le détail.';
    }
    return `Analyse de votre requête : *"${q}"*\n\nConnectez le backend Django sur \`/api/copilot/\` pour des réponses en temps réel.`;
  }

  formatMessage(c: string): string {
    return c.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>').replace(/\n/g, '<br>')
      .replace(/> (.*)/g, '<blockquote style="border-left:3px solid var(--primary);padding-left:10px;color:var(--muted);">$1</blockquote>');
  }

  clearChat(): void { this.messages = []; }
}
