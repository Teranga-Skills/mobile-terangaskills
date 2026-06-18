import { Component, OnInit, AfterViewInit, ElementRef, ViewChild } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ApiService, DashboardStats, Acte } from '../../core/services/api';
import { AuthService } from '../../core/services/auth.service';
import { Chart, registerables } from 'chart.js';

Chart.register(...registerables);

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, DatePipe],
  template: `
    <div class="topbar">
      <div>
        <div class="topbar__title">DetectSen Admin Console</div>
        <div class="topbar__sub">Bonjour {{ userName }} · Tableau de bord national — Sénégal · {{ today | date:'dd MMMM yyyy, HH:mm' }}</div>
      </div>
      <div class="topbar__right">
        <button class="topbar__btn" routerLink="/analyses" data-tooltip="Analyses IA">🤖</button>
        <button class="topbar__btn" routerLink="/alertes" data-tooltip="Alertes fraude" style="position:relative;">
          🔔
          <span class="topbar__notif-dot" *ngIf="stats.fraudes_detectees"></span>
        </button>
        <button class="topbar__btn" data-tooltip="Actualiser" (click)="loadAll()">🔄</button>
      </div>
    </div>

    <div class="page">
      <!-- KPI CARDS -->
      <div class="stat-grid">
        <div class="stat-card blue fade-up">
          <div class="stat-card__icon">📄</div>
          <div class="stat-card__value">{{ stats.total_actes | number }}</div>
          <div class="stat-card__label">Actes enregistrés</div>
        </div>
        <div class="stat-card green fade-up delay-1">
          <div class="stat-card__icon">👥</div>
          <div class="stat-card__value">{{ stats.citoyens_enregistres | number }}</div>
          <div class="stat-card__label">Citoyens enregistrés</div>
        </div>
        <div class="stat-card red fade-up delay-2">
          <div class="stat-card__icon">🚨</div>
          <div class="stat-card__value">{{ stats.fraudes_detectees | number }}</div>
          <div class="stat-card__label">Fraudes détectées</div>
        </div>
        <div class="stat-card orange fade-up delay-3">
          <div class="stat-card__icon">⚠️</div>
          <div class="stat-card__value">{{ (stats.alertes_critiques ?? stats.doublons_detectes) | number }}</div>
          <div class="stat-card__label">Alertes critiques</div>
        </div>
      </div>

      <!-- ROW 2: CHART + GAUGE -->
      <div style="display:grid; grid-template-columns:2fr 1fr; gap:18px; margin-bottom:22px;">
        <div class="card fade-up delay-2">
          <div class="card__header">
            <div>
              <div class="card__title">Évolution mensuelle des actes</div>
              <div class="card__sub">Naissances · Mariages · Décès · 12 derniers mois</div>
            </div>
            <a class="card__action" routerLink="/actes">Voir tout →</a>
          </div>
          <div class="card__body" style="padding-top:10px;">
            <canvas #chartEvo height="95"></canvas>
          </div>
        </div>

        <div class="card fade-up delay-3">
          <div class="card__header">
            <div>
              <div class="card__title">Score de risque national</div>
              <div class="card__sub">Moyenne IA · 30 jours</div>
            </div>
          </div>
          <div class="card__body" style="text-align:center; padding-top:0;">
            <canvas #chartGauge width="200" height="130" style="margin:0 auto; display:block;"></canvas>
            <div style="font-size:44px; font-weight:800; letter-spacing:-2px; margin-top:-10px;"
                 [style.color]="gaugeColor">{{ riskCounter }}</div>
            <div style="font-size:12px; color:var(--muted); margin-bottom:16px;">Score global / 100</div>
            <div style="display:flex; justify-content:center; gap:16px;">
              <div style="display:flex;align-items:center;gap:5px;font-size:11px;color:var(--muted);">
                <span style="width:8px;height:8px;border-radius:50%;background:var(--green);display:inline-block;"></span>Bas 0–39
              </div>
              <div style="display:flex;align-items:center;gap:5px;font-size:11px;color:var(--muted);">
                <span style="width:8px;height:8px;border-radius:50%;background:var(--warning);display:inline-block;"></span>Moyen
              </div>
              <div style="display:flex;align-items:center;gap:5px;font-size:11px;color:var(--muted);">
                <span style="width:8px;height:8px;border-radius:50%;background:var(--danger);display:inline-block;"></span>Haut 70+
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ROW 3: SUSPECTS + TOP CENTRES -->
      <div style="display:grid; grid-template-columns:1.5fr 1fr; gap:18px; margin-bottom:22px;">

        <div class="card fade-up delay-3">
          <div class="card__header">
            <div>
              <div class="card__title" style="display:flex;align-items:center;gap:8px;">
                <span class="pulse-dot"></span> Actes suspects récents
              </div>
              <div class="card__sub">Anomalies détectées par l'IA</div>
            </div>
            <a class="card__action" routerLink="/alertes">Voir alertes →</a>
          </div>
          <div class="card__body" style="padding-top:0;">
            <div class="fraud-item" *ngFor="let a of actesSuspects">
              <div class="risk-pill" [class]="riskPillClass(a.fraud_score!)">
                {{ a.fraud_score }}
              </div>
              <div class="fraud-item__body">
                <div class="fraud-item__name">{{ a.citoyen_nom || 'Citoyen' }} — {{ typeLabel(a.type_acte) }}</div>
                <div class="fraud-item__meta">{{ a.centre_nom }} · {{ a.date_creation | date:'dd/MM/yyyy' }}</div>
              </div>
              <a [routerLink]="['/actes', a.id]" class="fraud-item__arrow">›</a>
            </div>

            <!-- FALLBACK DEMO -->
            <ng-container *ngIf="actesSuspects.length === 0">
              <div class="fraud-item">
                <div class="risk-pill risk-pill--high">87</div>
                <div class="fraud-item__body">
                  <div class="fraud-item__name">Diop Moussa — Naissance</div>
                  <div class="fraud-item__meta">Centre Dakar Plateau · 16/06/2025</div>
                  <div class="fraud-item__tags">
                    <span class="reason-tag">Doublon détecté</span>
                    <span class="reason-tag">Anomalie date</span>
                  </div>
                </div>
                <span class="fraud-item__arrow">›</span>
              </div>
              <div class="fraud-item">
                <div class="risk-pill risk-pill--high">74</div>
                <div class="fraud-item__body">
                  <div class="fraud-item__name">Ndiaye Fatou — Mariage</div>
                  <div class="fraud-item__meta">Centre Thiès · 15/06/2025</div>
                  <div class="fraud-item__tags">
                    <span class="reason-tag">Document similaire existant</span>
                  </div>
                </div>
                <span class="fraud-item__arrow">›</span>
              </div>
              <div class="fraud-item">
                <div class="risk-pill risk-pill--medium">52</div>
                <div class="fraud-item__body">
                  <div class="fraud-item__name">Fall Ibrahima — Décès</div>
                  <div class="fraud-item__meta">Centre Kaolack · 14/06/2025</div>
                  <div class="fraud-item__tags">
                    <span class="reason-tag">Incohérence données</span>
                  </div>
                </div>
                <span class="fraud-item__arrow">›</span>
              </div>
            </ng-container>
          </div>
        </div>

        <div class="card fade-up delay-4">
          <div class="card__header">
            <div>
              <div class="card__title">🏢 Centres à risque élevé</div>
              <div class="card__sub">Top 5 par taux de fraude</div>
            </div>
            <a class="card__action" routerLink="/centres">Voir →</a>
          </div>
          <div class="card__body">
            <div *ngFor="let c of topCentres" style="margin-bottom:14px;">
              <div style="display:flex;justify-content:space-between;margin-bottom:5px;">
                <span style="font-size:13px;font-weight:600;">{{ c.nom }}</span>
                <span class="mono" style="font-size:12px;font-weight:700;"
                      [style.color]="riskColor(c.taux)">{{ c.taux }}%</span>
              </div>
              <div class="progress">
                <div class="progress-fill"
                     [style.width]="c.taux + '%'"
                     [style.background]="riskColor(c.taux)"></div>
              </div>
            </div>

            <!-- DEMO -->
            <ng-container *ngIf="topCentres.length === 0">
              <div *ngFor="let c of demoCentres" style="margin-bottom:14px;">
                <div style="display:flex;justify-content:space-between;margin-bottom:5px;">
                  <span style="font-size:13px;font-weight:600;">{{ c.nom }}</span>
                  <span class="mono" style="font-size:12px;font-weight:700;" [style.color]="riskColor(c.taux)">{{ c.taux }}%</span>
                </div>
                <div class="progress">
                  <div class="progress-fill" [style.width]="c.taux+'%'" [style.background]="riskColor(c.taux)"></div>
                </div>
              </div>
            </ng-container>
          </div>
        </div>
      </div>

      <!-- ROW 4: TYPES DONUT + ACTIVITÉ -->
      <div style="display:grid; grid-template-columns:1fr 2fr; gap:18px; margin-bottom:22px;">
        <div class="card fade-up">
          <div class="card__header">
            <div>
              <div class="card__title">Répartition des actes</div>
              <div class="card__sub">Par type d'état civil</div>
            </div>
          </div>
          <div class="card__body">
            <canvas #chartTypes height="200"></canvas>
          </div>
        </div>

        <div class="card fade-up delay-1">
          <div class="card__header">
            <div>
              <div class="card__title">Activité récente</div>
              <div class="card__sub">Dernières actions agents</div>
            </div>
            <a class="card__action" routerLink="/audit">Voir logs →</a>
          </div>
          <div class="card__body" style="padding:0 22px;">
            <table class="ds-table">
              <thead>
                <tr>
                  <th>Heure</th><th>Agent</th><th>Action</th><th>Réf. acte</th><th>Statut</th>
                </tr>
              </thead>
              <tbody>
                <tr *ngFor="let row of demoActivity">
                  <td class="mono" style="color:var(--muted);font-size:11px;">{{ row.time }}</td>
                  <td style="font-weight:600;">{{ row.agent }}</td>
                  <td>{{ row.action }}</td>
                  <td class="mono" style="font-size:11px;">{{ row.ref }}</td>
                  <td><span class="badge" [class]="'badge--' + row.badgeClass">{{ row.statut }}</span></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </div>
  `
})
export class DashboardComponent implements OnInit, AfterViewInit {
  @ViewChild('chartEvo')   chartEvoRef!: ElementRef<HTMLCanvasElement>;
  @ViewChild('chartGauge') chartGaugeRef!: ElementRef<HTMLCanvasElement>;
  @ViewChild('chartTypes') chartTypesRef!: ElementRef<HTMLCanvasElement>;

