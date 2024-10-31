--ダーク・コンタクト
--Dark Contact
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_FUSION,72043279} --"Supreme King's Castle"
function s.fusfilter(c)
	return c.dark_calling
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
function s.thfilter(c)
	return c:IsCode(72043279,CARD_DARK_FUSION) and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={fusfilter=s.fusfilter,
					matfilter=Fusion.OnFieldMat(Card.IsAbleToDeck),
					extrafil=s.fextra,
					extraop=Fusion.ShuffleMaterial,
					chkf=FUSPROC_NOLIMIT}
	--Fusion Summon 1 Fusion Monster from your Extra Deck, that must be Special Summoned with "Dark Fusion", by shuffling its materials from your field, GY, and/or banishment into the Deck
	local b1=not Duel.HasFlagEffect(tp,id)
		and Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	--Add 1 "Supreme King's Castle" or "Dark Fusion" from your Deck to your hand
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Fusion Summon 1 Fusion Monster from your Extra Deck, that must be Special Summoned with "Dark Fusion", by shuffling its materials from your field, GY, and/or banishment into the Deck
		local params={fusfilter=s.fusfilter,
						matfilter=Fusion.OnFieldMat(Card.IsAbleToDeck),
						extrafil=s.fextra,
						extraop=Fusion.ShuffleMaterial,
						chkf=FUSPROC_NOLIMIT}
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		--Add 1 "Supreme King's Castle" or "Dark Fusion" from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end