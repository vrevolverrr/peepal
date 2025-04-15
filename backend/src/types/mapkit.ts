import { LatLng } from "@googlemaps/polyline-codec";

export type MapKitAccessToken = {
    accessToken: string
    expiresAt: Date
  }
  
/**
 * Represents a geographical coordinate with latitude and longitude.
 */
export interface MKCoordinate {
    latitude: number;
    longitude: number;
}

/**
 * Represents the origin or destination of the directions.
 */
export interface MKLocationPoint {
    coordinate: MKCoordinate;
}

/**
 * Represents a single route within the directions.
 */
export interface MKRoute {
    name: string;
    distanceMeters: number;
    durationSeconds: number;
    transportType: string; // Could potentially be an enum: 'Walking' | 'Driving' | 'Transit' etc.
    stepIndexes: number[];
    hasTolls: boolean;
}
  
/**
 * Represents a single step in the directions.
 */
export interface MKStep {
    stepPathIndex: number;
    distanceMeters: number;
    durationSeconds: number;
    instructions: string;
}
  
/**
 * Represents the main structure for directions data.
 */
export interface MKDirections {
    origin: MKLocationPoint;
    destination: MKLocationPoint;
    routes: MKRoute[];
    steps: MKStep[];
    stepPaths: MKCoordinate[][];
}

export interface Route {
    overview_polyline: string;
    start_location: LatLng;
    end_location: LatLng;
    distance: string;
    duration: string;
    directions: RouteDirection[];
}

export interface RouteDirection {
    distance: string;
    duration: string;
    polyline: string;
    start_location: LatLng;
    end_location: LatLng;
    instructions: string;
}