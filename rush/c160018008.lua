--ハイブリッドライブ・バリアテイル
--Hybridrive Barriertail
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--summon without tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	--Piercing battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--Face-up Dragon/Machine monsters you control cannot be destroyed by your opponent's effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.indtg)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
end
s.listed_names={160017006}
function s.ntfilter(c)
	return c:IsFaceup() and c:IsCode(160017006)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.indtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON|RACE_MACHINE)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end