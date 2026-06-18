import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { ApiService, AuditLog } from '../../core/services/api';

@Component({
  selector: 'app-audit',
  standalone: true,
  imports: [CommonModule, DatePipe],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">Journal sécurité</div>
        <div class="topbar__sub">Traçabilité des actions administrateurs et agents</div>
      </div>
    </div>

    <div class="page">
      <div class="card fade-up">
        <div class="card__body" style="padding:0;">
          <table class="ds-table">
            <thead>
              <tr><th>Utilisateur</th><th>Action</th><th>Modèle</th><th>IP</th><th>Date</th></tr>
            </thead>
            <tbody>
              <tr *ngFor="let log of logs">
                <td style="font-weight:600;">{{ log.user }}</td>
                <td><span class="badge badge--blue">{{ log.action }}</span></td>
                <td style="color:var(--muted);">{{ log.model }} #{{ log.object_id | slice:0:8 }}</td>
                <td class="mono" style="font-size:11px;">{{ log.ip_address }}</td>
                <td style="color:var(--muted);font-size:12px;">{{ log.created_at | date:'dd/MM/yyyy HH:mm' }}</td>
              </tr>
              <tr *ngIf="logs.length===0">
                <td colspan="5" style="text-align:center;padding:32px;color:var(--muted);">Aucun log</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `,
})
export class AuditComponent implements OnInit {
  logs: AuditLog[] = [];

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.api.getAuditLogs().subscribe(l => this.logs = l);
  }
}
