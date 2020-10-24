--トラップリン
--Traplin
--By Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,tp)
	return (c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)) and c:IsReleasable() 
end
function s.spcon(e,c)
	if c==nil then return true end
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_CANNOT_RELEASE) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    	if g:IsFacedown() then
		Duel.ConfirmCards(1-tp,g)
	end
	if g then
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST+REASON_RELEASE)
end