  today = new Date();
  userName = 'Admin';
  stats: DashboardStats = {
    total_actes:0, actes_valides:0, actes_attente:0, fraudes_detectees:0,
    doublons_detectes:0, risk_score:0, centres_connectes:0, citoyens_enregistres:0
  };
  actesSuspects: Acte[] = [];
  topCentres: any[] = [];
  riskCounter = 0;

  get validRate() {
    if (!this.stats.total_actes) return 0;
    return Math.round(this.stats.actes_valides / this.stats.total_actes * 100);
  }
  get gaugeColor() {
    const s = this.stats.risk_score;
    return s >= 70 ? 'var(--danger)' : s >= 40 ? 'var(--warning)' : 'var(--green)';
  }

  riskColor(taux: number) {
    return taux >= 70 ? 'var(--danger)' : taux >= 40 ? 'var(--warning)' : 'var(--green)';
  }
  riskPillClass(score: number) {
    return score >= 70 ? 'risk-pill risk-pill--high' : score >= 40 ? 'risk-pill risk-pill--medium' : 'risk-pill risk-pill--low';
  }
  typeLabel(t: string) {
    return {NAISSANCE:'Naissance',MARIAGE:'Mariage',DECES:'Décès',DIVORCE:'Divorce'}[t] ?? t;
  }

