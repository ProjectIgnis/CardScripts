--四次元竜クレイデス
--Craydeath the Four Dimensional Dragon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuners
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--You can banish up to 4 cards from your hand, then activate this effect based on the number banished (but you can only use each effect of "Craydeath the Four Dimensional Dragon" once per turn);
	--● 1: Special Summon 1 Level 4 or lower monster from your hand.
	--● 2: Banish 1 Level 4 or lower monster on the field.
	--● 3: Send 1 DARK monster from your Deck to the GY.
	--● 4: Draw 5 cards instead of 1 for your normal draw during your next Draw Phase.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--When the fourth attack of each turn is declared: You can make this card's ATK become 4000.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFlagEffect(0,id)==3 and not e:GetHandler():IsAttack(4000)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--Make this card's ATK become 4000
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(4000)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end)
	c:RegisterEffect(e2)
	--Count attack declarations each turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
		end)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.spbanishcostfilter(c,e,tp)
	return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.banishmonfilter(c)
	return c:IsLevelBelow(4) and c:IsFaceup() and c:IsAbleToRemove()
end
function s.togravefilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,nil)
	--● 1: Special Summon 1 Level 4 or lower monster from your hand.
	local option_1=not Duel.HasFlagEffect(tp,id+1) and #g>=1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spbanishcostfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	--● 2: Banish 1 Level 4 or lower monster on the field.
	local option_2=not Duel.HasFlagEffect(tp,id+2) and #g>=2
		and Duel.IsExistingMatchingCard(s.banishmonfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	--● 3: Send 1 DARK monster from your Deck to the GY.
	local option_3=not Duel.HasFlagEffect(tp,id+3) and #g>=3
		and Duel.IsExistingMatchingCard(s.togravefilter,tp,LOCATION_DECK,0,1,nil)
	--● 4: Draw 5 cards instead of 1 for your normal draw during your next Draw Phase.
	local option_4=not Duel.HasFlagEffect(tp,id+4) and #g>=4
		and Duel.GetDrawCount(tp)~=5
	if chk==0 then return option_1 or option_2 or option_3 or option_4 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,2)},
		{option_2,aux.Stringid(id,3)},
		{option_3,aux.Stringid(id,4)},
		{option_4,aux.Stringid(id,5)})
	e:GetChainData().choice=choice
	local sg=nil
	if choice==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		sg=Duel.SelectMatchingCard(tp,s.spbanishcostfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,choice,choice,nil)
	end
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	Duel.RegisterFlagEffect(tp,id+choice,RESET_PHASE|PHASE_END,0,1)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local choice=e:GetChainData().choice
	if choice==1 then
		--● 1: Special Summon 1 Level 4 or lower monster from your hand.
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif choice==2 then
		--● 2: Banish 1 Level 4 or lower monster on the field.
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_EITHER,LOCATION_MZONE)
	elseif choice==3 then
		--● 3: Send 1 DARK monster from your Deck to the GY.
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif choice==4 then
		--● 4: Draw 5 cards instead of 1 for your normal draw during your next Draw Phase.
		e:SetCategory(0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● 1: Special Summon 1 Level 4 or lower monster from your hand.
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif choice==2 then
		--● 2: Banish 1 Level 4 or lower monster on the field.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.banishmonfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	elseif choice==3 then
		--● 3: Send 1 DARK monster from your Deck to the GY.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.togravefilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	elseif choice==4 then
		--● 4: Draw 5 cards instead of 1 for your normal draw during your next Draw Phase.
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,6))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetValue(5)
		e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,1)
		Duel.RegisterEffect(e1,tp)
	end
end