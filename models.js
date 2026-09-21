const mongoose = require('mongoose');

const EmbeddedUser = mongoose.model('EmbeddedUser', new mongoose.Schema({
  name: { type: String },
  address: {
    city: { type: String },
    zip: { type: String }
  }
}));

const RefUser = mongoose.model('RefUser', new mongoose.Schema({
  name: { type: String }
}));

const RefOrder = mongoose.model('RefOrder', new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'RefUser' },
  amount: { type: Number }
}));

const ExtUser = mongoose.model('ExtUser', new mongoose.Schema({
  name: { type: String }
}));

const ExtOrder = mongoose.model('ExtOrder', new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId },
  userName: { type: String },
  amount: { type: Number }
}));

const SubsetProduct = mongoose.model('SubsetProduct', new mongoose.Schema({
  name: { type: String },
  recentReviews: [
    {
      user: { type: String },
      rating: { type: Number }
    }
  ]
}));

const SubsetReview = mongoose.model('SubsetReview', new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId },
  user: { type: String },
  rating: { type: Number },
  comment: { type: String }
}));

const SensorBucket = mongoose.model('SensorBucket', new mongoose.Schema({
  sensorId: { type: String },
  date: { type: String },
  measurements: [
    {
      time: { type: String },
      temperature: { type: Number }
    }
  ]
}));

const AttrProduct = mongoose.model('AttrProduct', new mongoose.Schema({
  name: { type: String },
  attributes: [
    {
      k: { type: String },
      v: { type: String }
    }
  ]
}));

const Vehicle = mongoose.model('Vehicle', new mongoose.Schema({
  type: { type: String },
  doors: { type: Number },
  engine: { type: String },
  hasSidecar: { type: Boolean }
}, { strict: false }));

const ComputedProduct = mongoose.model('ComputedProduct', new mongoose.Schema({
  name: { type: String },
  reviewCount: { type: Number },
  averageRating: { type: Number },
  totalSales: { type: Number }
}));

const VersionedUser = mongoose.model('VersionedUser', new mongoose.Schema({
  schemaVersion: { type: Number },
  name: { type: String },
  firstName: { type: String },
  lastName: { type: String }
}, { strict: false }));

const OutlierUser = mongoose.model('OutlierUser', new mongoose.Schema({
  name: { type: String },
  items: [{ type: String }],
  hasOverflow: { type: Boolean }
}));

const OutlierOverflow = mongoose.model('OutlierOverflow', new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId },
  items: [{ type: String }]
}));

module.exports = {
  EmbeddedUser,
  RefUser,
  RefOrder,
  ExtUser,
  ExtOrder,
  SubsetProduct,
  SubsetReview,
  SensorBucket,
  AttrProduct,
  Vehicle,
  ComputedProduct,
  VersionedUser,
  OutlierUser,
  OutlierOverflow
};
