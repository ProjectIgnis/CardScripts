--Ｈ・Ｄ・Ｄ
--H.D.D. - Hundred Divine Dragon
--scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Draw until 6 cards in your hand instead of until 5 cards
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	local function get_draw(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0) end
	e2:SetCondition(function(e)return get_draw(e)<6 end)
	e2:SetValue(function(e)return 6-get_draw(e) end)
	c:RegisterEffect(e2)
end