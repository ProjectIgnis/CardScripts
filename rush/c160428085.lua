--ひたひたと迫る足音
--I Hear Footsteps
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_DRAW and ep==1-tp and r==REASON_RULE
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_ZOMBIE),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.cfilter(c,tp)
	return c:IsSpellTrap() and c:IsSSetable(false, 1-tp)
end
function s.rescon(ft)
	return function(sg,e,tp,mg)
		local fc=sg:FilterCount(Card.IsType,nil,TYPE_FIELD)
		local total=#sg
		return fc<=1 and (total-fc<=ft)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #hg>0 then
		Duel.ConfirmCards(tp,hg)
		local ft=Duel.GetLocationCount(1-tp,LOCATION_SZONE)
		local g=hg:Filter(s.cfilter,nil,tp)
		local ct=math.min(#g,ft+1,3)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,s.rescon(ft),1,tp,HINTMSG_SET)
		if #sg>0 then
			Duel.SSet(1-tp,sg,1-tp,true)
			Duel.Damage(1-tp,#sg*300,REASON_EFFECT)
		end
		Duel.ShuffleHand(1-tp)
	end
end
