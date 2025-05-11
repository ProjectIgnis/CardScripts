--フラッシュメモリー・フュージョン
--Flash Memory Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local e1=Fusion.CreateSummonEff(c,s.fusfilter,s.matfilter,s.fextra,Fusion.ShuffleMaterial,nil,s.stage2)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_BLUETOOTH_B_DRAGON,CARD_REDBOOT_B_DRAGON}
function s.fusfilter(c)
	return c:ListsCodeAsMaterial(CARD_BLUETOOTH_B_DRAGON,CARD_REDBOOT_B_DRAGON)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.cfilter(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and (c:IsReason(REASON_EFFECT) or (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp)))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local g=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,1-tp,LOCATION_GRAVE,0,nil,e,0,1-tp,false,false,POS_FACEUP_ATTACK)
		if Duel.GetTurnPlayer()==tp and #g>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
			local sg=g:Select(1-tp,1,1,nil)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
			end
		end
	end
end