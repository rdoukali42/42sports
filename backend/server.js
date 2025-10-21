const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// In-memory storage (replace with database in production)
let users = {};
let events = {};
let tournaments = {};
let teams = {};

// Helper to get local IP
const os = require('os');
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

// Routes

// Health check
app.get('/', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: '42Sports Backend Server',
    ip: getLocalIP(),
    port: PORT
  });
});

// User routes
app.get('/api/users/:id', (req, res) => {
  const user = users[req.params.id];
  if (user) {
    res.json(user);
  } else {
    res.status(404).json({ error: 'User not found' });
  }
});

app.post('/api/users', (req, res) => {
  const user = req.body;
  users[user.id] = user;
  res.status(201).json(user);
});

app.put('/api/users/:id', (req, res) => {
  const user = req.body;
  users[req.params.id] = user;
  res.json(user);
});

// Event routes
app.get('/api/events', (req, res) => {
  const eventList = Object.values(events);
  res.json(eventList);
});

app.get('/api/events/:id', (req, res) => {
  const event = events[req.params.id];
  if (event) {
    res.json(event);
  } else {
    res.status(404).json({ error: 'Event not found' });
  }
});

app.post('/api/events', (req, res) => {
  const event = req.body;
  events[event.id] = event;
  res.status(201).json(event);
});

app.put('/api/events/:id', (req, res) => {
  const event = req.body;
  events[req.params.id] = event;
  res.json(event);
});

app.delete('/api/events/:id', (req, res) => {
  delete events[req.params.id];
  res.status(204).send();
});

// Tournament routes
app.get('/api/tournaments', (req, res) => {
  const tournamentList = Object.values(tournaments);
  res.json(tournamentList);
});

app.get('/api/tournaments/:id', (req, res) => {
  const tournament = tournaments[req.params.id];
  if (tournament) {
    res.json(tournament);
  } else {
    res.status(404).json({ error: 'Tournament not found' });
  }
});

app.post('/api/tournaments', (req, res) => {
  const tournament = req.body;
  tournaments[tournament.id] = tournament;
  res.status(201).json(tournament);
});

app.put('/api/tournaments/:id', (req, res) => {
  const tournament = req.body;
  tournaments[req.params.id] = tournament;
  res.json(tournament);
});

app.delete('/api/tournaments/:id', (req, res) => {
  delete tournaments[req.params.id];
  res.status(204).send();
});

// Team routes
app.get('/api/teams', (req, res) => {
  const teamList = Object.values(teams);
  const { tournamentId } = req.query;
  
  if (tournamentId) {
    const filtered = teamList.filter(t => t.tournamentId === tournamentId);
    res.json(filtered);
  } else {
    res.json(teamList);
  }
});

app.get('/api/teams/:id', (req, res) => {
  const team = teams[req.params.id];
  if (team) {
    res.json(team);
  } else {
    res.status(404).json({ error: 'Team not found' });
  }
});

app.post('/api/teams', (req, res) => {
  const team = req.body;
  teams[team.id] = team;
  res.status(201).json(team);
});

app.put('/api/teams/:id', (req, res) => {
  const team = req.body;
  teams[req.params.id] = team;
  res.json(team);
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  const localIP = getLocalIP();
  console.log('\n🚀 42Sports Backend Server Started!');
  console.log('=====================================');
  console.log(`📱 Local:   http://localhost:${PORT}`);
  console.log(`📱 Network: http://${localIP}:${PORT}`);
  console.log('=====================================\n');
  console.log('📝 Use the Network URL on your phone when connected to the same WiFi\n');
});
