import { defineConfig } from 'vite';
const page=process.env.VIZ_PAGE;
export default defineConfig({ base: './', server: {proxy:{'/api':'http://127.0.0.1:8765'}}, build: {
  target: 'es2022',
  outDir:page?`dist/${page}`:'dist',
  ...(page?{rollupOptions:{input:`${page}.html`}}:{}),
} });
