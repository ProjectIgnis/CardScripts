--オリジン・オブ・レジェンド
--The Origin Stone of Legend
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top 4 cards and Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL) and c:IsLegend() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	Duel.ConfirmDecktop(tp,4)
	local g=Duel.GetDecktopGroup(tp,4)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:IsExists(s.spfilter,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		if #tg>0 then
			Duel.DisableShuffleCheck()
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
			g:RemoveCard(tg)
		end
	end
	if #g>0 then
		Duel.ShuffleDeck(tp)
	end
end
