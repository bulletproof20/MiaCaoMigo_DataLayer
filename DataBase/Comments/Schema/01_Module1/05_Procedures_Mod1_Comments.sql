-- =========================================================
-- comments: procedures - module 1 (schema / technical)
-- =========================================================

comment on procedure sp_auto_close_clock_in_midnight() is
'automatically closes open employee clock-in sessions from previous days by assigning midnight as the closing timestamp';

comment on procedure sp_auto_cancel_expired_absences() is
'automatically cancels pending absences whose scheduled absence interval has already expired';
