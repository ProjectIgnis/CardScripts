-- 幻竜重騎ウォームＥｘカベーター
--Wurm Ex-Cavator the Heavy Mequestrian Wyrm (Left)
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.maxCon)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
function s.maxCon(e)
	return e:GetHandler():IsMaximumMode()
end
function s.val(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*300
end