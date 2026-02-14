/**
 * коллбек отложенного вызова.
 *
 * @param {Function} callback
 * @param {...any} args
 */
export const defer = (callback, ...args) => {
  // ждем следующего кадра чтобы вывести его без мерцания.
  if (typeof requestAnimationFrame === 'function') {
    requestAnimationFrame(() => {
      setTimeout(() => callback(...args), 0);
    });
    return undefined;
  }
  return setTimeout(callback, 0, ...args);
};
