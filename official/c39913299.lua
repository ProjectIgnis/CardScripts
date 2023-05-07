--真実の名
--The True Name
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp,ft)
	return c:IsAttribute(ATTRIBUTE_DIVINE) and (c:IsAbleToHand()
		or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp,ft)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
			local sc=g:Select(tp,1,1,nil):GetFirst()
			local b1=sc:IsAbleToHand()
			local b2=sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0
			local op=Duel.SelectEffect(tp,
					{b1,aux.Stringid(id,1)},
					{b2,aux.Stringid(id,2)})
			if op==1 then
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sc)
			else
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			Duel.DisableShuffleCheck()
		end
		Duel.ShuffleHand(tp)
	else
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(tc,REASON_EFFECT|REASON_EXCAVATE)
	end
end