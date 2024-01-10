--エキサイト・グランド・ドラゴン
--Excite Ground Dragon
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Draw until 6 cards in your hand instead of until 5 cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	local function get_draw(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0) end
	e1:SetCondition(s.condition)
	e1:SetValue(function(e)return 6-get_draw(e) end)
	c:RegisterEffect(e1)
end
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<6 and Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(aux.TRUE),tp,0,LOCATION_MZONE,nil)==3
end