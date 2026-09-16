import http from 'k6/http';
import { sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL;

if (!BASE_URL) {
  throw new Error('BASE_URL environment variable is required');
}

export const options = {
  stages: [
    { duration: '30s', target: 50 },
    { duration: '1m', target: 90 },
    { duration: '2m', target: 120 },
    { duration: '30s', target: 0 },
  ],
};

export default function () {
  http.get(BASE_URL);
  sleep(0.3);
}
