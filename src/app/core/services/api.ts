import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

// ── Types ────────────────────────────────────────────────────────

export interface DashboardStats {
  total_actes: number;
  actes_valides: number;
  actes_attente: number;
  fraudes_detectees: number;
  doublons_detectes: number;
  risk_score: number;
  centres_connectes: number;
  citoyens_enregistres: number;
  alertes_critiques?: number;
}

export interface Citoyen {
  id: string;
  nom: string;
  prenom: string;
  date_naissance: string;
  numero_identification: string;
  created_at?: string;
  centre?: string;
  centre_nom?: string;
  actes?: Acte[];
}

export interface Acte {
  id: string;
  numero_acte: string;
  type_acte: 'NAISSANCE' | 'MARIAGE' | 'DECES' | 'DIVORCE';
  statut: 'EN_ATTENTE' | 'VALIDE' | 'SUSPECT' | 'FRAUDE';
  citoyen: string;
  citoyen_nom?: string;
  centre: string;
  centre_nom?: string;
  agent?: string;
  fraud_score?: number;
  risk_level?: 'LOW' | 'MEDIUM' | 'HIGH';
  date_creation: string;
  document_url?: string;
  analyse?: AIAnalysis;
}

export interface Centre {
  id: string;
  code: string;
  nom: string;
  region: string;
  commune: string;
  adresse?: string;
  telephone?: string;
  nb_actes?: number;
  taux_fraude?: number;
}

export interface Document {
  id: string;
  acte: string;
  fichier: string;
  created_at: string;
}

export interface AIAnalysis {
  id: string;
  acte: string;
  numero_acte?: string;
  ocr_text?: string;
  extracted_data: Record<string, unknown>;
  fraud_score: number;
  similarity_score?: number;
  risk_level: 'LOW' | 'MEDIUM' | 'HIGH';
  decision: 'VALID' | 'SUSPECT' | 'FRAUD';
  motifs?: string[];
  created_at: string;
}

export interface Alerte {
  id: string;
  acte: string;
  numero_acte?: string;
  type: string;
  severite: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITIQUE';
  centre: string;
  centre_nom?: string;
  date: string;
  resolu?: boolean;
  fraud_score?: number;
}

export interface ScanResult {
  acte_id?: string;
  ocr_text: string;
  extracted_data: Record<string, string>;
  fraud_score: number;
  risk_level: 'LOW' | 'MEDIUM' | 'HIGH';
  decision: 'VALID' | 'SUSPECT' | 'FRAUD';
  motifs: string[];
  top_match?: unknown;
}

export interface CopilotMessage {
  role: 'user' | 'assistant';
  content: string;
  timestamp?: Date;
}

export interface AuditLog {
  id: string;
  user: string;
  action: string;
  model: string;
  object_id: string;
  ip_address: string;
  created_at: string;
}

export interface Utilisateur {
  id: string;
  nom: string;
  email: string;
  role: 'ADMIN' | 'AGENT';
  centre?: string;
  centre_nom?: string;
  is_active: boolean;
}

export interface SyncStatus {
  centre: string;
  centre_nom?: string;
  derniere_synchro: string;
  statut: 'SYNCED' | 'PENDING' | 'ERROR';
}

export interface Region {
  id: string;
  nom: string;
}

