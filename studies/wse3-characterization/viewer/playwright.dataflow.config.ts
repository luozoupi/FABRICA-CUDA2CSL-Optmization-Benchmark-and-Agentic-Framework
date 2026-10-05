import {defineConfig} from '@playwright/test';
export default defineConfig({testDir:'./dataflow-tests',workers:1,
  use:{baseURL:'http://127.0.0.1:8791',viewport:{width:1680,height:1100},
    launchOptions:{args:['--no-sandbox','--enable-unsafe-swiftshader']}},
  webServer:{command:'python ../tools/dataflow_server.py --port 8791',url:'http://127.0.0.1:8791/api/health',reuseExistingServer:false},
});
