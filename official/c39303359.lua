--古代の機械騎士
--Ancient Gear Knight
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--Opponent cannot activate Spell/Trap cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(function(e) return Gemini.EffectStatusCondition(e) and Duel.GetAttacker()==e:GetHandler() end)
	e1:SetValue(function(_,re) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	c:RegisterEffect(e1)
end