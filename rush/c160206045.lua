--名匠の兜
--Helmet of the Master Craftsman
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--atk/def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val)
	c:RegisterEffectRush(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(200)
	c:RegisterEffectRush(e2)
end
s.listed_names={160206036}
function s.eqfilter(c)
	return c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.val(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	if (ec:IsLegend() and ec:GetOriginalLevel()<=4) or ec:IsCode(160206036) then
		return ec:GetBaseAttack()+200
	end
	return 200
end