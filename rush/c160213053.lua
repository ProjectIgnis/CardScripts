--栄華夢中のシルビクス
--Fleeting Delirium Silbyx
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
	--Face-up Insect monsters you control cannot be destroyed by your opponent's effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--cannot be used
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.sumlimit)
	c:RegisterEffect(e2)
end
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsRace(RACE_INSECT,fc,sumtype,tp) and c:IsType(TYPE_EFFECT,fc,sumtype,tp) and c:IsLevelBetween(7,9)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_INSECT,fc,sumtype,tp) and c:IsType(TYPE_EFFECT,fc,sumtype,tp)
end
function s.indtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
function s.cond(e,c)
	return c:IsSummonPlayer(1-e:GetHandlerPlayer())
end
function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(1-e:GetHandlerPlayer())
end