export interface Commune {
  id: string;
  nom: string;
  region?: string;
}

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly base = environment.apiUrl;

  constructor(private http: HttpClient) {}

  private params(obj?: Record<string, string>): HttpParams {
    let p = new HttpParams();
    if (obj) {
      Object.entries(obj).forEach(([k, v]) => {
        if (v) p = p.set(k, v);
      });
    }
    return p;
  }

  // ── DASHBOARD ──────────────────────────────────────────────────
  getDashboardStats(): Observable<DashboardStats> {
    return this.http.get<DashboardStats>(`${this.base}/dashboard/stats/`);
  }
  getEvolution(): Observable<unknown> {
    return this.http.get(`${this.base}/dashboard/evolution/`);
  }
  getActesParCentre(): Observable<unknown> {
    return this.http.get(`${this.base}/dashboard/centres/`);
  }
  getTopCentresRisque(): Observable<{ nom: string; taux: number; fraudes?: number }[]> {
    return this.http.get<{ nom: string; taux: number; fraudes?: number }[]>(`${this.base}/dashboard/top-centres-risque/`);
  }
  getActesSuspects(): Observable<Acte[]> {
    return this.http.get<Acte[]>(`${this.base}/dashboard/actes-suspects/`);
  }
  getFraudesStats(): Observable<unknown> {
    return this.http.get(`${this.base}/dashboard/fraudes/`);
  }
  getIAStats(): Observable<unknown> {
    return this.http.get(`${this.base}/dashboard/ia-stats/`);
  }

  // ── CITOYENS ───────────────────────────────────────────────────
  getCitoyens(params?: Record<string, string>): Observable<Citoyen[] | { results: Citoyen[] }> {
    return this.http.get<Citoyen[] | { results: Citoyen[] }>(`${this.base}/citoyens/`, { params: this.params(params) });
  }
  getCitoyen(id: string): Observable<Citoyen> {
    return this.http.get<Citoyen>(`${this.base}/citoyens/${id}/`);
  }
  createCitoyen(data: Partial<Citoyen>): Observable<Citoyen> {
    return this.http.post<Citoyen>(`${this.base}/citoyens/`, data);
  }
  updateCitoyen(id: string, data: Partial<Citoyen>): Observable<Citoyen> {
    return this.http.patch<Citoyen>(`${this.base}/citoyens/${id}/`, data);
  }
  deleteCitoyen(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/citoyens/${id}/`);
  }

  // ── ACTES ──────────────────────────────────────────────────────
  getActes(params?: Record<string, string>): Observable<Acte[] | { results: Acte[] }> {
    return this.http.get<Acte[] | { results: Acte[] }>(`${this.base}/actes/`, { params: this.params(params) });
  }
  getActe(id: string): Observable<Acte> {
    return this.http.get<Acte>(`${this.base}/actes/${id}/`);
  }
  createActe(data: Partial<Acte>): Observable<Acte> {
    return this.http.post<Acte>(`${this.base}/actes/`, data);
  }
  updateStatutActe(id: string, statut: string): Observable<Acte> {
    return this.http.patch<Acte>(`${this.base}/actes/${id}/`, { statut });
  }
  deleteActe(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/actes/${id}/`);
  }

  // ── CENTRES ────────────────────────────────────────────────────
  getCentres(): Observable<Centre[]> {
    return this.http.get<Centre[]>(`${this.base}/centres/`);
  }
  getCentre(id: string): Observable<Centre> {
    return this.http.get<Centre>(`${this.base}/centres/${id}/`);
  }
  createCentre(data: Partial<Centre>): Observable<Centre> {
    return this.http.post<Centre>(`${this.base}/centres/`, data);
  }
  updateCentre(id: string, data: Partial<Centre>): Observable<Centre> {
    return this.http.patch<Centre>(`${this.base}/centres/${id}/`, data);
  }
  deleteCentre(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/centres/${id}/`);
  }

  // ── RÉGIONS / COMMUNES ─────────────────────────────────────────
  getRegions(): Observable<Region[]> {
    return this.http.get<Region[]>(`${this.base}/regions/`);
  }
  getCommunes(): Observable<Commune[]> {
    return this.http.get<Commune[]>(`${this.base}/communes/`);
  }

  // ── DOCUMENTS ──────────────────────────────────────────────────
  uploadDocument(acteId: string, file: File): Observable<Document> {
    const fd = new FormData();
    fd.append('acte', acteId);
    fd.append('fichier', file);
    return this.http.post<Document>(`${this.base}/documents/`, fd);
  }
  getDocuments(): Observable<Document[]> {
    return this.http.get<Document[]>(`${this.base}/documents/`);
  }
  getDocument(id: string): Observable<Document> {
    return this.http.get<Document>(`${this.base}/documents/${id}/`);
  }
  deleteDocument(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/documents/${id}/`);
  }

  // ── SCAN IA ────────────────────────────────────────────────────
  scanDocument(acteId: string, file: File): Observable<ScanResult> {
    const fd = new FormData();
    fd.append('acte', acteId);
    fd.append('fichier', file);
    return this.http.post<ScanResult>(`${this.base}/scan/`, fd);
  }

  // ── ANALYSES IA ────────────────────────────────────────────────
  getAnalyses(): Observable<AIAnalysis[]> {
    return this.http.get<AIAnalysis[]>(`${this.base}/analyses/`);
  }
  getAnalyse(id: string): Observable<AIAnalysis> {
    return this.http.get<AIAnalysis>(`${this.base}/analyses/${id}/`);
  }
  getAnalysesFraudes(): Observable<AIAnalysis[]> {
    return this.http.get<AIAnalysis[]>(`${this.base}/analyses/fraudes/`);
  }
  getAnalyseComparison(id: string): Observable<unknown> {
    return this.http.get(`${this.base}/analyses/${id}/comparison/`);
  }

  // ── ALERTES ────────────────────────────────────────────────────
  getAlertes(): Observable<Alerte[]> {
    return this.http.get<Alerte[]>(`${this.base}/alertes/`);
  }
  resoudreAlerte(id: string): Observable<Alerte> {
    return this.http.patch<Alerte>(`${this.base}/alertes/${id}/`, { resolu: true });
  }

  // ── COPILOT ────────────────────────────────────────────────────
  askCopilot(question: string, history: CopilotMessage[]): Observable<{ response: string }> {
    return this.http.post<{ response: string }>(`${this.base}/copilot/`, {
      question,
      history: history.map(m => ({ role: m.role, content: m.content })),
    });
  }

  // ── UTILISATEURS ───────────────────────────────────────────────
  getUsers(): Observable<Utilisateur[]> {
    return this.http.get<Utilisateur[]>(`${this.base}/users/`);
  }
  getUser(id: string): Observable<Utilisateur> {
    return this.http.get<Utilisateur>(`${this.base}/users/${id}/`);
  }
  createUser(data: Partial<Utilisateur>): Observable<Utilisateur> {
    return this.http.post<Utilisateur>(`${this.base}/users/`, data);
  }
  updateUser(id: string, data: Partial<Utilisateur>): Observable<Utilisateur> {
    return this.http.patch<Utilisateur>(`${this.base}/users/${id}/`, data);
  }

  // ── AUDIT ──────────────────────────────────────────────────────
  getAuditLogs(): Observable<AuditLog[]> {
    return this.http.get<AuditLog[]>(`${this.base}/audit/`);
  }

  // ── SYNCHRONISATION ────────────────────────────────────────────
  getSyncStatus(): Observable<SyncStatus[]> {
    return this.http.get<SyncStatus[]>(`${this.base}/synchronisation/statut/`);
  }
  envoyerSync(data: unknown): Observable<unknown> {
    return this.http.post(`${this.base}/synchronisation/envoyer/`, data);
  }
}