  demoCentres = [
    { nom: 'Centre Dakar Médina', taux: 78 }, { nom: 'Centre Thiès Nord', taux: 61 },
    { nom: 'Centre Kaolack Central', taux: 48 }, { nom: 'Centre Ziguinchor', taux: 35 },
    { nom: 'Centre Saint-Louis', taux: 18 }
  ];

  demoActivity = [
    { time:'14:32', agent:'A. Diallo', action:'Scan IA', ref:'ACT-2025-0482', statut:'Valide', badgeClass:'green' },
    { time:'14:18', agent:'M. Ndiaye', action:'Création acte', ref:'ACT-2025-0481', statut:'En attente', badgeClass:'orange' },
    { time:'13:55', agent:'F. Sow', action:'Validation', ref:'ACT-2025-0479', statut:'Valide', badgeClass:'green' },
    { time:'13:41', agent:'I. Fall', action:'Scan IA', ref:'ACT-2025-0478', statut:'Suspect', badgeClass:'red' },
    { time:'13:20', agent:'A. Diallo', action:'Upload doc', ref:'ACT-2025-0477', statut:'Valide', badgeClass:'green' },
    { time:'12:58', agent:'M. Ba', action:'Création acte', ref:'ACT-2025-0476', statut:'En attente', badgeClass:'orange' },
  ];

