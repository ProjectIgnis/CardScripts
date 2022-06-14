--ひたひたと迫る足音
--Gradually Approaching Footsteps
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
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_ZOMBIE),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end --Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) 
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.rescon(ft)
	return function(sg,e,tp,mg)
		local fc=sg:FilterCount(Card.IsType,nil,TYPE_FIELD)
		local c1=#sg
		return fc<=1 and (c1-fc<=ft or c1>1)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if #hg>0 then
		Duel.ConfirmCards(tp,hg)
		local ft=Duel.GetLocationCount(1-tp,LOCATION_SZONE)
		local g=hg:Filter(s.cfilter,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(#g,ft+1,3),s.rescon(ft),1,tp,HINTMSG_SET)
		if #sg>0 then
			Duel.SSet(1-tp,sg,1-tp,true)
			Duel.Damage(1-tp,#sg*300,REASON_EFFECT)
		end
	end
end