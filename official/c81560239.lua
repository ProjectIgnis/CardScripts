--巳剣降臨
--Mitsurugi Ritual
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.deckmatfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsReleasableByEffect()
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.deckmatfilter,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.ReleaseRitualMaterial(mat,true)
end
function s.tributelimit(e,tp,g,sc)
	return #g<=2,#g>2
end
local ritual_params1={lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_DECK,matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE)}
local ritual_params2={lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),matfilter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.tributelimit}
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local b1=not Duel.HasFlagEffect(tp,id) and Ritual.Target(ritual_params1)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=not Duel.HasFlagEffect(tp,id+1) and Ritual.Target(ritual_params2)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cost_skip=e:GetLabel()~=-100
	local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and Ritual.Target(ritual_params1)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=(cost_skip or not Duel.HasFlagEffect(tp,id+1))
		and Ritual.Target(ritual_params2)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then e:SetLabel(0) return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	elseif op==2 then
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Ritual.Operation(ritual_params1)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		Ritual.Operation(ritual_params2)(e,tp,eg,ep,ev,re,r,rp)
	end
end
