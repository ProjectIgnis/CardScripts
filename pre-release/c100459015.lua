--スーパークリティカル
--Super Critical
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can add 1 card with an effect that requires a die roll from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Once per Chain per player, if either player rolls a 1 for a card effect's die roll: They can activate 1 of these effects;
	--● They destroy up to 3 monsters their opponent controls
	--● They destroy 1 monster their opponent controls, and if they do, they negate the effects of 1 monster their opponent controls
	--● They Special Summon 1 monster from their GY
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_EVENT_PLAYER)
	e2a:SetCode(EVENT_CUSTOM+id)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.IsDamageStep()
	end)
	e2a:SetTarget(s.efftg)
	e2a:SetOperation(s.effop)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetProperty(EFFECT_CANNOT_DISABLE)
	e2b:SetCode(EVENT_TOSS_DICE)
	e2b:SetRange(LOCATION_SZONE)
	e2b:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local dice_results={Duel.GetDiceResult()}
		local self_dice_count=aux.GetDiceCountSelfFromEv(ev)
		for i=1,#dice_results do
			if dice_results[i]==1 then
				local event_player=i<=self_dice_count and ep or 1-ep
				Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,r,rp,event_player,ev)
			end
		end
		return false
	end)
	c:RegisterEffect(e2b)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c.roll_dice and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.desfilter(c,tp)
	return Duel.IsExistingMatchingCard(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,c)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	--● They destroy up to 3 monsters their opponent controls
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local option_1=#g>0
	--● They destroy 1 monster their opponent controls, and if they do, they negate the effects of 1 monster their opponent controls
	local option_2=Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,tp)
	--● They Special Summon 1 monster from their GY
	local option_3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,0,1,nil,e,0,tp,false,false)
	if chk==0 then return (option_1 or option_2 or option_3) and not c:HasFlagEffect(id+100+tp) end
	--Once per Chain per player
	c:RegisterFlagEffect(id+100+tp,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,3)},
		{option_2,aux.Stringid(id,4)},
		{option_3,aux.Stringid(id,5)})
	e:GetChainData().choice=choice
	if choice==1 then
		--● They destroy up to 3 monsters their opponent controls
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	elseif choice==2 then
		--● They destroy 1 monster their opponent controls, and if they do, they negate the effects of 1 monster their opponent controls
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
	elseif choice==3 then
		--● They Special Summon 1 monster from their GY
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● They destroy up to 3 monsters their opponent controls
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,3,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif choice==2 then
		--● They destroy 1 monster their opponent controls, and if they do, they negate the effects of 1 monster their opponent controls
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
		if #dg==0 then return end
		Duel.HintSelection(dg)
		if Duel.Destroy(dg,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
			local sc=Duel.SelectMatchingCard(tp,Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
			if sc then
				Duel.HintSelection(sc)
				--Negate the effects of 1 monster their opponent controls
				sc:NegateEffects(e:GetHandler())
			end
		end
	elseif choice==3 then
		--● They Special Summon 1 monster from their GY
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,0,1,1,nil,e,0,tp,false,false)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end