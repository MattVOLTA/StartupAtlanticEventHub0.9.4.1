export interface Organization {
  id: string;
  name: string;
  eventbrite_id: string;
}

export interface Event {
  id: string;
  name: string;
  description: string;
  summary: string | null;
  start_date: string;
  end_date: string;
  organization_id: string;
  is_virtual: boolean;
  is_free: boolean;
  status: string;
  url: string;
  logo_url: string | null;
  venue_name: string | null;
  venue_address: string | null;
  venue_city: string | null;
}