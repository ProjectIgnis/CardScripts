--トランザム・ネビュラ・フュージョン
--Transam Nebula Fusion
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send to Graveyard and Fusion Summon
	local params={aux.FilterBoolFunction(Card.ListsCodeAsMaterial,CARD_TRANSAMU_RAINAC),aux.FALSE,s.fextra,Fusion.ShuffleMaterial}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
s.listed_names={CARD_TRANSAMU_RAINAC}
function s.matfilter(c)
	return (c:IsLocation(LOCATION_MZONE) or (c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_GALAXY))) and c:IsAbleToDeck()
end
function s.checkmat(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==1
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil),s.checkmat
end
function s.disfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_HAND,0,1,1,nil)
		if Duel.SendtoGrave(tg,REASON_EFFECT)>0 and fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end