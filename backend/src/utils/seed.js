const bcrypt = require('bcryptjs');
const User = require('../models/user');
const Post = require('../models/post');
const Comment = require('../models/comment');

async function ensureBotUser() {
  const botEmail = process.env.BOT_EMAIL || 'bot@example.com';
  const botUsername = process.env.BOT_USERNAME || 'demo_bot';
  const botPassword = process.env.BOT_PASSWORD || 'password123';

  let bot = await User.findOne({ email: botEmail });
  if (!bot) {
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(botPassword, salt);
    bot = await User.create({
      username: botUsername,
      email: botEmail,
      password: hash,
      fullName: 'Demo Bot',
      bio: 'I auto-generate content for demos',
      profileImageUrl: 'https://i.pravatar.cc/150?img=12',
    });
  }
  return bot;
}

async function seedSampleContent(bot) {
  const existing = await Post.find({ author: bot._id }).countDocuments();
  const target = Number(process.env.BOT_POST_COUNT || 6);
  const toCreate = Math.max(0, target - existing);
  if (toCreate === 0) return;

  const postsPayload = Array.from({ length: toCreate }).map((_, i) => ({
    author: bot._id,
    caption: `Demo post #${existing + i + 1}`,
    imageUrl: `https://picsum.photos/seed/demo_${existing + i + 1}/600/800` ,
    music: ''
  }));
  const created = await Post.insertMany(postsPayload);

  // Add a quick comment and like from bot on each post
  for (const p of created) {
    try {
      await Comment.create({
        text: 'Nice shot! #demo',
        author: bot._id,
        post: p._id,
      });
      p.likes.push(bot._id);
      await p.save();
    } catch (_) {}
  }
}

async function seedBotAndContent() {
  try {
    const bot = await ensureBotUser();
    await seedSampleContent(bot);
    return { ok: true, botId: bot._id };
  } catch (err) {
    console.error('Seed error:', err);
    return { ok: false, error: err?.message };
  }
}

module.exports = { seedBotAndContent };