  constructor(private api: ApiService, private auth: AuthService) {}

  ngOnInit() {
    this.userName = this.auth.getUserName();
    this.loadAll();
  }

  loadAll() {
    this.api.getDashboardStats().subscribe(s => {
      this.stats = s;
      this.animateRisk(s.risk_score || 34);
    });
    this.api.getActesSuspects().subscribe(a => this.actesSuspects = a.slice(0,4));
    this.api.getTopCentresRisque().subscribe(c => this.topCentres = c.slice(0,5));
  }

  animateRisk(target: number) {
    let count = 0;
    const interval = setInterval(() => {
      count += Math.ceil(target / 40);
      if (count >= target) { count = target; clearInterval(interval); }
      this.riskCounter = count;
    }, 25);
  }

  ngAfterViewInit() {
    // Evolution chart
    new Chart(this.chartEvoRef.nativeElement, {
      type: 'line',
      data: {
        labels: ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'],
        datasets: [
          { label:'Naissances', data:[320,295,342,380,360,410,395,420,445,398,430,452], borderColor:'#5780FA', backgroundColor:'rgba(87,128,250,.07)', tension:.4, fill:true, pointRadius:3 },
          { label:'Mariages', data:[120,98,145,132,160,178,155,188,202,175,192,210], borderColor:'#1E8449', backgroundColor:'rgba(30,132,73,.05)', tension:.4, fill:true, pointRadius:3 },
          { label:'Décès', data:[65,72,58,80,74,68,82,75,90,85,78,92], borderColor:'#E67E22', backgroundColor:'rgba(230,126,34,.05)', tension:.4, fill:true, pointRadius:3 },
        ]
      },
      options: {
        responsive:true, interaction:{mode:'index', intersect:false},
        plugins:{ legend:{labels:{font:{family:'Montserrat',size:11}, boxWidth:10}} },
        scales: {
          x:{ grid:{display:false}, ticks:{font:{family:'Montserrat',size:10}} },
          y:{ grid:{color:'#F1F3F9'}, ticks:{font:{family:'Montserrat',size:10}} }
        }
      }
    });

    // Gauge chart
    const riskScore = this.stats.risk_score || 34;
    const gaugeColor = riskScore >= 70 ? '#C0392B' : riskScore >= 40 ? '#E67E22' : '#1E8449';
    new Chart(this.chartGaugeRef.nativeElement, {
      type: 'doughnut',
      data: {
        datasets: [{
          data: [riskScore, 100-riskScore],
          backgroundColor: [gaugeColor, '#F1F3F9'],
          borderWidth: 0,
          circumference: 220,
          rotation: 250,
        } as any]
      },
      options: {
        responsive:false, cutout:'78%',
        plugins:{ legend:{display:false}, tooltip:{enabled:false} },
        animation:{ duration:1200, easing:'easeOutQuart' }
      }
    });

    // Types donut
    new Chart(this.chartTypesRef.nativeElement, {
      type: 'doughnut',
      data: {
        labels: ['Naissances','Mariages','Décès','Divorces'],
        datasets: [{ data:[52,28,15,5], backgroundColor:['#5780FA','#1E8449','#E67E22','#C0392B'], borderWidth:0, hoverOffset:8 }]
      },
      options: {
        responsive:true, cutout:'68%',
        plugins:{ legend:{position:'bottom', labels:{font:{family:'Montserrat',size:11}, padding:12, boxWidth:10}} }
      }
    });
  }
}