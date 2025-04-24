Shiny.addCustomMessageHandler('startCounters', function(message) {
  const easingOutSlow = function (t, b, c, d) {
    return c * (-Math.pow(2, -10 * t / d) + 1) + b; // easeOutExpo
  };

  const opts = {
    duration: 1.5, // Increase duration for dramatic effect
    separator: ',',
    useEasing: true,
    easingFn: easingOutSlow
  };

  const obs = new countUp.CountUp(message.ns + 'count-observations', message.total, opts);
  const species = new countUp.CountUp(message.ns + 'count-species', message.unique, opts);
  const last = new countUp.CountUp(message.ns + 'count-lastdate', message.last, opts);

  if (!obs.error) obs.start(); else console.error(obs.error);
  if (!species.error) species.start(); else console.error(species.error);
  if (!last.error) last.start(); else console.error(last.error);
});
