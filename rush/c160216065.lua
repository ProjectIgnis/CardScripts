--レジェンド・リネージ・マジシャン
--Legend Lineage Magician
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual
	c:EnableReviveLimit()
	--Treated as a Legend Card in the GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IS_LEGEND)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e0)
	--Piercing battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Cannot be changed to Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
	e2:SetCondition(s.poscon)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
end
function s.poscon(e)
	return e:GetHandler():IsAttackPos()
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()==e:GetOwnerPlayer()
end