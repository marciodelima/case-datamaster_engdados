import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Acao } from '../models/acao.model';

@Injectable({ providedIn: 'root' })
export class CarteiraService {
  constructor(private http: HttpClient) {}

  getCarteira(cpf: string): Observable<Acao[]> {
    return this.http.get<Acao[]>(`/api/clientes/${cpf}/carteira`);
  }
}

