--漆黒の戦士 ワーウルフ
--Pitch-Black Warwolf (Rush)
local s,id=GetID()
function s.initial_effect(c)
	--Opponent cannot activate Trap Cards during the Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetValue(s.aclimit)
	c:RegisterEffect(e1)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsTrap() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end