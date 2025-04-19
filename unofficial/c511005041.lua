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
	return (c:IsTrap() and c:IsType(TYPE_CONTINUOUS)) and c:IsReleasable() and (not tp or Duel.GetMZoneCount(tp,c)>0)
end
function s.spcon(e,c)
	if c==nil then return true end
	local g=Duel.GetMatchingGroup(s.spfilter,c:GetControler(),LOCATION_ONFIELD,0,nil,tp)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_CANNOT_RELEASE) and #g>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
	local dg=sg:Filter(Card.IsFacedown,nil)
    	if #dg>0 then
		Duel.ConfirmCards(1-tp,dg)
	end
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end