exports.topup = async (req, res) => {
  const { user_id, amount } = req.body;

  if (!user_id || !amount) {
    return res.status(400).json({
      message: 'user_id dan amount wajib diisi',
    });
  }

  if (amount < 20500) {
    return res.status(400).json({
      message: 'Minimal topup Rp20.500',
    });
  }

  try {
    await Wallet.addBalance(user_id, amount);
    res.json({
      message: 'Topup berhasil',
      amount,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
