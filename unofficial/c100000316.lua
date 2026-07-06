--ラスオブタクス・マンモス (Anime)
--Last Tusk Mammoth (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Both players take battle damage from this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ALSO_BATTLE_DAMAGE)
	c:RegisterEffect(e1)
end
