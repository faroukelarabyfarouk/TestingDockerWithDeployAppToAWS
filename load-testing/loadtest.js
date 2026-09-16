import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 50 },
    { duration: '1m', target: 90 },
    { duration: '2m', target: 120 },
    { duration: '30s', target: 0 },
  ],
};

export default function () {
  http.get('http://54.242.212.85');
  sleep(0.3);
}
