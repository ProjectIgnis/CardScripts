--フェイバリット・コンタクト
--Favorite Contact
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff{handler=c,fusfilter=s.spfilter,matfilter=Card.IsAbleToDeck,extrafil=s.fextra,
									extraop=s.extraop,value=0,chkf=FUSPROC_NOTFUSION,stage2=s.stage2}
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_NEOS}
s.listed_series={0x8}
function s.spfilter(c)
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListSetCard(c,0x8)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_GRAVE,0,nil)+
		Duel.GetMatchingGroup(aux.FilterFaceupFunction(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_REMOVED,0,nil)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsFacedown,nil)
	if #rg>0 then Duel.ConfirmCards(1-tp,rg) end
	local gyrmg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED)
	if #gyrmg>0 then Duel.HintSelection(gyrmg,true) end
	Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>0 then Duel.SortDeckbottom(tp,tp,ct) end
	sg:Clear()
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 and sg:IsExists(Card.IsCode,1,nil,CARD_NEOS,SUMMON_TYPE_FUSION,tp) then
		--Cannot be returned to the Extra Deck
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TO_DECK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e1:SetCode(EFFECT_CANNOT_TO_HAND)
		tc:RegisterEffect(e2)
	end
end