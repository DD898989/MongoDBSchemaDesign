const express = require('express');
const mongoose = require('mongoose');
const models = require('./models');

const app = express();
app.use(express.json());

mongoose.connect('mongodb://mongodb:27017/showcase');

app.post('/api/clear', async (req, res) => {
  await Promise.all([
    models.EmbeddedUser.deleteMany({}),
    models.RefUser.deleteMany({}),
    models.RefOrder.deleteMany({}),
    models.ExtUser.deleteMany({}),
    models.ExtOrder.deleteMany({}),
    models.SubsetProduct.deleteMany({}),
    models.SubsetReview.deleteMany({}),
    models.SensorBucket.deleteMany({}),
    models.AttrProduct.deleteMany({}),
    models.Vehicle.deleteMany({}),
    models.ComputedProduct.deleteMany({}),
    models.VersionedUser.deleteMany({}),
    models.OutlierUser.deleteMany({}),
    models.OutlierOverflow.deleteMany({})
  ]);
  res.json({ ok: true });
});

app.post('/api/patterns/embedded', async (req, res) => {
  const doc = await models.EmbeddedUser.create(req.body);
  res.json(doc);
});

app.post('/api/patterns/embedded/query', async (req, res) => {
  const doc = await models.EmbeddedUser.findById(req.body.id);
  res.json(doc);
});

app.post('/api/patterns/references/users', async (req, res) => {
  const user = await models.RefUser.create(req.body);
  res.json(user);
});

app.post('/api/patterns/references/orders', async (req, res) => {
  const order = await models.RefOrder.create(req.body);
  res.json(order);
});

app.post('/api/patterns/references/orders/query', async (req, res) => {
  const order = await models.RefOrder.findById(req.body.id).populate('userId');
  res.json(order);
});

app.post('/api/patterns/extended-references/users', async (req, res) => {
  const user = await models.ExtUser.create(req.body);
  res.json(user);
});

app.post('/api/patterns/extended-references/orders', async (req, res) => {
  const order = await models.ExtOrder.create(req.body);
  res.json(order);
});

app.post('/api/patterns/extended-references/orders/query', async (req, res) => {
  const order = await models.ExtOrder.findById(req.body.id);
  res.json(order);
});

app.post('/api/patterns/subset/products', async (req, res) => {
  const prod = await models.SubsetProduct.create(req.body);
  res.json(prod);
});

app.post('/api/patterns/subset/reviews', async (req, res) => {
  const review = await models.SubsetReview.create(req.body);
  const prod = await models.SubsetProduct.findById(req.body.productId);
  prod.recentReviews.unshift({ user: req.body.user, rating: req.body.rating });
  if (prod.recentReviews.length > 2) {
    prod.recentReviews = prod.recentReviews.slice(0, 2);
  }
  await prod.save();
  res.json({ review, product: prod });
});

app.post('/api/patterns/bucket/measurements', async (req, res) => {
  const doc = await models.SensorBucket.findOneAndUpdate(
    { sensorId: req.body.sensorId, date: req.body.date },
    { $push: { measurements: { time: req.body.time, temperature: req.body.temperature } } },
    { typeof: true, upsert: true, new: true }
  );
  res.json(doc);
});

app.post('/api/patterns/attributes', async (req, res) => {
  const doc = await models.AttrProduct.create(req.body);
  res.json(doc);
});

app.post('/api/patterns/attributes/query', async (req, res) => {
  const docs = await models.AttrProduct.find();
  res.json(docs);
});

app.post('/api/patterns/polymorphic', async (req, res) => {
  const doc = await models.Vehicle.create(req.body);
  res.json(doc);
});

app.post('/api/patterns/polymorphic/query', async (req, res) => {
  const docs = await models.Vehicle.find();
  res.json(docs);
});

app.post('/api/patterns/computed/products', async (req, res) => {
  const prod = await models.ComputedProduct.create({ name: req.body.name, reviewCount: 0, averageRating: 0, totalSales: 0 });
  res.json(prod);//                                                                      ^^^^^^^^^^^^^TODO 避免數據失真可改成 totalRating
});

app.post('/api/patterns/computed/reviews', async (req, res) => {
  const prod = await models.ComputedProduct.findById(req.body.productId);
  const currentSum = prod.averageRating * prod.reviewCount;
  prod.reviewCount += 1;
  prod.averageRating = (currentSum + req.body.rating) / prod.reviewCount;
  await prod.save();
  res.json(prod);
});

app.post('/api/patterns/computed/sales', async (req, res) => {
  const prod = await models.ComputedProduct.findByIdAndUpdate(
    req.body.productId,
    { $inc: { totalSales: req.body.amount } },
    { new: true }
  );
  res.json(prod);
});

app.post('/api/patterns/versioning', async (req, res) => {
  const doc = await models.VersionedUser.create(req.body);
  res.json(doc);
});

app.post('/api/patterns/versioning/query', async (req, res) => {
  const user = await models.VersionedUser.findById(req.body.id);
  let result = {};
  if (user.schemaVersion === 1) {
    result = {
      schemaVersion: 1,
      fullName: user.name
    };
  } else if (user.schemaVersion === 2) {
    result = {
      schemaVersion: 2,
      fullName: `${user.firstName} ${user.lastName}`
    };
  }
  res.json(result);
});

app.post('/api/patterns/outlier/users', async (req, res) => {
  const user = await models.OutlierUser.create({ name: req.body.name, items: [], hasOverflow: false });
  res.json(user);
});

app.post('/api/patterns/outlier/items', async (req, res) => {
  const user = await models.OutlierUser.findById(req.body.userId);
  if (user.items.length < 5) {
    user.items.push(req.body.item);
    await user.save();
    res.json({ user });
  } else {
    user.hasOverflow = true;
    await user.save();
    const overflow = await models.OutlierOverflow.findOneAndUpdate(
      { userId: req.body.userId },
      { $push: { items: req.body.item } },
      { upsert: true, new: true }
    );
    res.json({ user, overflow });
  }
});

app.listen(8080);
