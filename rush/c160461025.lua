--ダーク・コーリング
--Dark Calling
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local e1=Fusion.CreateSummonEff{handler=c,fusfilter=s.filter,matfilter=s.mfilter,
									extrafil=s.fextra,extraop=s.extraop,chkf=FUSPROC_NOLIMIT}
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c.dark_calling
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE|LOCATION_HAND) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_HAND,0,nil)
end
function s.extraop(e,tc,tp,sg)
	local gg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND|LOCATION_GRAVE)
	if #gg>0 then Duel.HintSelection(gg) end
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #rg>0 then Duel.ConfirmCards(1-tp,rg) end
	Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	local dg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	local ct=dg:FilterCount(Card.IsControler,nil,tp)
	if ct>0 then
		Duel.SortDeckbottom(tp,tp,ct)
	end
	if #dg>ct then
		Duel.SortDeckbottom(tp,1-tp,#dg-ct)
	end
	sg:Clear()
end
