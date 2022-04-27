--デーモンの召喚
--Summoned Skull (Rush)
local s,id=GetID()
function s.initial_effect(c)
	Card.Alias(c,CARD_SUMMONED_SKULL)
end