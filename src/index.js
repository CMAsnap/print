const createApp = require('./app');
const enableDestroy = require('server-destroy');
const BPromise = require('bluebird');
const logger = require('./util/logger')(__filename);
const config = require('./config');

BPromise.config({
  warnings: config.NODE_ENV !== 'production',
  longStackTraces: true,
});

const app = createApp();
const PORT = process.env.PORT || config.PORT || 8080;
const HOST = '0.0.0.0';

const server = app.listen(PORT, HOST, () => {
  logger.info(
    'Express server listening on http://%s:%d/ in %s mode',
    HOST,
    PORT,
    app.get('env')
  );
});
enableDestroy(server);

function closeServer(signal) {
  logger.info(`${signal} received`);
  logger.info('Closing http.Server ..');
  server.destroy();
}

// Handle signals gracefully. Heroku will send SIGTERM before idle.
process.on('SIGTERM', closeServer.bind(this, 'SIGTERM'));
process.on('SIGINT', closeServer.bind(this, 'SIGINT(Ctrl-C)'));

server.on('close', () => {
  logger.info('Server closed');
  process.emit('cleanup');

  logger.info('Giving 100ms time to cleanup..');
  // Give a small time frame to clean up
  setTimeout(process.exit, 100);
});
