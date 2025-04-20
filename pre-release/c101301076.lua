--帝王の極致
--Culmination of the Monarchs
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MONARCH}
function s.effcostfilter(c)
	return c:IsSetCard(SET_MONARCH) and c:IsSpellTrap() and c:IsAbleToRemoveAsCost()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then return Duel.IsExistingMatchingCard(s.effcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.effcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cost_skip=e:GetLabel()~=-100
	--Destroy 1 monster on the field
	local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	--Destroy up to 2 Spells/Traps on the field
	local b2=(cost_skip or not Duel.HasFlagEffect(tp,id+100))
		and Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	--Discard 1 random card from your opponent's hand
	local b3=(cost_skip or not Duel.HasFlagEffect(tp,id+200))
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,0,LOCATION_HAND,1,nil,REASON_EFFECT)
	--Destroy 1 face-down card on the field
	local b4=(cost_skip or not Duel.HasFlagEffect(tp,id+300))
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	--Place 1 card on the field on top of the Deck
	local b5=(cost_skip or not Duel.HasFlagEffect(tp,id+400))
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	--Banish 1 card on the field
	local b6=(cost_skip or not Duel.HasFlagEffect(tp,id+500))
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then e:SetLabel(0) return Duel.IsExistingMatchingCard(Card.IsTributeSummoned,tp,LOCATION_MZONE,0,1,nil)
		and (b1 or b2 or b3 or b4 or b5 or b6) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)},
		{b4,aux.Stringid(id,4)},
		{b5,aux.Stringid(id,5)},
		{b6,aux.Stringid(id,6)})
	e:SetLabel(op)
	if op==1 then
		--Destroy 1 monster on the field
		e:SetCategory(CATEGORY_DESTROY)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	elseif op==2 then
		--Destroy up to 2 Spells/Traps on the field
		e:SetCategory(CATEGORY_DESTROY)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1) end
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	elseif op==3 then
		--Discard 1 random card from your opponent's hand
		e:SetCategory(CATEGORY_HANDES)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	elseif op==4 then
		--Destroy 1 face-down card on the field
		e:SetCategory(CATEGORY_DESTROY)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE|PHASE_END,0,1) end
		local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	elseif op==5 then
		--Place 1 card on the field on top of the Deck
		e:SetCategory(CATEGORY_TODECK)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+400,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD)
	elseif op==6 then
		--Banish 1 card on the field
		e:SetCategory(CATEGORY_REMOVE)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+500,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Destroy 1 monster on the field
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==2 then
		--Destroy up to 2 Spells/Traps on the field
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==3 then
		--Discard 1 random card from your opponent's hand
		local hg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT)
		if #hg>0 then
			local g=hg:RandomSelect(tp,1,1,nil)
			Duel.SendtoGrave(g,REASON_DISCARD|REASON_EFFECT)
		end
	elseif op==4 then
		--Destroy 1 face-down card on the field
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==5 then
		--Place 1 card on the field on top of the Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	elseif op==6 then
		--Banish 1 card on the field
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end