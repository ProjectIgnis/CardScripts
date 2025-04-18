--スケアクロー・アクロア
--Scareclaw Acro
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(s.hspval)
	c:RegisterEffect(e1)
	--Boost ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_EMZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(s.sclawfilter))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SCARECLAW}
s.sclawfilter=aux.FaceupFilter(Card.IsSetCard,SET_SCARECLAW)
function s.hspval(e,c)
	local zone=0
	local left_right=0
	local tp=c:GetControler()
	local lg=Duel.GetMatchingGroup(s.sclawfilter,tp,LOCATION_MZONE,0,nil)
	for tc in lg:Iter() do
		left_right=tc:IsInMainMZone() and 1 or 0
		zone=(zone|tc:GetColumnZone(LOCATION_MZONE,left_right,left_right,tp))
	end
	return 0,zone&ZONES_MMZ
end
function s.atkval(e)
	return Duel.GetMatchingGroupCount(Card.IsDefensePos,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*300
end