--Future Vision
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #sg<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsType,1-tp,LOCATION_DECK,0,nil,TYPE_MONSTER)
	local dcount=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	if dcount==0 then return end
	if #g==0 then
		Duel.ConfirmDecktop(1-tp,dcount)
		return
	end
	local seq=-1
	local tc=g:GetFirst()
	local spcard=nil
	while tc do
		if tc:GetSequence()>seq then 
			seq=tc:GetSequence()
			spcard=tc
		end
		tc=g:GetNext()
	end
	Duel.ConfirmDecktop(1-tp,dcount-seq)
	if sg:IsExists(Card.IsRace,1,nil,spcard:GetRace()) then
		Duel.Recover(1-tp,1000,REASON_EFFECT)
	end
end
