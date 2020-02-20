-- Acrobatic Circus
local s,id=GetID()

function s.initial_effect(c)
	aux.CallToken(301)
end

s.af="a"

s.tableAction = {
150000024,
150000033,
150000042,
150000071
}