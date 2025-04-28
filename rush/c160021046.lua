--Ｐ・Ｍ Ｒ－レノアール
--Plasmatic Model Rising Lenoir
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual
	c:EnableReviveLimit()
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler()
end
function s.val(e,c)
	return e:GetHandler():GetLevel()*200
end