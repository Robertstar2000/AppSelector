const Docker = require('dockerode');
const express = require('express');

module.exports = function registerDockerRoutes(app) {
  const router = express.Router();
  const REQUIRED_TOKEN = process.env.DOCKER_API_TOKEN || '';

  function requireToken(req, res, next) {
    const provided = req.headers['x-docker-token'] || req.query.token || '';
    if (!REQUIRED_TOKEN) {
      console.warn('DOCKER_API_TOKEN not set — Docker-control endpoints will be guarded when set.');
    }
    if (REQUIRED_TOKEN && provided !== REQUIRED_TOKEN) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  }

  router.use(express.json());
  router.use(requireToken);

  // Cross-platform socket path:
  // - On Windows Docker Desktop exposes the named pipe: //./pipe/docker_engine
  // - On Linux/macOS the unix socket is /var/run/docker.sock
  const socketPath = process.platform === 'win32'
    ? '//./pipe/docker_engine'
    : '/var/run/docker.sock';

  const docker = new Docker({ socketPath });

  router.get('/docker/list', async (req, res) => {
    try {
      const containers = await docker.listContainers({ all: true });
      res.json(containers);
    } catch (err) {
      res.status(500).json({ error: err.message || String(err) });
    }
  });

  router.post('/docker/create', async (req, res) => {
    const { Image, Cmd, name, HostConfig } = req.body;
    if (!Image) return res.status(400).json({ error: 'Image is required' });
    try {
      const opts = { Image, Cmd, name, HostConfig };
      const container = await docker.createContainer(opts);
      res.json({ id: container.id });
    } catch (err) {
      res.status(500).json({ error: err.message || String(err) });
    }
  });

  router.post('/docker/:id/start', async (req, res) => {
    try {
      const c = docker.getContainer(req.params.id);
      await c.start();
      res.json({ message: 'started' });
    } catch (err) {
      res.status(500).json({ error: err.message || String(err) });
    }
  });

  router.post('/docker/:id/stop', async (req, res) => {
    try {
      const c = docker.getContainer(req.params.id);
      await c.stop();
      res.json({ message: 'stopped' });
    } catch (err) {
      res.status(500).json({ error: err.message || String(err) });
    }
  });

  app.use('/api', router);
};
