--トポロジック・ガンブラー・ドラゴン
--Topologic Gumblar Dragon
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	--discard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.hdcon)
	e1:SetTarget(s.hdtg)
	e1:SetOperation(s.hdop)
	c:RegisterEffect(e1)	
	--discard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.hdcon2)
	e2:SetTarget(s.hdtg2)
	e2:SetOperation(s.hdop2)
	c:RegisterEffect(e2)
end
function s.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return (ec:GetLinkedZone(c:GetPreviousControler())&(1<<c:GetPreviousSequence()))~=0
	end
end
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	for tc in aux.Next(Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK)) do
		if eg:IsExists(s.cfilter,1,nil,tc) then return true end
	end
	return false
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rt1=math.min(Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT),2)
	if rt1>0 then
		local rt2=math.min(Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT),2)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,math.min(rt1,rt2))
	end
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT)
	if ct==0 then return end
	local sel
	if ct<2 then sel=1 else Duel.Hint(HINT_SELECTMSG,tp,565) sel=Duel.AnnounceNumber(tp,1,2) end
	local g1=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT):RandomSelect(tp,sel)
	local rt=Duel.SendtoGrave(g1,REASON_EFFECT+REASON_DISCARD)
	if rt==0 or rt>Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT) then return end
	local g2=Duel.GetMatchingGroup(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT):Select(1-tp,rt,rt,nil)
	Duel.SendtoGrave(g2,REASON_EFFECT+REASON_DISCARD)
end
function s.hdcon2(e)
	return e:GetHandler():IsExtraLinked()
end
function s.hdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,2)
end
function s.hdop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=2
	if Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)==1 then ct=1 end
	if Duel.DiscardHand(1-tp,nil,ct,ct,REASON_EFFECT+REASON_DISCARD)~=0
		and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)==0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,3000,REASON_EFFECT)
	end
end

