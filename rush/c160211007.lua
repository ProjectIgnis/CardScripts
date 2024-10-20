--ディープスペース・ユグドラゴ
--Deep Space Yggdrago
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e0=Fusion.AddProcMixN(c,true,true,160211009,3)[1]
	e0:SetDescription(aux.Stringid(id,0))
	local e4=Fusion.AddProcMix(c,true,true,160211009,s.ffilter)[1]
	e4:SetDescription(aux.Stringid(id,1))
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3001)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Inflict piercing battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--Atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,7))
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsCode(160211009) and c:IsHasEffect(160019011)
end