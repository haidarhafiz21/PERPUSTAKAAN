exports.addHours = (h) => {
  const d = new Date();
  d.setHours(d.getHours() + h);
  return d;
};

exports.addDays = (d) => {
  const date = new Date();
  date.setDate(date.getDate() + d);
  return date;
};
 